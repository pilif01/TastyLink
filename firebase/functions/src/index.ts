import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { spawn } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

// Initialize Firebase Admin
admin.initializeApp();

interface TranscribeRequest {
  sourceLink: string;
  preferLang?: string;
}

interface TranscribeResponse {
  recipeId: string;
  title?: string;
  creatorHandle?: string;
  sourceLink: string;
  lang: string;
  text: {
    original: string;
    ro?: string;
  };
  ingredients: Array<{
    name: string;
    qty?: number;
    unit?: string;
    category?: string;
    notes?: string;
  }>;
  steps: Array<{
    index: number;
    text: string;
    durationSec?: number;
    imageUrl?: string;
    notes?: string;
  }>;
}

// Main transcription function
export const transcribeFromLink = functions
  .region('europe-central2')
  .runWith({
    timeoutSeconds: 540, // 9 minutes
    memory: '2GB',
  })
  .https.onCall(async (data: TranscribeRequest, context) => {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.'
      );
    }

    const { sourceLink, preferLang } = data;

    if (!sourceLink) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'sourceLink is required'
      );
    }

    try {
      // Generate deterministic recipe ID
      const recipeId = crypto.createHash('sha256').update(sourceLink).digest('hex');
      
      // Check if recipe already exists
      const recipeRef = admin.firestore().collection('recipes').doc(recipeId);
      const existingRecipe = await recipeRef.get();
      
      if (existingRecipe.exists) {
        const existingData = existingRecipe.data() as TranscribeResponse;
        return existingData;
      }

      // Step 1: Download audio using yt-dlp
      const tempDir = '/tmp';
      const audioFile = path.join(tempDir, `audio_${Date.now()}.webm`);
      
      console.log('Downloading audio from:', sourceLink);
      await downloadAudio(sourceLink, audioFile);

      // Step 2: Convert to 16kHz mono WAV using ffmpeg
      const wavFile = path.join(tempDir, `audio_${Date.now()}.wav`);
      console.log('Converting audio to WAV format');
      await convertToWav(audioFile, wavFile);

      // Step 3: Transcribe using faster-whisper
      console.log('Transcribing audio');
      const transcription = await transcribeAudio(wavFile, preferLang);

      // Step 4: Basic text cleaning
      const cleanedText = cleanText(transcription.text);

      // Step 5: Extract recipe components
      const extracted = await extractRecipeComponents(cleanedText, sourceLink);

      // Step 6: Create canonical recipe document
      const recipeData: TranscribeResponse = {
        recipeId,
        title: extracted.title,
        creatorHandle: extracted.creatorHandle,
        sourceLink,
        lang: transcription.language,
        text: {
          original: cleanedText,
        },
        ingredients: extracted.ingredients,
        steps: extracted.steps,
      };

      // Save to Firestore
      await recipeRef.set(recipeData);

      // Clean up temporary files
      try {
        if (fs.existsSync(audioFile)) fs.unlinkSync(audioFile);
        if (fs.existsSync(wavFile)) fs.unlinkSync(wavFile);
      } catch (cleanupError) {
        console.warn('Failed to clean up temporary files:', cleanupError);
      }

      return recipeData;

    } catch (error) {
      console.error('Transcription error:', error);
      throw new functions.https.HttpsError(
        'internal',
        `Failed to transcribe from link: ${error instanceof Error ? error.message : 'Unknown error'}`
      );
    }
  });

