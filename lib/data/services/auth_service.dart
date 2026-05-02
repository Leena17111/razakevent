// lib/data/services/auth_service.dart
//
// Thin wrapper around FirebaseAuth.
// Responsibilities:
//   - Register a new user with email + password.
//   - Log in an existing user.
//   - Send a password-reset email.
//   - Log out the current user.
//   - Expose the currently signed-in Firebase user.
//
// This service does NOT:
//   - Write anything to Firestore.
//   - Validate form fields.
//   - Handle UI navigation.
//   - Catch FirebaseAuthExceptions — those bubble up to the repository or
//     controller layer so they can decide how to present errors to the user.

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // ── Dependencies ───────────────────────────────────────────────────────────
  // Accept a [FirebaseAuth] instance so this class is easy to unit-test by
  // injecting a mock.  Defaults to the real singleton in production.
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  // ── Current user ───────────────────────────────────────────────────────────
  /// Returns the currently signed-in Firebase [User], or null if no user is
  /// signed in.
  User? get currentUser => _auth.currentUser;

  /// Stream that emits every time the auth state changes (sign-in / sign-out).
  /// Useful for listening in a StreamBuilder or AuthController.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Register ───────────────────────────────────────────────────────────────
  /// Creates a new Firebase Auth account with [email] and [password].
  ///
  /// Returns a [UserCredential] whose `.user` property contains the newly
  /// created [User] (including their UID).
  ///
  /// Throws [FirebaseAuthException] on failure (e.g. email already in use,
  /// weak password).  Let the caller decide how to handle it.
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential;
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  /// Signs in an existing user with [email] and [password].
  ///
  /// Returns a [UserCredential] on success.
  /// Throws [FirebaseAuthException] on failure (e.g. wrong password, user not
  /// found).
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential;
  }

  // ── Password reset ─────────────────────────────────────────────────────────
  /// Sends a password-reset email to [email].
  ///
  /// Throws [FirebaseAuthException] if the address is not registered or the
  /// request fails.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  /// Signs out the currently authenticated user.
  Future<void> logout() async {
    await _auth.signOut();
  }
}