import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import 'cache_service.dart';
import 'offline_service.dart';
import 'recipe_dedup_service.dart';

class DataService {
  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._();
  
  DataService._();
  
  final CacheService _cacheService = CacheService.instance;
  final OfflineService _offlineService = OfflineService.instance;
  final RecipeDedupService _dedupService = RecipeDedupService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _initialized = false;
  
  Future<void> initialize() async {
    if (_initialized) return;
    
    await _cacheService.initialize();
    await _offlineService.initialize();
    
    _initialized = true;
  }
  
  // User Management
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return await _offlineService.getUserProfile(user.uid);
  }
  
  Future<UserProfile> createUserProfile({
    required String uid,
    required String displayName,
    String? photoURL,
    String? referralCode,
  }) async {
    final profile = UserProfile.create(
      uid: uid,
      displayName: displayName,
      photoURL: photoURL,
      referralCode: referralCode,
    );
    
    await _offlineService.saveUserProfile(profile);
    return profile;
  }
  
  Future<void> updateUserProfile(UserProfile profile) async {
    await _offlineService.saveUserProfile(profile);
  }
  
  // Recipe Management
  Future<Recipe?> getRecipe(String recipeId) async {
    return await _offlineService.getRecipe(recipeId);
  }
  
  Future<List<Recipe>> searchRecipes({
    String? query,
    List<String>? tags,
    String? creatorHandle,
    int limit = 20,
  }) async {
    return await _offlineService.searchRecipes(
      query: query,
      tags: tags,
      creatorHandle: creatorHandle,
      limit: limit,
    );
  }
  
  Future<Recipe> createRecipe({
    required String sourceLink,
    required String title,
    required String creatorHandle,
    required String lang,
    required RecipeText text,
    required RecipeMedia media,
    required List<Ingredient> ingredients,
    required List<StepItem> steps,
    List<String> tags = const [],
    String? createdByUid,
  }) async {
    return await _dedupService.createOrGetRecipe(
      sourceLink: sourceLink,
      title: title,
      creatorHandle: creatorHandle,
      lang: lang,
      text: text,
      media: media,
      ingredients: ingredients,
      steps: steps,
      tags: tags,
      createdByUid: createdByUid,
    );
  }
  
  Future<void> saveRecipeToUser(String uid, Recipe recipe) async {
    await _dedupService.saveRecipeToUser(uid, recipe);
    await _dedupService.updateRecipeStats(recipe.id, savesDelta: 1);
  }
  
  Future<void> removeRecipeFromUser(String uid, String recipeId) async {
    await _dedupService.removeRecipeFromUser(uid, recipeId);
    await _dedupService.updateRecipeStats(recipeId, savesDelta: -1);
  }
  
  Future<List<UserRecipe>> getUserSavedRecipes(String uid) async {
    return await _dedupService.getUserSavedRecipes(uid);
  }
  
  Future<void> likeRecipe(String recipeId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _dedupService.likeRecipe(recipeId, user.uid);
    }
  }
  
  Future<void> unlikeRecipe(String recipeId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _dedupService.unlikeRecipe(recipeId, user.uid);
    }
  }
  
  Future<bool> hasUserLikedRecipe(String recipeId) async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _dedupService.hasUserLikedRecipe(recipeId, user.uid);
    }
    return false;
  }
  
  // Shopping List Management
  Future<List<ShoppingItem>> getShoppingItems() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    return await _offlineService.getShoppingItems(user.uid);
  }
  
  Future<void> addShoppingItem(ShoppingItem item) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _offlineService.saveShoppingItem(user.uid, item);
  }
  
  Future<void> updateShoppingItem(ShoppingItem item) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _offlineService.saveShoppingItem(user.uid, item);
  }
  
  Future<void> deleteShoppingItem(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _offlineService.deleteShoppingItem(user.uid, itemId);
  }
  
  Future<void> addIngredientsToShoppingList(List<Ingredient> ingredients) async {
    for (final ingredient in ingredients) {
      final shoppingItem = ShoppingItem.create(
        name: ingredient.name,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        category: ingredient.category,
      );
      
      await addShoppingItem(shoppingItem);
    }
  }
  
  // Meal Planning
  Future<List<PlannerEntry>> getPlannerEntries(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    if (_offlineService.isOnline) {
      try {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        final snapshot = await _firestore
            .collection('planner')
            .doc(user.uid)
            .collection('days')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('date', isLessThan: Timestamp.fromDate(endOfDay))
            .get();
        
        return snapshot.docs.map((doc) => PlannerEntry.fromFirestore(doc)).toList();
      } catch (e) {
        print('Error fetching planner entries online: $e');
      }
    }
    
    // Fallback to cache
    final cachedEntries = await _cacheService.getCachedPlannerEntries();
    return cachedEntries.where((entry) => 
        entry.date.year == date.year &&
        entry.date.month == date.month &&
        entry.date.day == date.day).toList();
  }
  
  Future<void> savePlannerEntry(PlannerEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    if (_offlineService.isOnline) {
      try {
        await _firestore
            .collection('planner')
            .doc(user.uid)
            .collection('days')
            .doc(entry.id)
            .set(entry.toMap());
        await _cacheService.cachePlannerEntry(entry);
        return;
      } catch (e) {
        print('Error saving planner entry online: $e');
      }
    }
    
    // Cache for offline
    await _cacheService.cachePlannerEntry(entry);
  }
  
  Future<void> deletePlannerEntry(String entryId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    if (_offlineService.isOnline) {
      try {
        await _firestore
            .collection('planner')
            .doc(user.uid)
            .collection('days')
            .doc(entryId)
            .delete();
        await _cacheService.removeCachedPlannerEntry(entryId);
        return;
      } catch (e) {
        print('Error deleting planner entry online: $e');
      }
    }
    
    // Remove from cache
    await _cacheService.removeCachedPlannerEntry(entryId);
  }
  
  // Activities
  Future<List<Activity>> getUserActivities({int limit = 50}) async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    if (_offlineService.isOnline) {
      try {
        final snapshot = await _firestore
            .collection('activities')
            .doc(user.uid)
            .collection('events')
            .orderBy('ts', descending: true)
            .limit(limit)
            .get();
        
        return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
      } catch (e) {
        print('Error fetching user activities online: $e');
      }
    }
    
    // For offline, we could implement local caching
    return [];
  }
  
  Future<void> logActivity(Activity activity) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    if (_offlineService.isOnline) {
      try {
        await _firestore
            .collection('activities')
            .doc(user.uid)
            .collection('events')
            .doc(activity.id)
            .set(activity.toMap());
        return;
      } catch (e) {
        print('Error logging activity online: $e');
      }
    }
    
    // For offline, we could implement local caching
  }
  
  // Social Features
  Future<List<SocialPost>> getSocialFeed({int limit = 20}) async {
    if (_offlineService.isOnline) {
      try {
        final snapshot = await _firestore
            .collection('social')
            .doc('posts')
            .collection('posts')
            .orderBy('ts', descending: true)
            .limit(limit)
            .get();
        
        return snapshot.docs.map((doc) => SocialPost.fromFirestore(doc)).toList();
      } catch (e) {
        print('Error fetching social feed online: $e');
      }
    }
    
    // For offline, we could implement local caching
    return [];
  }
  
  Future<void> createSocialPost(SocialPost post) async {
    if (_offlineService.isOnline) {
      try {
        await _firestore
            .collection('social')
            .doc('posts')
            .collection('posts')
            .doc(post.id)
            .set(post.toMap());
        return;
      } catch (e) {
        print('Error creating social post online: $e');
      }
    }
    
    // For offline, we could implement local caching
  }
  
  // Utility Methods
  bool get isOnline => _offlineService.isOnline;
  int get pendingOperationsCount => _offlineService.pendingOperationsCount;
  Map<String, int> get cacheStats => _cacheService.getCacheStats();
  
  Future<void> clearAllCaches() async {
    await _cacheService.clearAllCaches();
  }
  
  void dispose() {
    _cacheService.dispose();
  }
}