// Download audio using yt-dlp
async function downloadAudio(sourceLink: string, outputFile: string): Promise<void> {
  const command = `yt-dlp -f "bestaudio[ext=m4a]/bestaudio" --extract-audio --audio-format webm --output "${outputFile}" "${sourceLink}"`;
  
  try {
    await execAsync(command);
    
    // Check if file was created
    if (!fs.existsSync(outputFile)) {
      throw new Error('Audio file was not downloaded');
    }
  } catch (error) {
    throw new Error(`Failed to download audio: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

// Convert audio to 16kHz mono WAV using ffmpeg
async function convertToWav(inputFile: string, outputFile: string): Promise<void> {
  const command = `ffmpeg -i "${inputFile}" -ar 16000 -ac 1 -y "${outputFile}"`;
  
  try {
    await execAsync(command);
    
    if (!fs.existsSync(outputFile)) {
      throw new Error('WAV file was not created');
    }
  } catch (error) {
    throw new Error(`Failed to convert audio: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

// Transcribe audio using faster-whisper
async function transcribeAudio(audioFile: string, preferLang?: string): Promise<{text: string, language: string}> {
  return new Promise((resolve, reject) => {
    const pythonScript = `
import sys
import os
sys.path.append('/app')

from faster_whisper import WhisperModel
import torch

def transcribe_audio(audio_file, prefer_lang=None):
    try:
        # Use small model for faster processing
        model = WhisperModel("small", device="cpu", compute_type="int8")
        
        # Transcribe with language detection
        segments, info = model.transcribe(
            audio_file,
            language=prefer_lang,
            beam_size=5,
            best_of=5,
            temperature=0.0,
            condition_on_previous_text=False
        )
        
        # Combine all segments
        text = " ".join([segment.text for segment in segments])
        
        return {
            "text": text.strip(),
            "language": info.language
        }
    except Exception as e:
        raise Exception(f"Transcription failed: {str(e)}")

if __name__ == "__main__":
    import json
    audio_file = "${audioFile}"
    prefer_lang = "${preferLang || ''}"
    
    result = transcribe_audio(audio_file, prefer_lang if prefer_lang else None)
    print(json.dumps(result))
`;

    const tempScript = `/tmp/transcribe_${Date.now()}.py`;
    fs.writeFileSync(tempScript, pythonScript);

    const process = spawn('python3', [tempScript]);
    
    let output = '';
    let errorOutput = '';

    process.stdout.on('data', (data) => {
      output += data.toString();
    });

    process.stderr.on('data', (data) => {
      errorOutput += data.toString();
    });

    process.on('close', (code) => {
      try {
        fs.unlinkSync(tempScript);
      } catch (e) {
        // Ignore cleanup errors
      }

      if (code === 0) {
        try {
          const result = JSON.parse(output);
          resolve(result);
        } catch (parseError) {
          reject(new Error(`Failed to parse transcription result: ${parseError}`));
        }
      } else {
        reject(new Error(`Transcription failed with code ${code}: ${errorOutput}`));
      }
    });

    process.on('error', (error) => {
      reject(new Error(`Failed to start transcription process: ${error.message}`));
    });
  });
}

// Basic text cleaning
function cleanText(text: string): string {
  return text
    .replace(/\s+/g, ' ') // Normalize whitespace
    .replace(/[^\w\s.,!?;:()\-]/g, '') // Remove special characters
    .trim();
}

// Extract recipe components using rule-based approach
async function extractRecipeComponents(text: string, sourceLink: string): Promise<{
  title?: string;
  creatorHandle?: string;
  ingredients: Array<{
    name: string;
    qty?: number;
    unit?: string;
    category?: string;
    notes?: string;
  }>;
  steps: Array<{
    index: number;
    text: string;
    durationSec?: number;
    imageUrl?: string;
    notes?: string;
  }>;
}> {
  // Extract title (first line or sentence)
  const lines = text.split('\n').filter(line => line.trim().length > 0);
  const title = lines.length > 0 ? lines[0].trim() : undefined;

  // Extract creator handle from source link
  let creatorHandle: string | undefined;
  try {
    const url = new URL(sourceLink);
    if (url.hostname.includes('youtube.com') || url.hostname.includes('youtu.be')) {
      // Extract channel name from YouTube URL
      creatorHandle = 'YouTube Creator';
    } else if (url.hostname.includes('tiktok.com')) {
      creatorHandle = 'TikTok Creator';
    } else {
      creatorHandle = url.hostname;
    }
  } catch {
    creatorHandle = 'Unknown Creator';
  }

  // Extract ingredients using pattern matching
  const ingredients = extractIngredients(text);

  // Extract steps using pattern matching
  const steps = extractSteps(text);

  return {
    title,
    creatorHandle,
    ingredients,
    steps,
  };
}

// Extract ingredients from text
function extractIngredients(text: string): Array<{
  name: string;
  qty?: number;
  unit?: string;
  category?: string;
  notes?: string;
}> {
  const ingredients: Array<{
    name: string;
    qty?: number;
    unit?: string;
    category?: string;
    notes?: string;
  }> = [];

  // Common ingredient patterns
  const patterns = [
    // "2 cups flour"
    /(\d+(?:\.\d+)?)\s*(cups?|tablespoons?|tbsp|teaspoons?|tsp|pounds?|lbs?|ounces?|oz|grams?|g|kilograms?|kg|ml|milliliters?|liters?|l)\s+([^,.\n]+)/gi,
    // "flour" (without quantity)
    /^([a-zA-Z\s]+)$/gm,
  ];

  const lines = text.split('\n');
  
  for (const line of lines) {
    const trimmedLine = line.trim();
    if (trimmedLine.length < 3) continue;

    // Try to match quantity + unit + ingredient
    const qtyMatch = trimmedLine.match(/(\d+(?:\.\d+)?)\s*(cups?|tablespoons?|tbsp|teaspoons?|tsp|pounds?|lbs?|ounces?|oz|grams?|g|kilograms?|kg|ml|milliliters?|liters?|l)\s+(.+)/i);
    
    if (qtyMatch) {
      const qty = parseFloat(qtyMatch[1]);
      const unit = qtyMatch[2].toLowerCase();
      const name = qtyMatch[3].trim();
      
      ingredients.push({
        name,
        qty,
        unit,
        category: categorizeIngredient(name),
      });
    } else if (trimmedLine.length < 50 && !trimmedLine.includes('step') && !trimmedLine.includes('instruction')) {
      // Simple ingredient name without quantity
      ingredients.push({
        name: trimmedLine,
        category: categorizeIngredient(trimmedLine),
      });
    }
  }

  return ingredients.slice(0, 20); // Limit to 20 ingredients
}

// Extract cooking steps from text
function extractSteps(text: string): Array<{
  index: number;
  text: string;
  durationSec?: number;
  imageUrl?: string;
  notes?: string;
}> {
  const steps: Array<{
    index: number;
    text: string;
    durationSec?: number;
    imageUrl?: string;
    notes?: string;
  }> = [];

  const lines = text.split('\n');
  let stepIndex = 1;

  for (const line of lines) {
    const trimmedLine = line.trim();
    if (trimmedLine.length < 10) continue;

    // Look for step indicators
    const stepPatterns = [
      /^(step\s*\d+[:\-]?\s*)/i,
      /^(\d+[\.\)]\s*)/,
      /^(first|second|third|fourth|fifth|sixth|seventh|eighth|ninth|tenth)[:\-]?\s*/i,
    ];

    let isStep = false;
    for (const pattern of stepPatterns) {
      if (pattern.test(trimmedLine)) {
        isStep = true;
        break;
      }
    }

    // Also consider longer lines as potential steps
    if (isStep || (trimmedLine.length > 20 && !trimmedLine.includes('ingredient'))) {
      // Extract duration if mentioned
      let durationSec: number | undefined;
      const durationMatch = trimmedLine.match(/(\d+)\s*(minutes?|mins?|hours?|hrs?|seconds?|secs?)/i);
      if (durationMatch) {
        const value = parseInt(durationMatch[1]);
        const unit = durationMatch[2].toLowerCase();
        
        if (unit.startsWith('minute') || unit.startsWith('min')) {
          durationSec = value * 60;
        } else if (unit.startsWith('hour') || unit.startsWith('hr')) {
          durationSec = value * 3600;
        } else if (unit.startsWith('second') || unit.startsWith('sec')) {
          durationSec = value;
        }
      }

      steps.push({
        index: stepIndex++,
        text: trimmedLine,
        durationSec,
      });
    }
  }

  return steps.slice(0, 15); // Limit to 15 steps
}

// Categorize ingredient
function categorizeIngredient(name: string): string {
  const lowerName = name.toLowerCase();
  
  if (lowerName.includes('flour') || lowerName.includes('sugar') || lowerName.includes('salt') || lowerName.includes('pepper')) {
    return 'Pantry';
  } else if (lowerName.includes('chicken') || lowerName.includes('beef') || lowerName.includes('pork') || lowerName.includes('fish')) {
    return 'Meat & Seafood';
  } else if (lowerName.includes('onion') || lowerName.includes('garlic') || lowerName.includes('tomato') || lowerName.includes('carrot')) {
    return 'Vegetables';
  } else if (lowerName.includes('milk') || lowerName.includes('cheese') || lowerName.includes('butter') || lowerName.includes('egg')) {
    return 'Dairy & Eggs';
  } else if (lowerName.includes('oil') || lowerName.includes('vinegar') || lowerName.includes('sauce')) {
    return 'Condiments & Oils';
  } else {
    return 'Other';
  }
}