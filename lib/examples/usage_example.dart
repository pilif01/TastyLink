import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../core/constants.dart';

/// Example usage of the TastyLink data models and services
class UsageExample {
  final DataService _dataService = DataService.instance;
  
  Future<void> initializeApp() async {
    // Initialize the data service (this sets up caching and offline support)
    await _dataService.initialize();
  }
  
  Future<void> createUserExample() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    // Create a new user profile
    final profile = await _dataService.createUserProfile(
      uid: user.uid,
      displayName: user.displayName ?? 'User',
      photoURL: user.photoURL,
    );
    
    print('Created user profile: ${profile.displayName}');
  }
  
  Future<void> createRecipeExample() async {
    // Create a recipe with translation support
    final recipe = await _dataService.createRecipe(
      sourceLink: 'https://example.com/recipe',
      title: 'Chocolate Chip Cookies',
      creatorHandle: 'baker123',
      lang: 'en',
      text: RecipeText(
        original: 'Delicious chocolate chip cookies recipe',
        ro: 'Rețetă delicioasă de fursecuri cu ciocolată',
      ),
      media: RecipeMedia(
        coverImageUrl: 'https://example.com/cookie-image.jpg',
        stepPhotos: [
          'https://example.com/step1.jpg',
          'https://example.com/step2.jpg',
        ],
      ),
      ingredients: [
        Ingredient(name: 'flour', quantity: 2, unit: 'cups'),
        Ingredient(name: 'sugar', quantity: 1, unit: 'cup'),
        Ingredient(name: 'chocolate chips', quantity: 1, unit: 'cup'),
      ],
      steps: [
        StepItem(index: 1, text: 'Mix dry ingredients', durationSec: 300),
        StepItem(index: 2, text: 'Add wet ingredients', durationSec: 180),
        StepItem(index: 3, text: 'Bake for 12 minutes', durationSec: 720),
      ],
      tags: ['dessert', 'cookies', 'baking'],
    );
    
    print('Created recipe: ${recipe.title}');
    
    // Save to user's collection
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _dataService.saveRecipeToUser(user.uid, recipe);
      print('Saved recipe to user collection');
    }
  }
  
  Future<void> shoppingListExample() async {
    // Add items to shopping list
    final items = [
      ShoppingItem.create(
        name: 'flour',
        quantity: 2,
        unit: 'cups',
        category: IngredientCategory.pantry,
      ),
      ShoppingItem.create(
        name: 'chocolate chips',
        quantity: 1,
        unit: 'cup',
        category: IngredientCategory.pantry,
      ),
      ShoppingItem.create(
        name: 'eggs',
        quantity: 3,
        unit: 'pieces',
        category: IngredientCategory.dairy,
      ),
    ];
    
    for (final item in items) {
      await _dataService.addShoppingItem(item);
    }
    
    // Get shopping list
    final shoppingList = await _dataService.getShoppingItems();
    print('Shopping list has ${shoppingList.length} items');
    
    // Mark item as checked
    if (shoppingList.isNotEmpty) {
      final checkedItem = shoppingList.first.copyWith(checked: true);
      await _dataService.updateShoppingItem(checkedItem);
      print('Marked ${checkedItem.name} as checked');
    }
  }
  
  Future<void> mealPlanningExample() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    
    // Create planner entries
    final entries = [
      PlannerEntry.create(
        meal: MealType.breakfast,
        note: 'Oatmeal with berries',
        date: tomorrow,
      ),
      PlannerEntry.create(
        meal: MealType.lunch,
        note: 'Salad with grilled chicken',
        date: tomorrow,
      ),
      PlannerEntry.create(
        meal: MealType.dinner,
        note: 'Pasta with marinara sauce',
        date: tomorrow,
      ),
    ];
    
    for (final entry in entries) {
      await _dataService.savePlannerEntry(entry);
    }
    
    // Get planner entries for tomorrow
    final plannerEntries = await _dataService.getPlannerEntries(tomorrow);
    print('Planned ${plannerEntries.length} meals for tomorrow');
  }
  
  Future<void> socialFeaturesExample() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    // Create a social post
    final post = SocialPost.create(
      uid: user.uid,
      text: 'Just made the most amazing chocolate chip cookies! 🍪',
      visibility: PostVisibility.public,
    );
    
    await _dataService.createSocialPost(post);
    print('Created social post');
    
    // Get social feed
    final feed = await _dataService.getSocialFeed();
    print('Social feed has ${feed.length} posts');
  }
  
  Future<void> offlineExample() async {
    // Check if app is online
    if (_dataService.isOnline) {
      print('App is online - data will sync to server');
    } else {
      print('App is offline - data will be cached locally');
    }
    
    // Check pending operations
    final pendingOps = _dataService.pendingOperationsCount;
    if (pendingOps > 0) {
      print('$pendingOps operations pending sync');
    }
    
    // Check cache statistics
    final cacheStats = _dataService.cacheStats;
    print('Cache stats: $cacheStats');
  }
  
  Future<void> searchExample() async {
    // Search for recipes
    final searchResults = await _dataService.searchRecipes(
      query: 'chocolate',
      tags: ['dessert'],
      limit: 10,
    );
    
    print('Found ${searchResults.length} chocolate dessert recipes');
    
    // Search by creator
    final creatorResults = await _dataService.searchRecipes(
      creatorHandle: 'baker123',
      limit: 5,
    );
    
    print('Found ${creatorResults.length} recipes by baker123');
  }
  
  Future<void> translationExample() async {
    // Get a recipe
    final recipes = await _dataService.searchRecipes(limit: 1);
    if (recipes.isEmpty) return;
    
    final recipe = recipes.first;
    
    // Get ingredients in Romanian
    final ingredientsRo = recipe.getIngredientsForLanguage('ro');
    print('Romanian ingredients: ${ingredientsRo.length}');
    
    // Get steps in Romanian
    final stepsRo = recipe.getStepsForLanguage('ro');
    print('Romanian steps: ${stepsRo.length}');
    
    // Get text in Romanian
    final textRo = recipe.getTextForLanguage('ro');
    print('Romanian text: $textRo');
  }
  
  Future<void> badgeSystemExample() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    // Get user profile
    final profile = await _dataService.getCurrentUserProfile();
    if (profile == null) return;
    
    // Check for badges
    final stats = profile.stats;
    print('User has ${stats.badges.length} badges');
    
    // Check specific badges
    if (stats.hasBadge(Badge.firstSave)) {
      print('User has first save badge!');
    }
    
    if (stats.hasBadge(Badge.recipes100)) {
      print('User has 100 recipes badge!');
    }
    
    // Update stats (this would typically be done by the app logic)
    final updatedStats = stats.copyWith(
      recipesSaved: stats.recipesSaved + 1,
    );
    
    final updatedProfile = profile.copyWith(stats: updatedStats);
    await _dataService.updateUserProfile(updatedProfile);
    print('Updated user stats');
  }
  
  Future<void> cleanupExample() async {
    // Clear all caches (useful for testing or when user logs out)
    await _dataService.clearAllCaches();
    print('Cleared all caches');
  }
}
