import '../models/ingredient.dart';
import '../models/step_item.dart';

class RecipeExtractor {
  /// Extract ingredients from text
  List<Ingredient> extractIngredients(String text) {
    final ingredients = <Ingredient>[];
    final lines = text.split('\n');
    
    bool inIngredientsSection = false;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // Detect ingredients section
      if (trimmedLine.toLowerCase().contains('ingredient')) {
        inIngredientsSection = true;
        continue;
      }
      
      // Detect end of ingredients section
      if (inIngredientsSection && 
          (trimmedLine.toLowerCase().contains('instruction') ||
           trimmedLine.toLowerCase().contains('step') ||
           trimmedLine.toLowerCase().contains('method'))) {
        break;
      }
      
      if (inIngredientsSection && trimmedLine.isNotEmpty) {
        final ingredient = _parseIngredientLine(trimmedLine);
        if (ingredient != null) {
          ingredients.add(ingredient);
        }
      }
    }
    
    return ingredients;
  }
  
  /// Extract cooking steps from text
  List<StepItem> extractSteps(String text) {
    final steps = <StepItem>[];
    final lines = text.split('\n');
    
    bool inStepsSection = false;
    int stepIndex = 1;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // Detect steps section
      if (trimmedLine.toLowerCase().contains('instruction') ||
          trimmedLine.toLowerCase().contains('step') ||
          trimmedLine.toLowerCase().contains('method')) {
        inStepsSection = true;
        continue;
      }
      
      if (inStepsSection && trimmedLine.isNotEmpty) {
        // Check if line looks like a step
        final stepPatterns = [
          RegExp(r'^\d+[\.\)]\s*(.+)'), // "1. Step text" or "1) Step text"
          RegExp(r'^(first|second|third|fourth|fifth|sixth|seventh|eighth|ninth|tenth)[:\-]?\s*(.+)', caseSensitive: false),
        ];
        
        bool isStep = false;
        String stepText = trimmedLine;
        
        for (final pattern in stepPatterns) {
          final match = pattern.firstMatch(trimmedLine);
          if (match != null) {
            stepText = match.group(2) ?? match.group(1) ?? trimmedLine;
            isStep = true;
            break;
          }
        }
        
        // Also consider longer lines as potential steps
        if (isStep || (trimmedLine.length > 20 && !trimmedLine.toLowerCase().contains('ingredient'))) {
          // Extract duration if mentioned
          int? durationSec = _extractDuration(stepText);
          
          steps.add(StepItem(
            index: stepIndex++,
            text: stepText,
            durationSec: durationSec,
          ));
        }
      }
    }
    
    return steps;
  }
  
  /// Extract recipe title
  String? extractTitle(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    if (lines.isEmpty) return null;
    
    // First non-empty line is likely the title
    final firstLine = lines.first.trim();
    
    // Check if it looks like a title (not too long, not all caps, etc.)
    if (firstLine.length > 5 && 
        firstLine.length < 100 && 
        !firstLine.toUpperCase().contains('INGREDIENT') &&
        !firstLine.toUpperCase().contains('INSTRUCTION')) {
      return firstLine;
    }
    
    return null;
  }
  
  /// Extract complete recipe
  RecipeExtractionResult extractRecipe(String text) {
    final cleanedText = _cleanText(text);
    
    // Extract title
    final title = extractTitle(cleanedText);
    
    // Extract ingredients
    final ingredients = extractIngredients(cleanedText);
    
    // Extract steps
    final steps = extractSteps(cleanedText);
    
    return RecipeExtractionResult(
      title: title,
      ingredients: ingredients,
      steps: steps,
      originalText: cleanedText,
      confidence: _calculateConfidence(cleanedText, ingredients, steps),
    );
  }
  
  // Private methods
  
  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'[^\w\s.,!?;:()\-°]'), '') // Remove special chars
        .trim();
  }
  
  Ingredient? _parseIngredientLine(String line) {
    // Skip lines that don't look like ingredients
    if (line.length < 3 || 
        line.toLowerCase().contains('ingredient') ||
        line.toLowerCase().contains('instruction')) {
      return null;
    }
    
    // Try to extract quantity and unit
    final qtyMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(cups?|tablespoons?|tbsp|teaspoons?|tsp|pounds?|lbs?|ounces?|oz|grams?|g|kilograms?|kg|ml|milliliters?|liters?|l)\s+(.+)').firstMatch(line);
    
    if (qtyMatch != null) {
      final qty = double.tryParse(qtyMatch.group(1) ?? '');
      final unit = qtyMatch.group(2)?.toLowerCase();
      final name = qtyMatch.group(3)?.trim() ?? '';
      
      return Ingredient(
        name: name,
        quantity: qty,
        unit: unit,
        category: _categorizeIngredient(name),
      );
    } else {
      // No quantity found, treat as ingredient name only
      return Ingredient(
        name: line,
        category: _categorizeIngredient(line),
      );
    }
  }
  
  int? _extractDuration(String text) {
    final durationMatch = RegExp(r'(\d+)\s*(minutes?|mins?|hours?|hrs?|seconds?|secs?)').firstMatch(text.toLowerCase());
    
    if (durationMatch != null) {
      final value = int.tryParse(durationMatch.group(1) ?? '');
      final unit = durationMatch.group(2)?.toLowerCase();
      
      if (value != null) {
        if (unit?.startsWith('minute') == true || unit?.startsWith('min') == true) {
          return value * 60;
        } else if (unit?.startsWith('hour') == true || unit?.startsWith('hr') == true) {
          return value * 3600;
        } else if (unit?.startsWith('second') == true || unit?.startsWith('sec') == true) {
          return value;
        }
      }
    }
    
    return null;
  }
  
  String _categorizeIngredient(String name) {
    final lowerName = name.toLowerCase();
    
    if (lowerName.contains('flour') || lowerName.contains('sugar') || lowerName.contains('salt') || lowerName.contains('pepper')) {
      return 'Pantry';
    } else if (lowerName.contains('chicken') || lowerName.contains('beef') || lowerName.contains('pork') || lowerName.contains('fish')) {
      return 'Meat & Seafood';
    } else if (lowerName.contains('onion') || lowerName.contains('garlic') || lowerName.contains('tomato') || lowerName.contains('carrot')) {
      return 'Vegetables';
    } else if (lowerName.contains('milk') || lowerName.contains('cheese') || lowerName.contains('butter') || lowerName.contains('egg')) {
      return 'Dairy & Eggs';
    } else if (lowerName.contains('oil') || lowerName.contains('vinegar') || lowerName.contains('sauce')) {
      return 'Condiments & Oils';
    } else {
      return 'Other';
    }
  }
  
  double _calculateConfidence(String text, List<Ingredient> ingredients, List<StepItem> steps) {
    double confidence = 0.5; // Base confidence
    
    // Increase confidence based on text quality
    confidence += _getTextQualityScore(text) * 0.3;
    
    // Increase confidence if we found ingredients
    if (ingredients.isNotEmpty) {
      confidence += 0.1;
    }
    
    // Increase confidence if we found steps
    if (steps.isNotEmpty) {
      confidence += 0.1;
    }
    
    // Increase confidence if we found both ingredients and steps
    if (ingredients.isNotEmpty && steps.isNotEmpty) {
      confidence += 0.1;
    }
    
    return confidence.clamp(0.0, 1.0);
  }
  
  double _getTextQualityScore(String text) {
    if (text.isEmpty) return 0.0;
    
    double score = 1.0;
    
    // Reduce score for common OCR errors
    final errorPatterns = [
      RegExp(r'[|]'), // Pipe characters (common OCR error)
      RegExp(r'[0O]'), // Zero/O confusion
      RegExp(r'[1lI]'), // One/l/I confusion
      RegExp(r'[5S]'), // Five/S confusion
      RegExp(r'[8B]'), // Eight/B confusion
    ];
    
    for (final pattern in errorPatterns) {
      final matches = pattern.allMatches(text).length;
      score -= (matches / text.length) * 0.1;
    }
    
    // Reduce score for very short text
    if (text.length < 50) {
      score *= 0.7;
    }
    
    return score.clamp(0.0, 1.0);
  }
}

/// Result of recipe extraction
class RecipeExtractionResult {
  final String? title;
  final List<Ingredient> ingredients;
  final List<StepItem> steps;
  final String originalText;
  final double confidence;
  
  const RecipeExtractionResult({
    this.title,
    required this.ingredients,
    required this.steps,
    required this.originalText,
    required this.confidence,
  });
  
  /// Check if extraction was successful
  bool get isSuccessful => confidence > 0.3 && (ingredients.isNotEmpty || steps.isNotEmpty);
  
  /// Get summary of extraction
  String get summary {
    final parts = <String>[];
    
    if (title != null) {
      parts.add('Title: $title');
    }
    
    parts.add('Ingredients: ${ingredients.length}');
    parts.add('Steps: ${steps.length}');
    parts.add('Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
    
    return parts.join(', ');
  }
}
