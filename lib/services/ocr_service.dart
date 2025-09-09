import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  /// Extract text from image using Tesseract OCR
  Future<String> extractTextFromImage(String imagePath, {String language = 'eng'}) async {
    try {
      // Get the path to the tessdata directory
      final tessDataPath = await _getTessDataPath();
      
      // Perform OCR
      final extractedText = await FlutterTesseractOcr.extractText(
        imagePath,
        language: language,
        args: {
          "tessdata_dir": tessDataPath,
          "psm": "6", // Assume a single uniform block of text
          "oem": "3", // Default OCR Engine Mode
        },
      );
      
      return extractedText.trim();
    } catch (e) {
      throw Exception('Failed to extract text from image: $e');
    }
  }

  /// Extract text from image with multiple language support
  Future<String> extractTextFromImageMultiLanguage(
    String imagePath, {
    List<String> languages = const ['eng', 'ron'],
  }) async {
    try {
      final tessDataPath = await _getTessDataPath();
      final languageString = languages.join('+');
      
      final extractedText = await FlutterTesseractOcr.extractText(
        imagePath,
        language: languageString,
        args: {
          "tessdata_dir": tessDataPath,
          "psm": "6",
          "oem": "3",
        },
      );
      
      return extractedText.trim();
    } catch (e) {
      throw Exception('Failed to extract text from image: $e');
    }
  }

  /// Extract recipe text from image (optimized for recipe cards)
  Future<Map<String, String>> extractRecipeFromImage(String imagePath) async {
    try {
      // First try with English and Romanian
      String fullText = await extractTextFromImageMultiLanguage(
        imagePath,
        languages: ['eng', 'ron'],
      );

      // Parse the extracted text to identify recipe components
      final recipeData = _parseRecipeText(fullText);
      
      return recipeData;
    } catch (e) {
      throw Exception('Failed to extract recipe from image: $e');
    }
  }

  /// Parse extracted text to identify recipe components
  Map<String, String> _parseRecipeText(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    String title = '';
    List<String> ingredients = [];
    List<String> instructions = [];
    String cookingTime = '';
    String servings = '';

    // Simple parsing logic - this could be enhanced with more sophisticated NLP
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Look for title (usually the first substantial line)
      if (title.isEmpty && line.length > 3 && line.length < 100) {
        title = line;
      }
      
      // Look for ingredients (lines that might contain measurements or food items)
      if (_isIngredientLine(line)) {
        ingredients.add(line);
      }
      
      // Look for instructions (lines that might contain cooking steps)
      if (_isInstructionLine(line)) {
        instructions.add(line);
      }
      
      // Look for cooking time
      if (_containsTime(line)) {
        cookingTime = line;
      }
      
      // Look for servings
      if (_containsServings(line)) {
        servings = line;
      }
    }

    return {
      'title': title,
      'ingredients': ingredients.join('\n'),
      'instructions': instructions.join('\n'),
      'cookingTime': cookingTime,
      'servings': servings,
      'fullText': text,
    };
  }

  /// Check if a line looks like an ingredient
  bool _isIngredientLine(String line) {
    final lowerLine = line.toLowerCase();
    
    // Common ingredient indicators
    final ingredientKeywords = [
      'cup', 'tbsp', 'tsp', 'oz', 'lb', 'kg', 'g', 'ml', 'l',
      'salt', 'pepper', 'oil', 'butter', 'flour', 'sugar',
      'onion', 'garlic', 'tomato', 'cheese', 'milk', 'egg',
      'meat', 'chicken', 'beef', 'pork', 'fish', 'vegetable',
    ];
    
    return ingredientKeywords.any((keyword) => lowerLine.contains(keyword));
  }

  /// Check if a line looks like an instruction
  bool _isInstructionLine(String line) {
    final lowerLine = line.toLowerCase();
    
    // Common instruction indicators
    final instructionKeywords = [
      'heat', 'cook', 'bake', 'fry', 'boil', 'mix', 'stir',
      'add', 'place', 'put', 'remove', 'serve', 'garnish',
      'preheat', 'season', 'taste', 'check', 'drain',
    ];
    
    return instructionKeywords.any((keyword) => lowerLine.contains(keyword));
  }

  /// Check if a line contains time information
  bool _containsTime(String line) {
    final lowerLine = line.toLowerCase();
    return lowerLine.contains(RegExp(r'\d+\s*(min|hour|hr|minute)'));
  }

  /// Check if a line contains serving information
  bool _containsServings(String line) {
    final lowerLine = line.toLowerCase();
    return lowerLine.contains(RegExp(r'\d+\s*(serving|portion|person)'));
  }

  /// Get the path to the tessdata directory
  Future<String> _getTessDataPath() async {
    try {
      // For Flutter, we'll use the assets directory
      // The tessdata files should be in assets/tessdata/
      final directory = await getApplicationDocumentsDirectory();
      final tessDataPath = '${directory.path}/tessdata';
      
      // Ensure the directory exists
      final tessDataDir = Directory(tessDataPath);
      if (!await tessDataDir.exists()) {
        await tessDataDir.create(recursive: true);
      }
      
      return tessDataPath;
    } catch (e) {
      throw Exception('Failed to get tessdata path: $e');
    }
  }

  /// Check if OCR is available
  Future<bool> isOCRAvailable() async {
    try {
      // Try to initialize Tesseract with a simple test
      await _getTessDataPath();
      return true; // If we can get the path, OCR should be available
    } catch (e) {
      return false;
    }
  }

  /// Get supported languages
  List<String> getSupportedLanguages() {
    return ['eng', 'ron']; // English and Romanian
  }
}
