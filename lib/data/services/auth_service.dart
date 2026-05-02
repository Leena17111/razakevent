import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      const errors = {
        'user-not-found': 'No account found for this email.',
        'wrong-password': 'Incorrect password.',
        'invalid-email': 'Please enter a valid email.',
        'invalid-credential': 'Invalid email or password.',
        'user-disabled': 'This account has been disabled.',
      };
      return errors[e.code] ?? 'Login failed. Please try again.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}