import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../core/constants.dart';

class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._();
  
  late Box<Recipe> _recipesCache;
  late Box<ShoppingItem> _shoppingCache;
  late Box<UserProfile> _userCache;
  late Box<PlannerEntry> _plannerCache;
  
  bool _initialized = false;
  
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Register Hive adapters
    Hive.registerAdapter(IngredientAdapter());
    Hive.registerAdapter(StepItemAdapter());
    Hive.registerAdapter(RecipeTextAdapter());
    Hive.registerAdapter(RecipeMediaAdapter());
    Hive.registerAdapter(RecipeAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(UserStatsAdapter());
    Hive.registerAdapter(UserSocialAdapter());
    Hive.registerAdapter(UserReferralsAdapter());
    Hive.registerAdapter(ShoppingItemAdapter());
    Hive.registerAdapter(PlannerEntryAdapter());
    Hive.registerAdapter(ActivityAdapter());
    Hive.registerAdapter(SocialPostAdapter());
    Hive.registerAdapter(UserRecipeAdapter());
    
    // Open boxes
    _recipesCache = await Hive.openBox<Recipe>(Constants.recipesCacheBox);
    _shoppingCache = await Hive.openBox<ShoppingItem>(Constants.shoppingCacheBox);
    _userCache = await Hive.openBox<UserProfile>(Constants.userBox);
    _plannerCache = await Hive.openBox<PlannerEntry>('planner_cache');
    
    _initialized = true;
  }
  
  // Recipe caching
  Future<void> cacheRecipe(Recipe recipe) async {
    await _recipesCache.put(recipe.id, recipe);
    await _enforceCacheLimit();
  }
  
  Future<Recipe?> getCachedRecipe(String recipeId) async {
    return _recipesCache.get(recipeId);
  }
  
  Future<List<Recipe>> getCachedRecipes() async {
    return _recipesCache.values.toList();
  }
  
  Future<void> removeCachedRecipe(String recipeId) async {
    await _recipesCache.delete(recipeId);
  }
  
  Future<void> _enforceCacheLimit() async {
    if (_recipesCache.length > Constants.maxCachedRecipes) {
      // Remove oldest recipes (by creation date)
      final recipes = _recipesCache.values.toList();
      recipes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      final toRemove = recipes.take(_recipesCache.length - Constants.maxCachedRecipes);
      for (final recipe in toRemove) {
        await _recipesCache.delete(recipe.id);
      }
    }
  }
  
  // Shopping list caching
  Future<void> cacheShoppingItem(ShoppingItem item) async {
    await _shoppingCache.put(item.id, item);
  }
  
  Future<List<ShoppingItem>> getCachedShoppingItems() async {
    return _shoppingCache.values.toList();
  }
  
  Future<void> removeCachedShoppingItem(String itemId) async {
    await _shoppingCache.delete(itemId);
  }
  
  Future<void> clearShoppingCache() async {
    await _shoppingCache.clear();
  }
  
  // User profile caching
  Future<void> cacheUserProfile(UserProfile profile) async {
    await _userCache.put(profile.uid, profile);
  }
  
  Future<UserProfile?> getCachedUserProfile(String uid) async {
    return _userCache.get(uid);
  }
  
  Future<void> removeCachedUserProfile(String uid) async {
    await _userCache.delete(uid);
  }
  
  // Planner caching
  Future<void> cachePlannerEntry(PlannerEntry entry) async {
    await _plannerCache.put(entry.id, entry);
  }
  
  Future<List<PlannerEntry>> getCachedPlannerEntries() async {
    return _plannerCache.values.toList();
  }
  
  Future<void> removeCachedPlannerEntry(String entryId) async {
    await _plannerCache.delete(entryId);
  }
  
  // Merge strategy for shopping list when reconnecting
  Future<List<ShoppingItem>> mergeShoppingLists(
    List<ShoppingItem> localItems,
    List<ShoppingItem> remoteItems,
  ) async {
    final Map<String, ShoppingItem> merged = {};
    
    // Add local items first
    for (final item in localItems) {
      merged[item.id] = item;
    }
    
    // Merge with remote items
    for (final remoteItem in remoteItems) {
      final localItem = merged[remoteItem.id];
      if (localItem != null) {
        // Merge logic: prefer remote data but keep local checked state if more recent
        final mergedItem = localItem.checked != remoteItem.checked
            ? (localItem.createdAt.isAfter(remoteItem.createdAt) ? localItem : remoteItem)
            : remoteItem;
        merged[remoteItem.id] = mergedItem;
      } else {
        merged[remoteItem.id] = remoteItem;
      }
    }
    
    return merged.values.toList();
  }
  
  // Clear all caches
  Future<void> clearAllCaches() async {
    await _recipesCache.clear();
    await _shoppingCache.clear();
    await _userCache.clear();
    await _plannerCache.clear();
  }
  
  // Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'recipes': _recipesCache.length,
      'shopping': _shoppingCache.length,
      'users': _userCache.length,
      'planner': _plannerCache.length,
    };
  }
  
  void dispose() {
    _recipesCache.close();
    _shoppingCache.close();
    _userCache.close();
    _plannerCache.close();
    _initialized = false;
  }
}
