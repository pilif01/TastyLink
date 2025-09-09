import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      await _createUserDocument(userCredential.user!);
      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _createUserDocument(userCredential.user!);
      return userCredential;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isPremium': false,
        'recipeCount': 0,
        'preferences': {
          'language': 'ro',
          'theme': 'system',
          'notifications': true,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Update user document
  Future<void> updateUserDocument(Map<String, dynamic> data) async {
    try {
      final user = currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update user document: $e');
    }
  }

  // Get user document
  Future<DocumentSnapshot> getUserDocument() async {
    try {
      final user = currentUser;
      if (user != null) {
        return await _firestore.collection('users').doc(user.uid).get();
      }
      throw Exception('No user signed in');
    } catch (e) {
      throw Exception('Failed to get user document: $e');
    }
  }

  // Delete user account
  Future<void> deleteUser() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user from Firebase Auth
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
