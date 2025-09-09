import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String recipesCollection = 'recipes';
  static const String usersCollection = 'users';
  static const String shoppingListsCollection = 'shopping_lists';
  static const String mealPlansCollection = 'meal_plans';

  // Recipe operations
  Future<String> saveRecipe(Map<String, dynamic> recipeData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final docRef = await _firestore
          .collection(recipesCollection)
          .add({
        ...recipeData,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user's recipe count
      await _firestore.collection(usersCollection).doc(user.uid).update({
        'recipeCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save recipe: $e');
    }
  }

  Future<void> updateRecipe(String recipeId, Map<String, dynamic> recipeData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection(recipesCollection)
          .doc(recipeId)
          .update({
        ...recipeData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection(recipesCollection).doc(recipeId).delete();

      // Update user's recipe count
      await _firestore.collection(usersCollection).doc(user.uid).update({
        'recipeCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  Future<DocumentSnapshot> getRecipe(String recipeId) async {
    try {
      return await _firestore.collection(recipesCollection).doc(recipeId).get();
    } catch (e) {
      throw Exception('Failed to get recipe: $e');
    }
  }

  Stream<QuerySnapshot> getUserRecipes() {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      return _firestore
          .collection(recipesCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      throw Exception('Failed to get user recipes: $e');
    }
  }

  // Shopping list operations
  Future<void> saveShoppingList(List<String> items) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection(shoppingListsCollection)
          .doc(user.uid)
          .set({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save shopping list: $e');
    }
  }

  Future<DocumentSnapshot> getShoppingList() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      return await _firestore
          .collection(shoppingListsCollection)
          .doc(user.uid)
          .get();
    } catch (e) {
      throw Exception('Failed to get shopping list: $e');
    }
  }

  // Meal plan operations
  Future<void> saveMealPlan(Map<String, dynamic> mealPlanData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection(mealPlansCollection)
          .doc(user.uid)
          .set({
        ...mealPlanData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save meal plan: $e');
    }
  }

  Future<DocumentSnapshot> getMealPlan() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      return await _firestore
          .collection(mealPlansCollection)
          .doc(user.uid)
          .get();
    } catch (e) {
      throw Exception('Failed to get meal plan: $e');
    }
  }

  // Search recipes
  Stream<QuerySnapshot> searchRecipes(String query) {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      return _firestore
          .collection(recipesCollection)
          .where('userId', isEqualTo: user.uid)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .snapshots();
    } catch (e) {
      throw Exception('Failed to search recipes: $e');
    }
  }
}
