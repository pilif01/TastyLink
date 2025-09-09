# TastyLink Models & Firestore Architecture

This document describes the complete data architecture for TastyLink, including Dart models, Firestore collections, offline-first capabilities, and translation support.

## Overview

TastyLink uses a comprehensive data model with:
- **Offline-first architecture** with Hive caching
- **Translation support** for Romanian and English
- **Recipe de-duplication** based on source URL hashing
- **Social features** with privacy controls
- **Gamification** with badges and statistics
- **Meal planning** and shopping list integration

## Data Models

### Core Models

#### Recipe
```dart
class Recipe {
  final String id;                    // SHA256 hash of normalized sourceLink
  final String title;
  final String creatorHandle;
  final String sourceLink;
  final String lang;                  // "ro" | "en" | ...
  final RecipeText text;              // { original, ro, en }
  final RecipeMedia media;            // { coverImageUrl, stepPhotos, videoUrl, audioUrl }
  final List<Ingredient> ingredients; // Original language
  final List<Ingredient> ingredientsRo; // Romanian translation
  final List<StepItem> steps;         // Original language
  final List<StepItem> stepsRo;       // Romanian translation
  final List<String> tags;
  final int likes;
  final int saves;
  final String? createdByUid;         // For user-created recipes
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### UserProfile
```dart
class UserProfile {
  final String uid;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final String plan;                  // "free" | "premium"
  final UserStats stats;              // { recipesSaved, recipesCooked, streak, badges }
  final UserSocial social;            // { followers, following, bio, visibility }
  final UserReferrals referrals;      // { code, referredCount }
}
```

#### ShoppingItem
```dart
class ShoppingItem {
  final String id;
  final String? recipeId;             // Link to recipe if from recipe
  final String name;
  final double? quantity;
  final String? unit;
  final bool checked;
  final String category;              // IngredientCategory enum
  final DateTime addedAt;
  final String? notes;
}
```

#### PlannerEntry
```dart
class PlannerEntry {
  final String id;
  final String meal;                  // "breakfast" | "lunch" | "dinner" | "snack"
  final String? recipeId;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## Firestore Collections

### users/{uid}
```json
{
  "displayName": "John Doe",
  "photoURL": "https://...",
  "createdAt": "2024-01-01T00:00:00Z",
  "plan": "free",
  "stats": {
    "recipesSaved": 25,
    "recipesCooked": 12,
    "streak": 7,
    "badges": ["first_save", "five_recipes"]
  },
  "social": {
    "followers": 150,
    "following": 75,
    "bio": "Food lover and home cook",
    "visibility": "public"
  },
  "referrals": {
    "code": "ABC123",
    "referredCount": 3
  }
}
```

### recipes/{recipeId}
```json
{
  "title": "Chocolate Chip Cookies",
  "creatorHandle": "baker123",
  "sourceLink": "https://example.com/recipe",
  "lang": "en",
  "text": {
    "original": "Delicious chocolate chip cookies...",
    "ro": "Fursecuri delicioase cu ciocolată..."
  },
  "media": {
    "coverImageUrl": "https://...",
    "stepPhotos": ["https://...", "https://..."]
  },
  "ingredients": [
    {"name": "flour", "qty": 2, "unit": "cups"},
    {"name": "sugar", "qty": 1, "unit": "cup"}
  ],
  "ingredients_ro": [
    {"name": "făină", "qty": 2, "unit": "căni"},
    {"name": "zahăr", "qty": 1, "unit": "cană"}
  ],
  "steps": [
    {"index": 1, "text": "Mix dry ingredients", "durationSec": 300}
  ],
  "steps_ro": [
    {"index": 1, "text": "Amestecă ingredientele uscate", "durationSec": 300}
  ],
  "tags": ["dessert", "cookies", "baking"],
  "likes": 45,
  "saves": 23,
  "createdByUid": "user123",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### user_recipes/{uid}/saved/{recipeId}
```json
{
  "title": "Chocolate Chip Cookies",
  "creatorHandle": "baker123",
  "coverImageUrl": "https://...",
  "savedAt": "2024-01-01T00:00:00Z"
}
```

### shopping_lists/{uid}/items/{itemId}
```json
{
  "recipeId": "recipe123",
  "name": "flour",
  "qty": 2,
  "unit": "cups",
  "checked": false,
  "category": "pantry",
  "addedAt": "2024-01-01T00:00:00Z"
}
```

### planner/{uid}/weeks/{yyyy-ww}/days/{isoDate}/slots/{slotId}
```json
{
  "meal": "breakfast",
  "recipeId": "recipe123",
  "note": "Oatmeal with berries",
  "date": "2024-01-01T00:00:00Z"
}
```

### activities/{uid}/events/{eventId}
```json
{
  "type": "saved",
  "recipeId": "recipe123",
  "ts": "2024-01-01T00:00:00Z",
  "metadata": {"source": "web"}
}
```

### social/posts/{postId}
```json
{
  "uid": "user123",
  "recipeId": "recipe123",
  "text": "Just made amazing cookies!",
  "imageUrl": "https://...",
  "likes": 12,
  "comments": 3,
  "visibility": "public",
  "ts": "2024-01-01T00:00:00Z"
}
```

### social/follows/{uid}/following/{otherUid}
```json
{
  "ts": "2024-01-01T00:00:00Z"
}
```

## Security Rules

The Firestore security rules ensure:
- **Public read access** to recipes collection
- **User-specific access** to personal data (shopping lists, planner, activities)
- **Privacy controls** for social posts based on visibility settings
- **Rate limiting** for likes/comments via Cloud Functions

## Offline-First Architecture

### Hive Caching
- **recipes_cache**: Last 50 canonical recipes
- **shopping_cache**: User's shopping list items
- **user_cache**: User profile data
- **planner_cache**: Meal planning entries

### Offline Operations
- All operations work offline and sync when online
- Pending operations queue for sync
- Merge strategies for conflict resolution
- Automatic cache management with size limits

## Recipe De-duplication

### ID Generation
```dart
String generateRecipeId(String sourceLink) {
  final normalized = _normalizeUrl(sourceLink);
  final bytes = utf8.encode(normalized);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

### De-duplication Process
1. Normalize source URL (remove protocol, www, trailing slash)
2. Generate SHA256 hash as recipe ID
3. Check if recipe exists with same ID
4. If exists, return existing recipe
5. If not, create new recipe and save to canonical collection
6. Save lightweight copy to user's saved collection

## Translation Support

### Language Detection
- Automatic language detection using Google ML Kit
- Support for Romanian (primary) and English (fallback)

### Translation Fields
- **text**: `{ original, ro, en }`
- **ingredients_ro**: Romanian ingredient translations
- **steps_ro**: Romanian step translations

### Client-Side Translation
- On-device translation using Google ML Kit
- Cached translations for offline use
- Fallback to original language if translation unavailable

## Constants & Enums

### Ingredient Categories
```dart
class IngredientCategory {
  static const String produce = 'produce';
  static const String dairy = 'dairy';
  static const String meat = 'meat';
  static const String pantry = 'pantry';
  static const String spices = 'spices';
  static const String bakery = 'bakery';
  static const String beverages = 'beverages';
  static const String other = 'other';
}
```

### Badges
```dart
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
}
```

## Usage Examples

### Initialize Services
```dart
await DataService.instance.initialize();
```

### Create Recipe
```dart
final recipe = await DataService.instance.createRecipe(
  sourceLink: 'https://example.com/recipe',
  title: 'Chocolate Chip Cookies',
  creatorHandle: 'baker123',
  lang: 'en',
  text: RecipeText(
    original: 'Delicious cookies...',
    ro: 'Fursecuri delicioase...',
  ),
  media: RecipeMedia(coverImageUrl: 'https://...'),
  ingredients: [Ingredient(name: 'flour', quantity: 2, unit: 'cups')],
  steps: [StepItem(index: 1, text: 'Mix ingredients')],
);
```

### Add to Shopping List
```dart
final item = ShoppingItem.create(
  name: 'flour',
  quantity: 2,
  unit: 'cups',
  category: IngredientCategory.pantry,
);
await DataService.instance.addShoppingItem(item);
```

### Plan Meal
```dart
final entry = PlannerEntry.create(
  meal: MealType.breakfast,
  recipeId: recipe.id,
  date: DateTime.now().add(Duration(days: 1)),
);
await DataService.instance.savePlannerEntry(entry);
```

## Indexes

The system includes optimized Firestore indexes for:
- Recipe search by tags, creator, title
- Shopping list filtering by recipe and checked status
- Social posts by timestamp and visibility
- Activities by type and timestamp
- Planner entries by date and meal type

## Performance Considerations

- **Cache limits**: Maximum 50 cached recipes
- **Batch operations**: Group related operations
- **Lazy loading**: Load data as needed
- **Pagination**: Limit query results
- **Offline sync**: Process pending operations in background

## Testing

The system includes comprehensive examples in `lib/examples/usage_example.dart` demonstrating:
- User management
- Recipe creation and search
- Shopping list operations
- Meal planning
- Social features
- Offline functionality
- Translation support
- Badge system

This architecture provides a robust, scalable foundation for the TastyLink app with excellent offline support and translation capabilities.
