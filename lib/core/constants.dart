import 'package:crypto/crypto.dart';
import 'dart:convert';

class Constants {
  // Hive Box Names
  static const String userBox = 'user_box';
  static const String recipesBox = 'recipes_box';
  static const String recipesCacheBox = 'recipes_cache';
  static const String shoppingCacheBox = 'shopping_cache';
  static const String settingsBox = 'settings_box';
  
  // Firebase Remote Config Keys
  static const String freeRecipeLimitKey = 'free_recipe_limit';
  static const String enableAdsKey = 'enable_ads';
  static const String premiumPriceEurKey = 'premium_price_eur';
  static const String enableSocialBetaKey = 'enable_social_beta';
  
  // Default Values
  static const int defaultFreeRecipeLimit = 10;
  static const bool defaultEnableAds = true;
  static const double defaultPremiumPriceEur = 4.49;
  static const bool defaultEnableSocialBeta = true;
  
  // App Configuration
  static const String primaryLocale = 'ro';
  static const String fallbackLocale = 'en';
  
  // Animation Durations
  static const Duration introAnimationDuration = Duration(milliseconds: 1600);
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
  
  // OCR Configuration
  static const String tesseractDataPath = 'assets/tessdata/';
  static const String englishTessData = 'eng.traineddata';
  static const String romanianTessData = 'ron.traineddata';
  
  // Translation Configuration
  static const String targetLanguage = 'ro';
  
  // Storage Paths
  static const String recipesPath = 'recipes';
  static const String userImagesPath = 'user_images';
  static const String tempImagesPath = 'temp_images';
  
  // Cache Limits
  static const int maxCachedRecipes = 50;
  
  // Recipe De-duplication
  static String generateRecipeId(String sourceLink) {
    final normalized = _normalizeUrl(sourceLink);
    final bytes = utf8.encode(normalized);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static String _normalizeUrl(String url) {
    // Remove protocol, www, trailing slash, and convert to lowercase
    return url
        .toLowerCase()
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'^www\.'), '')
        .replaceAll(RegExp(r'/$'), '');
  }
}

// Ingredient Categories
class IngredientCategory {
  static const String produce = 'produce';
  static const String dairy = 'dairy';
  static const String meat = 'meat';
  static const String pantry = 'pantry';
  static const String spices = 'spices';
  static const String bakery = 'bakery';
  static const String beverages = 'beverages';
  static const String other = 'other';
  
  static const Map<String, String> labels = {
    produce: 'Legume și fructe',
    dairy: 'Lactate',
    meat: 'Carne și pește',
    pantry: 'Bucătărie',
    spices: 'Condimente',
    bakery: 'Panificație',
    beverages: 'Băuturi',
    other: 'Altele',
  };
  
  static const Map<String, String> labelsEn = {
    produce: 'Produce',
    dairy: 'Dairy',
    meat: 'Meat & Fish',
    pantry: 'Pantry',
    spices: 'Spices',
    bakery: 'Bakery',
    beverages: 'Beverages',
    other: 'Other',
  };
  
  static List<String> get all => [
    produce, dairy, meat, pantry, spices, bakery, beverages, other
  ];
}

// User Plans
class UserPlan {
  static const String free = 'free';
  static const String premium = 'premium';
  
  static List<String> get all => [free, premium];
}

// User Visibility
class UserVisibility {
  static const String private = 'private';
  static const String friends = 'friends';
  static const String public = 'public';
  
  static List<String> get all => [private, friends, public];
}

// Meal Types
class MealType {
  static const String breakfast = 'breakfast';
  static const String lunch = 'lunch';
  static const String dinner = 'dinner';
  static const String snack = 'snack';
  
  static List<String> get all => [breakfast, lunch, dinner, snack];
}

// Activity Types
class ActivityType {
  static const String saved = 'saved';
  static const String cooked = 'cooked';
  static const String completedStep = 'completed_step';
  static const String badge = 'badge';
  
  static List<String> get all => [saved, cooked, completedStep, badge];
}

// Social Post Visibility
class PostVisibility {
  static const String public = 'public';
  static const String friends = 'friends';
  
  static List<String> get all => [public, friends];
}

// Badges
class Badge {
  static const String firstSave = 'first_save';
  static const String firstCook = 'first_cook';
  static const String fiveRecipes = 'five_recipes';
  static const String sevenDayStreak = 'seven_day_streak';
  static const String veggieWeek = 'veggie_week';
  static const String dessertMaster = 'dessert_master';
  static const String recipes100 = 'recipes_100';
  static const String inviteFriends = 'invite_friends';
  static const String cookingChallenge = 'cooking_challenge';
  
  static const Map<String, String> labels = {
    firstSave: 'Prima salvare',
    firstCook: 'Prima gătire',
    fiveRecipes: 'Cinci rețete',
    sevenDayStreak: 'Șapte zile consecutive',
    veggieWeek: 'Săptămâna verde',
    dessertMaster: 'Maestrul deserturilor',
    recipes100: 'O sută de rețete',
    inviteFriends: 'Invită prietenii',
    cookingChallenge: 'Provocarea gătitului',
  };
  
  static const Map<String, String> labelsEn = {
    firstSave: 'First Save',
    firstCook: 'First Cook',
    fiveRecipes: 'Five Recipes',
    sevenDayStreak: 'Seven Day Streak',
    veggieWeek: 'Veggie Week',
    dessertMaster: 'Dessert Master',
    recipes100: '100 Recipes',
    inviteFriends: 'Invite Friends',
    cookingChallenge: 'Cooking Challenge',
  };
  
  static List<String> get all => [
    firstSave, firstCook, fiveRecipes, sevenDayStreak, 
    veggieWeek, dessertMaster, recipes100, inviteFriends, cookingChallenge
  ];
}

// Supported Languages
class SupportedLanguage {
  static const String romanian = 'ro';
  static const String english = 'en';
  
  static List<String> get all => [romanian, english];
}
