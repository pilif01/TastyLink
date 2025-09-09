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
    
    // Register Hive adapters only if not already registered
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(IngredientAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(StepItemAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(RecipeTextAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(RecipeMediaAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(RecipeAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(UserProfileAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(UserStatsAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(UserSocialAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(UserReferralsAdapter());
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(ShoppingItemAdapter());
    if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(PlannerEntryAdapter());
    if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(ActivityAdapter());
    if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(SocialPostAdapter());
    if (!Hive.isAdapterRegistered(13)) Hive.registerAdapter(UserRecipeAdapter());
    
    // Open boxes only if not already open
    if (!Hive.isBoxOpen(Constants.recipesCacheBox)) {
      _recipesCache = await Hive.openBox<Recipe>(Constants.recipesCacheBox);
    } else {
      _recipesCache = Hive.box<Recipe>(Constants.recipesCacheBox);
    }
    
    if (!Hive.isBoxOpen(Constants.shoppingCacheBox)) {
      _shoppingCache = await Hive.openBox<ShoppingItem>(Constants.shoppingCacheBox);
    } else {
      _shoppingCache = Hive.box<ShoppingItem>(Constants.shoppingCacheBox);
    }
    
    if (!Hive.isBoxOpen(Constants.userBox)) {
      _userCache = await Hive.openBox<UserProfile>(Constants.userBox);
    } else {
      _userCache = Hive.box<UserProfile>(Constants.userBox);
    }
    
    if (!Hive.isBoxOpen('planner_cache')) {
      _plannerCache = await Hive.openBox<PlannerEntry>('planner_cache');
    } else {
      _plannerCache = Hive.box<PlannerEntry>('planner_cache');
    }
    
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
