import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../core/constants.dart';
import 'offline_service.dart';

class RecipeDedupService {
  static RecipeDedupService? _instance;
  static RecipeDedupService get instance => _instance ??= RecipeDedupService._();
  
  RecipeDedupService._();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OfflineService _offlineService = OfflineService.instance;
  
  /// Check if a recipe with the same source link already exists
  /// Returns the existing recipe if found, null otherwise
  Future<Recipe?> checkForDuplicate(String sourceLink) async {
    final recipeId = Constants.generateRecipeId(sourceLink);
    return await _offlineService.getRecipe(recipeId);
  }
  
  /// Create a new recipe or return existing one if duplicate
  /// Returns the recipe (either existing or newly created)
  Future<Recipe> createOrGetRecipe({
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
    // Check for existing recipe
    final existingRecipe = await checkForDuplicate(sourceLink);
    if (existingRecipe != null) {
      return existingRecipe;
    }
    
    // Create new recipe
    final recipe = Recipe.createFromSource(
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
    
    // Save the recipe
    await _offlineService.saveRecipe(recipe);
    
    return recipe;
  }
  
  /// Save a recipe to user's saved collection
  /// This creates a lightweight copy in user_recipes/{uid}/saved/{recipeId}
  Future<void> saveRecipeToUser(String uid, Recipe recipe) async {
    final userRecipe = UserRecipe.create(
      id: recipe.id,
      title: recipe.title,
      creatorHandle: recipe.creatorHandle,
      coverImageUrl: recipe.media.coverImageUrl,
    );
    
    if (_offlineService.isOnline) {
      try {
        await _firestore
            .collection('user_recipes')
            .doc(uid)
            .collection('saved')
            .doc(recipe.id)
            .set(userRecipe.toMap());
        return;
      } catch (e) {
        print('Error saving recipe to user online: $e');
      }
    }
    
    // For offline, we'll handle this in the pending operations
    _offlineService.addPendingOperation('saveUserRecipe', {
      'uid': uid,
      'userRecipe': userRecipe.toMap(),
    });
  }
  
  /// Remove a recipe from user's saved collection
  Future<void> removeRecipeFromUser(String uid, String recipeId) async {
    if (_offlineService.isOnline) {
      try {
        await _firestore
            .collection('user_recipes')
            .doc(uid)
            .collection('saved')
            .doc(recipeId)
            .delete();
        return;
      } catch (e) {
        print('Error removing recipe from user online: $e');
      }
    }
    
    // For offline, we'll handle this in the pending operations
    _offlineService.addPendingOperation('removeUserRecipe', {
      'uid': uid,
      'recipeId': recipeId,
    });
  }
  
  /// Get user's saved recipes
  Future<List<UserRecipe>> getUserSavedRecipes(String uid) async {
    if (_offlineService.isOnline) {
      try {
        final snapshot = await _firestore
            .collection('user_recipes')
            .doc(uid)
            .collection('saved')
            .orderBy('savedAt', descending: true)
            .get();
        
        return snapshot.docs.map((doc) => UserRecipe.fromFirestore(doc)).toList();
      } catch (e) {
        print('Error fetching user saved recipes online: $e');
      }
    }
    
    // For offline, we could implement local caching of user recipes
    // For now, return empty list
    return [];
  }
  
  /// Update recipe statistics (likes, saves)
  Future<void> updateRecipeStats(String recipeId, {
    int? likesDelta,
    int? savesDelta,
  }) async {
    if (_offlineService.isOnline) {
      try {
        final docRef = _firestore.collection('recipes').doc(recipeId);
        
        await _firestore.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (snapshot.exists) {
            final data = snapshot.data()!;
            final currentLikes = data['likes'] ?? 0;
            final currentSaves = data['saves'] ?? 0;
            
            final updates = <String, dynamic>{
              'updatedAt': FieldValue.serverTimestamp(),
            };
            
            if (likesDelta != null) {
              updates['likes'] = currentLikes + likesDelta;
            }
            
            if (savesDelta != null) {
              updates['saves'] = currentSaves + savesDelta;
            }
            
            transaction.update(docRef, updates);
          }
        });
        return;
      } catch (e) {
        print('Error updating recipe stats online: $e');
      }
    }
    
    // For offline, we'll handle this in the pending operations
    _offlineService.addPendingOperation('updateRecipeStats', {
      'recipeId': recipeId,
      'likesDelta': likesDelta,
      'savesDelta': savesDelta,
    });
  }
  
