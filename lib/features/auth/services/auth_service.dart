import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Firebase Auth
  Future<UserModel?> signInWithFirebase() async {
    try {
      // Configure provider
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');

      // Sign in based on platform
      final UserCredential userCredential = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);

      final User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'sign_in_failed',
          message: 'Failed to sign in. Please try again.',
        );
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // Create new user in Firestore
        final now = DateTime.now();
        final newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          profilePhotoUrl: user.photoURL,
          createdAt: now,
          updatedAt: now,
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e, stack) {
      print('FIREBASE AUTH ERROR: $e');
      print(stack);
      rethrow;
    } catch (e, stack) {
      print('GENERIC ERROR: $e');
      print(stack);
      rethrow;
    }
  }

  // Handle Firebase Auth errors
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      case 'invalid-credential':
        return 'The sign-in credential is invalid. Please try again.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled for this project.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Invalid password.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      default:
        return e.message ?? 'An error occurred during sign in. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw 'Failed to update profile. Please try again.';
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user profile. Please try again.';
    }
  }
} 