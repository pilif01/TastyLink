import 'package:flutter/services.dart';

class ShareHandler {
  static final ShareHandler _instance = ShareHandler._internal();
  factory ShareHandler() => _instance;
  ShareHandler._internal();

  static const MethodChannel _channel = MethodChannel('tasty_link/share');

  /// Handle shared content from platform
  static Future<void> handleSharedContent() async {
    try {
      final String? sharedText = await _channel.invokeMethod('getSharedText');
      
      if (sharedText != null && sharedText.isNotEmpty) {
        // Navigate to home page with prefilled link
        // This would be called from the main app when it receives shared content
        _navigateToHomeWithLink(sharedText);
      }
    } catch (e) {
      print('Error handling shared content: $e');
    }
  }

  /// Navigate to home page with prefilled link
  static void _navigateToHomeWithLink(String link) {
    // This would be implemented in the main app to navigate to home
    // with the shared link prefilled in the input field
    print('Received shared link: $link');
  }

  /// Share text content
  static Future<void> shareText(String text) async {
    try {
      await _channel.invokeMethod('shareText', {'text': text});
    } catch (e) {
      print('Error sharing text: $e');
    }
  }

  /// Share recipe
  static Future<void> shareRecipe(Map<String, dynamic> recipe) async {
    try {
      final formattedText = _formatRecipeForSharing(recipe);
      await shareText(formattedText);
    } catch (e) {
      print('Error sharing recipe: $e');
    }
  }

  /// Format recipe data for sharing
  static String _formatRecipeForSharing(Map<String, dynamic> recipe) {
    final buffer = StringBuffer();
    
    buffer.writeln('🍽️ ${recipe['title'] ?? 'Rețetă'}');
    buffer.writeln();
    
    if (recipe['cookingTime'] != null) {
      buffer.writeln('⏱️ Timp de gătit: ${recipe['cookingTime']}');
    }
    
    if (recipe['servings'] != null) {
      buffer.writeln('👥 Porții: ${recipe['servings']}');
    }
    
    buffer.writeln();
    
    if (recipe['ingredients'] != null) {
      buffer.writeln('📝 Ingrediente:');
      final ingredients = recipe['ingredients'] as List<dynamic>;
      for (final ingredient in ingredients) {
        buffer.writeln('• $ingredient');
      }
      buffer.writeln();
    }
    
    if (recipe['instructions'] != null) {
      buffer.writeln('👨‍🍳 Instrucțiuni:');
      final instructions = recipe['instructions'] as List<dynamic>;
      for (int i = 0; i < instructions.length; i++) {
        buffer.writeln('${i + 1}. ${instructions[i]}');
      }
      buffer.writeln();
    }
    
    if (recipe['sourceUrl'] != null) {
      buffer.writeln('🔗 Sursa: ${recipe['sourceUrl']}');
    }
    
    buffer.writeln();
    buffer.writeln('Extras cu TastyLink 📱');
    
    return buffer.toString();
  }
}
