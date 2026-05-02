// lib/data/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Current signed-in user
  User? get currentUser => _auth.currentUser;

  // Auth state listener
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user role from Firestore for role-based navigation
  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  // Register new user with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Login and return Firebase UserCredential
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // Login and return error message as String?
  // null means login success.
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      const errors = {
        'user-not-found': 'No account found for this email.',
        'wrong-password': 'Incorrect password.',
        'invalid-email': 'Please enter a valid email.',
        'invalid-credential': 'Invalid email or password.',
        'user-disabled': 'This account has been disabled.',
        'network-request-failed':
            'No internet connection. Please check your network and try again.',
      };

      return errors[e.code] ?? 'Login failed. Please try again.';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Logout current user
  Future<void> logout() async {
    await _auth.signOut();
  }
}