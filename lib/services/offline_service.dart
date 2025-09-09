import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'cache_service.dart';

class OfflineService {
  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();
  
  OfflineService._();
  
  final CacheService _cacheService = CacheService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isOnline = true;
  final List<Map<String, dynamic>> _pendingOperations = [];
  
  bool get isOnline => _isOnline;
  
  Future<void> initialize() async {
    // Enable Firestore offline persistence
    await _firestore.enablePersistence();
    
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    
    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    
    if (_isOnline) {
      await _processPendingOperations();
    }
  }
  
  void _onConnectivityChanged(ConnectivityResult result) {
    final wasOffline = !_isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (wasOffline && _isOnline) {
      _processPendingOperations();
    }
  }
  
  // Recipe operations with offline support
  Future<Recipe?> getRecipe(String recipeId) async {
    if (_isOnline) {
      try {
        final doc = await _firestore.collection('recipes').doc(recipeId).get();
        if (doc.exists) {
          final recipe = Recipe.fromFirestore(doc);
          await _cacheService.cacheRecipe(recipe);
          return recipe;
        }
      } catch (e) {
        debugPrint('Error fetching recipe online: $e');
      }
    }
    
    // Fallback to cache
    return await _cacheService.getCachedRecipe(recipeId);
  }
  
  Future<List<Recipe>> searchRecipes({
    String? query,
    List<String>? tags,
    String? creatorHandle,
    int limit = 20,
  }) async {
    if (_isOnline) {
      try {
        Query queryRef = _firestore.collection('recipes');
        
        if (tags != null && tags.isNotEmpty) {
          queryRef = queryRef.where('tags', arrayContainsAny: tags);
        }
        
        if (creatorHandle != null) {
          queryRef = queryRef.where('creatorHandle', isEqualTo: creatorHandle);
        }
        
        if (query != null && query.isNotEmpty) {
          queryRef = queryRef.where('title', isGreaterThanOrEqualTo: query)
              .where('title', isLessThan: query + '\uf8ff');
        }
        
        queryRef = queryRef.orderBy('createdAt', descending: true).limit(limit);
        
        final snapshot = await queryRef.get();
        final recipes = snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
        
        // Cache the results
        for (final recipe in recipes) {
          await _cacheService.cacheRecipe(recipe);
        }
        
        return recipes;
      } catch (e) {
        debugPrint('Error searching recipes online: $e');
      }
    }
    
    // Fallback to cached recipes with local filtering
    final cachedRecipes = await _cacheService.getCachedRecipes();
    var filtered = cachedRecipes;
    
    if (tags != null && tags.isNotEmpty) {
      filtered = filtered.where((recipe) => 
          recipe.tags.any((tag) => tags.contains(tag))).toList();
    }
    
    if (creatorHandle != null) {
      filtered = filtered.where((recipe) => 
          recipe.creatorHandle == creatorHandle).toList();
    }
    
    if (query != null && query.isNotEmpty) {
      filtered = filtered.where((recipe) => 
          recipe.title.toLowerCase().contains(query.toLowerCase())).toList();
    }
    
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.take(limit).toList();
  }
  
  Future<void> saveRecipe(Recipe recipe) async {
    if (_isOnline) {
      try {
        await _firestore.collection('recipes').doc(recipe.id).set(recipe.toMap());
        await _cacheService.cacheRecipe(recipe);
        return;
      } catch (e) {
        debugPrint('Error saving recipe online: $e');
      }
    }
    
    // Cache for offline
    await _cacheService.cacheRecipe(recipe);
    addPendingOperation('saveRecipe', recipe.toMap());
  }
  
  // Shopping list operations with offline support
  Future<List<ShoppingItem>> getShoppingItems(String userId) async {
    if (_isOnline) {
      try {
        final snapshot = await _firestore
            .collection('shopping_lists')
            .doc(userId)
            .collection('items')
            .get();
        
        final items = snapshot.docs.map((doc) => ShoppingItem.fromFirestore(doc)).toList();
        
        // Cache the results
        for (final item in items) {
          await _cacheService.cacheShoppingItem(item);
        }
        
        return items;
      } catch (e) {
        debugPrint('Error fetching shopping items online: $e');
      }
    }
    
    // Fallback to cache
    return await _cacheService.getCachedShoppingItems();
  }
  
  Future<void> saveShoppingItem(String userId, ShoppingItem item) async {
    if (_isOnline) {
      try {
        await _firestore
            .collection('shopping_lists')
            .doc(userId)
            .collection('items')
            .doc(item.id)
            .set(item.toMap());
        await _cacheService.cacheShoppingItem(item);
        return;
      } catch (e) {
        debugPrint('Error saving shopping item online: $e');
      }
    }
    
    // Cache for offline
    await _cacheService.cacheShoppingItem(item);
    addPendingOperation('saveShoppingItem', {
      'userId': userId,
      'item': item.toMap(),
    });
  }
  