  /// Like a recipe
  Future<void> likeRecipe(String recipeId, String uid) async {
    await updateRecipeStats(recipeId, likesDelta: 1);
    
    // Also track the like in a separate collection for analytics
    if (_offlineService.isOnline) {
      try {
        await _firestore
            .collection('social')
            .doc('posts')
            .collection(recipeId)
            .doc('likes')
            .collection('users')
            .doc(uid)
            .set({
          'uid': uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error tracking like online: $e');
      }
    }
  }
  
  /// Unlike a recipe
  Future<void> unlikeRecipe(String recipeId, String uid) async {
    await updateRecipeStats(recipeId, likesDelta: -1);
    
    if (_offlineService.isOnline) {
      try {
        await _firestore
            .collection('social')
            .doc('posts')
            .collection(recipeId)
            .doc('likes')
            .collection('users')
            .doc(uid)
            .delete();
      } catch (e) {
        print('Error removing like online: $e');
      }
    }
  }
  
  /// Check if user has liked a recipe
  Future<bool> hasUserLikedRecipe(String recipeId, String uid) async {
    if (_offlineService.isOnline) {
      try {
        final doc = await _firestore
            .collection('social')
            .doc('posts')
            .collection(recipeId)
            .doc('likes')
            .collection('users')
            .doc(uid)
            .get();
        
        return doc.exists;
      } catch (e) {
        print('Error checking like status online: $e');
      }
    }
    
    // For offline, we could implement local caching
    return false;
  }
  
  /// Get recipe statistics
  Future<Map<String, int>> getRecipeStats(String recipeId) async {
    final recipe = await _offlineService.getRecipe(recipeId);
    if (recipe != null) {
      return {
        'likes': recipe.likes,
        'saves': recipe.saves,
      };
    }
    
    return {'likes': 0, 'saves': 0};
  }
  
  /// Search for similar recipes by title or ingredients
  Future<List<Recipe>> findSimilarRecipes(Recipe recipe, {int limit = 5}) async {
    final results = await _offlineService.searchRecipes(
      query: recipe.title.split(' ').first, // Use first word of title
      limit: limit * 2, // Get more results to filter
    );
    
    // Filter out the original recipe and sort by similarity
    final similar = results
        .where((r) => r.id != recipe.id)
        .take(limit)
        .toList();
    
    return similar;
  }
  
  /// Merge duplicate recipes (admin function)
  Future<void> mergeDuplicateRecipes(String primaryRecipeId, String duplicateRecipeId) async {
    if (!_offlineService.isOnline) {
      throw Exception('Recipe merging requires online connection');
    }
    
    try {
      await _firestore.runTransaction((transaction) async {
        // Get both recipes
        final primaryDoc = await transaction.get(
          _firestore.collection('recipes').doc(primaryRecipeId)
        );
        final duplicateDoc = await transaction.get(
          _firestore.collection('recipes').doc(duplicateRecipeId)
        );
        
        if (!primaryDoc.exists || !duplicateDoc.exists) {
          throw Exception('One or both recipes not found');
        }
        
        final primaryRecipe = Recipe.fromFirestore(primaryDoc);
        final duplicateRecipe = Recipe.fromFirestore(duplicateDoc);
        
        // Merge the recipes (combine likes, saves, etc.)
        final mergedRecipe = primaryRecipe.copyWith(
          likes: primaryRecipe.likes + duplicateRecipe.likes,
          saves: primaryRecipe.saves + duplicateRecipe.saves,
          updatedAt: DateTime.now(),
        );
        
        // Update primary recipe
        transaction.set(
          _firestore.collection('recipes').doc(primaryRecipeId),
          mergedRecipe.toMap()
        );
        
        // Delete duplicate recipe
        transaction.delete(
          _firestore.collection('recipes').doc(duplicateRecipeId)
        );
      });
    } catch (e) {
      print('Error merging duplicate recipes: $e');
      rethrow;
    }
  }
}
