import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ingredient.dart';
import '../models/step_item.dart';
import '../models/recipe_text.dart';

class TranslationService {
  static const String _modelUrl = 'https://huggingface.co/Helsinki-NLP/opus-mt-en-ro/resolve/main/';
  static const String _modelName = 'opus-mt-en-ro';
  static const String _modelVersion = '1.0.0';
  
  static TranslationService? _instance;
  static TranslationService get instance => _instance ??= TranslationService._();
  
  TranslationService._();
  
  bool _isModelDownloaded = false;
  bool _isInitialized = false;
  
  /// Initialize the translation service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _checkModelStatus();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Translation service initialization failed: $e');
    }
  }
  
  /// Check if model is downloaded and ready
  Future<bool> isModelReady() async {
    if (!_isInitialized) await initialize();
    return _isModelDownloaded;
  }
  
  /// Download the translation model if needed
  Future<void> downloadModelIfNeeded() async {
    if (_isModelDownloaded) return;
    
    try {
      debugPrint('Downloading translation model...');
      await _downloadModel();
      _isModelDownloaded = true;
      await _saveModelStatus(true);
      debugPrint('Translation model downloaded successfully');
    } catch (e) {
      debugPrint('Failed to download translation model: $e');
      rethrow;
    }
  }
  
  /// Translate text from English to Romanian
  Future<String> translateText(String text) async {
    if (text.isEmpty) return text;
    
    if (!await isModelReady()) {
      await downloadModelIfNeeded();
    }
    
    try {
      // For now, use a simple rule-based translation
      // In a real implementation, you would use the downloaded model
      return await _translateWithRules(text);
    } catch (e) {
      debugPrint('Translation failed: $e');
      return text; // Return original text if translation fails
    }
  }
  
  /// Translate recipe text
  Future<RecipeText> translateRecipeText(RecipeText originalText) async {
    final translatedOriginal = await translateText(originalText.original);
    
    return RecipeText(
      original: originalText.original,
      ro: translatedOriginal,
      summary: originalText.summary != null ? await translateText(originalText.summary!) : null,
      notes: originalText.notes != null ? await translateText(originalText.notes!) : null,
    );
  }
  
  /// Translate ingredients list
  Future<List<Ingredient>> translateIngredients(List<Ingredient> ingredients) async {
    final translatedIngredients = <Ingredient>[];
    
    for (final ingredient in ingredients) {
      final translatedName = await translateText(ingredient.name);
      final translatedNotes = ingredient.notes != null 
          ? await translateText(ingredient.notes!) 
          : null;
      
      translatedIngredients.add(Ingredient(
        name: translatedName,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        category: ingredient.category,
        notes: translatedNotes,
      ));
    }
    
    return translatedIngredients;
  }
  
  /// Translate steps list
  Future<List<StepItem>> translateSteps(List<StepItem> steps) async {
    final translatedSteps = <StepItem>[];
    
    for (final step in steps) {
      final translatedText = await translateText(step.text);
      final translatedNotes = step.notes != null 
          ? await translateText(step.notes!) 
          : null;
      
      translatedSteps.add(StepItem(
        index: step.index,
        text: translatedText,
        durationSec: step.durationSec,
        imageUrl: step.imageUrl,
        notes: translatedNotes,
      ));
    }
    
    return translatedSteps;
  }
  
  /// Get model download progress
  Future<double> getModelDownloadProgress() async {
    // This would track actual download progress in a real implementation
    return _isModelDownloaded ? 1.0 : 0.0;
  }
  
  /// Get model size in MB
  Future<int> getModelSize() async {
    // Estimated size for opus-mt-en-ro model
    return 200; // MB
  }
  
  /// Clear downloaded model
  Future<void> clearModel() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${appDir.path}/translation_models/$_modelName');
      
      if (await modelDir.exists()) {
        await modelDir.delete(recursive: true);
      }
      
      _isModelDownloaded = false;
      await _saveModelStatus(false);
    } catch (e) {
      debugPrint('Failed to clear model: $e');
    }
  }
  
  // Private methods
  
  Future<void> _checkModelStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isModelDownloaded = prefs.getBool('translation_model_downloaded') ?? false;
    
    if (_isModelDownloaded) {
      // Verify model files exist
      final appDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${appDir.path}/translation_models/$_modelName');
      _isModelDownloaded = await modelDir.exists();
    }
  }
  
  Future<void> _saveModelStatus(bool downloaded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('translation_model_downloaded', downloaded);
  }
  
  Future<void> _downloadModel() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${appDir.path}/translation_models/$_modelName');
    
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    
    // In a real implementation, you would download the actual model files
    // For now, we'll simulate the download
    await Future.delayed(const Duration(seconds: 2));
    
    // Create a placeholder file to indicate model is "downloaded"
    final placeholderFile = File('${modelDir.path}/model.bin');
    await placeholderFile.writeAsString('placeholder');
  }
  
  /// Simple rule-based translation for common cooking terms
  Future<String> _translateWithRules(String text) async {
    // This is a simplified rule-based translation
    // In production, you would use the actual ML model
    
    final translations = {
      // Common cooking verbs
      'add': 'adaugă',
      'mix': 'amestecă',
      'stir': 'amestecă',
      'cook': 'gătește',
      'bake': 'coace',
      'fry': 'prăjește',
      'boil': 'fierbe',
      'simmer': 'fierbe la foc mic',
      'roast': 'prăjește în cuptor',
      'grill': 'grătar',
      'steam': 'abur',
      'blend': 'mixează',
      'chop': 'taie',
      'slice': 'taie felii',
      'dice': 'taie cuburi',
      'mince': 'tocă',
      'grate': 'raie',
      'peel': 'cojește',
      'wash': 'spală',
      'drain': 'scurge',
      'season': 'condimentează',
      'taste': 'gustă',
      'serve': 'serveste',
      
      // Common ingredients
      'salt': 'sare',
      'pepper': 'piper',
      'oil': 'ulei',
      'butter': 'unt',
      'flour': 'făină',
      'sugar': 'zahăr',
      'eggs': 'ouă',
      'milk': 'lapte',
      'cheese': 'brânză',
      'onion': 'ceapă',
      'garlic': 'usturoi',
      'tomato': 'roșie',
      'carrot': 'morcov',
      'potato': 'cartof',
      'chicken': 'pui',
      'beef': 'carne de vită',
      'pork': 'carne de porc',
      'fish': 'pește',
      'rice': 'orez',
      'pasta': 'paste',
      'bread': 'pâine',
      'water': 'apă',
      'vinegar': 'oțet',
      'lemon': 'lămâie',
      'herbs': 'iarbă',
      'spices': 'condimente',
      
      // Common measurements
      'cup': 'cană',
      'cups': 'căni',
      'tablespoon': 'lingură mare',
      'tablespoons': 'linguri mari',
      'teaspoon': 'linguriță',
      'teaspoons': 'lingurițe',
      'pound': 'livră',
      'pounds': 'livre',
      'ounce': 'uncie',
      'ounces': 'uncii',
      'gram': 'gram',
      'grams': 'grame',
      'kilogram': 'kilogram',
      'kilograms': 'kilograme',
      'liter': 'litru',
      'liters': 'litri',
      'milliliter': 'mililitru',
      'milliliters': 'mililitri',
      
      // Common cooking terms
      'minutes': 'minute',
      'minute': 'minut',
      'hours': 'ore',
      'hour': 'oră',
      'seconds': 'secunde',
      'second': 'secundă',
      'degrees': 'grade',
      'degree': 'grad',
      'celsius': 'celsius',
      'fahrenheit': 'fahrenheit',
      'preheat': 'preîncălzește',
      'oven': 'cuptor',
      'pan': 'tigaie',
      'pot': 'oală',
      'bowl': 'castron',
      'plate': 'farfurie',
      'knife': 'cuțit',
      'spoon': 'lingură',
      'fork': 'furculiță',
      'hot': 'fierbinte',
      'cold': 'rece',
      'warm': 'călduț',
      'room temperature': 'temperatura camerei',
      'medium heat': 'foc mediu',
      'high heat': 'foc mare',
      'low heat': 'foc mic',
      'until golden': 'până devine auriu',
      'until tender': 'până devine fraged',
      'until done': 'până e gata',
      'al dente': 'al dente',
      'garnish': 'garnisește',
      'garnish with': 'garnisește cu',
    };
    
    String translated = text.toLowerCase();
    
    // Apply translations
    for (final entry in translations.entries) {
      final regex = RegExp(r'\b' + RegExp.escape(entry.key) + r'\b', caseSensitive: false);
      translated = translated.replaceAll(regex, entry.value);
    }
    
    // Capitalize first letter
    if (translated.isNotEmpty) {
      translated = translated[0].toUpperCase() + translated.substring(1);
    }
    
    return translated;
  }
}

/// Translation result with progress tracking
class TranslationResult {
  final String originalText;
  final String translatedText;
  final double progress;
  final bool isComplete;
  final String? error;
  
  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.progress,
    required this.isComplete,
    this.error,
  });
}

/// Translation progress callback
typedef TranslationProgressCallback = void Function(TranslationResult result);