  Future<void> deleteShoppingItem(String userId, String itemId) async {
    if (_isOnline) {
      try {
        await _firestore
            .collection('shopping_lists')
            .doc(userId)
            .collection('items')
            .doc(itemId)
            .delete();
        await _cacheService.removeCachedShoppingItem(itemId);
        return;
      } catch (e) {
        debugPrint('Error deleting shopping item online: $e');
      }
    }
    
    // Remove from cache
    await _cacheService.removeCachedShoppingItem(itemId);
    addPendingOperation('deleteShoppingItem', {
      'userId': userId,
      'itemId': itemId,
    });
  }
  
  // User profile operations
  Future<UserProfile?> getUserProfile(String uid) async {
    if (_isOnline) {
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          final profile = UserProfile.fromFirestore(doc);
          await _cacheService.cacheUserProfile(profile);
          return profile;
        }
      } catch (e) {
        debugPrint('Error fetching user profile online: $e');
      }
    }
    
    // Fallback to cache
    return await _cacheService.getCachedUserProfile(uid);
  }
  
  Future<void> saveUserProfile(UserProfile profile) async {
    if (_isOnline) {
      try {
        await _firestore.collection('users').doc(profile.uid).set(profile.toMap());
        await _cacheService.cacheUserProfile(profile);
        return;
      } catch (e) {
        debugPrint('Error saving user profile online: $e');
      }
    }
    
    // Cache for offline
    await _cacheService.cacheUserProfile(profile);
    addPendingOperation('saveUserProfile', profile.toMap());
  }
  
  // Process pending operations when coming back online
  Future<void> _processPendingOperations() async {
    if (_pendingOperations.isEmpty) return;
    
    debugPrint('Processing ${_pendingOperations.length} pending operations...');
    
    final operations = List<Map<String, dynamic>>.from(_pendingOperations);
    _pendingOperations.clear();
    
    for (final operation in operations) {
      try {
        await _executeOperation(operation);
      } catch (e) {
        debugPrint('Error processing pending operation: $e');
        // Re-add failed operations
        _pendingOperations.add(operation);
      }
    }
  }
  
  Future<void> _executeOperation(Map<String, dynamic> operation) async {
    final type = operation['type'] as String;
    
    switch (type) {
      case 'saveRecipe':
        final data = operation['data'] as Map<String, dynamic>;
        await _firestore.collection('recipes').doc(data['id']).set(data);
        break;
        
      case 'saveShoppingItem':
        final userId = operation['data']['userId'] as String;
        final item = operation['data']['item'] as Map<String, dynamic>;
        await _firestore
            .collection('shopping_lists')
            .doc(userId)
            .collection('items')
            .doc(item['id'])
            .set(item);
        break;
        
      case 'deleteShoppingItem':
        final userId = operation['data']['userId'] as String;
        final itemId = operation['data']['itemId'] as String;
        await _firestore
            .collection('shopping_lists')
            .doc(userId)
            .collection('items')
            .doc(itemId)
            .delete();
        break;
        
      case 'saveUserProfile':
        final data = operation['data'] as Map<String, dynamic>;
        await _firestore.collection('users').doc(data['uid']).set(data);
        break;
        
      case 'saveUserRecipe':
        final uid = operation['data']['uid'] as String;
        final userRecipe = operation['data']['userRecipe'] as Map<String, dynamic>;
        await _firestore
            .collection('user_recipes')
            .doc(uid)
            .collection('saved')
            .doc(userRecipe['id'])
            .set(userRecipe);
        break;
        
      case 'removeUserRecipe':
        final uid = operation['data']['uid'] as String;
        final recipeId = operation['data']['recipeId'] as String;
        await _firestore
            .collection('user_recipes')
            .doc(uid)
            .collection('saved')
            .doc(recipeId)
            .delete();
        break;
        
      case 'updateRecipeStats':
        final recipeId = operation['data']['recipeId'] as String;
        final likesDelta = operation['data']['likesDelta'] as int?;
        final savesDelta = operation['data']['savesDelta'] as int?;
        
        final docRef = _firestore.collection('recipes').doc(recipeId);
        final snapshot = await docRef.get();
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
          
          await docRef.update(updates);
        }
        break;
    }
  }
  
  void addPendingOperation(String type, Map<String, dynamic> data) {
    _pendingOperations.add({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // Get pending operations count
  int get pendingOperationsCount => _pendingOperations.length;
  
  // Clear pending operations
  void clearPendingOperations() {
    _pendingOperations.clear();
  }
}
