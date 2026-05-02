// lib/data/repository/auth_repository.dart
//
// Orchestrates the full registration flow:
//   1. Optionally validates the verification code (Organizer Head / Secretary).
//   2. Creates the Firebase Auth account via AuthService.
//   3. Writes the user profile to Firestore at users/{uid}.
//   4. Returns a UserModel on success.
//
// This class does NOT contain:
//   - UI code or navigation.
//   - Form-field validation (email format, password length, etc.) — that lives
//     in the controller / UI layer.
//   - Direct calls to FirebaseAuth — those go through AuthService.
 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for UserCredential
 
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/registration_code_service.dart';
 
class AuthRepository {
  // ── Dependencies ───────────────────────────────────────────────────────────
  final AuthService _authService;
  final RegistrationCodeService _codeService;
  final FirebaseFirestore _firestore;
 
  // Firestore collection where user profiles are stored.
  static const String _usersCollection = 'users';
 
  AuthRepository({
    AuthService? authService,
    RegistrationCodeService? registrationCodeService,
    FirebaseFirestore? firestore,
  })  : _authService = authService ?? AuthService(),
        _codeService = registrationCodeService ?? RegistrationCodeService(),
        _firestore = firestore ?? FirebaseFirestore.instance;
 
  // ── registerUser ───────────────────────────────────────────────────────────
  /// Full registration flow.  Returns a [UserModel] on success.
  ///
  /// Throws an [Exception] with a human-readable message on any failure so the
  /// controller layer can surface it to the user without knowing the internals.
  Future<UserModel> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String matricNumber,
    String? organizationType,
    String? verificationCode,
  }) async {
    // ── Step 1: Trim all text inputs ─────────────────────────────────────────
    final trimmedFullName = fullName.trim();
    final trimmedEmail = email.trim();
    final trimmedRole = role.trim();
    final trimmedPhone = phoneNumber.trim();
    final trimmedMatric = matricNumber.trim();
    final trimmedOrgType = organizationType?.trim();
    final trimmedCode = verificationCode?.trim();
 
    // ── Step 2 / 3 / 4: Role-specific verification code checks ──────────────
    if (trimmedRole == UserRole.organizerHead) {
      // Organizer Head must supply both organizationType and verificationCode.
      if (trimmedOrgType == null || trimmedOrgType.isEmpty) {
        throw Exception(
          'Please select an organization type (Exco or Club).',
        );
      }
      if (trimmedOrgType != OrgType.exco && trimmedOrgType != OrgType.club) {
        throw Exception(
          'Organization type must be either Exco or Club.',
        );
      }
      if (trimmedCode == null || trimmedCode.isEmpty) {
        throw Exception(
          'A verification code is required for Organizer Head registration.',
        );
      }
 
      // ── Step 5: Validate code against Firestore ──────────────────────────
      final isValid = await _codeService.isValidCode(
        code: trimmedCode,
        role: trimmedRole,
        organizationType: trimmedOrgType,
      );
      if (!isValid) {
        throw Exception(
          'The verification code is invalid or has expired. '
          'Please check the code and try again.',
        );
      }
    } else if (trimmedRole == UserRole.secretary) {
      // Secretary must supply a verificationCode.
      if (trimmedCode == null || trimmedCode.isEmpty) {
        throw Exception(
          'A verification code is required for Secretary registration.',
        );
      }
 
      // ── Step 5: Validate code against Firestore ──────────────────────────
      final isValid = await _codeService.isValidCode(
        code: trimmedCode,
        role: trimmedRole,
      );
      if (!isValid) {
        throw Exception(
          'The verification code is invalid or has expired. '
          'Please check the code and try again.',
        );
      }
    }
    // Student: no verification code needed — fall through.
 
    // ── Step 6: Create Firebase Auth account ─────────────────────────────────
    // Keep a reference to UserCredential so we can delete the Auth account if
    // the Firestore write fails later.
    UserCredential credential;
    try {
      credential = await _authService.registerWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Re-throw as a plain Exception so the controller does not need to import
      // firebase_auth just to display an error message.
      throw Exception(_friendlyAuthError(e.code));
    }
 
    // ── Step 7: Get the new user UID ─────────────────────────────────────────
    final uid = credential.user?.uid;
    if (uid == null || uid.isEmpty) {
      // This should never happen, but guard against it defensively.
      throw Exception(
        'Registration failed: could not retrieve user ID. Please try again.',
      );
    }
 
    // ── Step 8: Build the UserModel ──────────────────────────────────────────
    final newUser = UserModel(
      uid: uid,
      fullName: trimmedFullName,
      email: trimmedEmail,
      role: trimmedRole,
      phoneNumber: trimmedPhone,
      matricNumber: trimmedMatric,
      organizationType: trimmedOrgType,
      verificationCode: trimmedCode,
      status: 'approved', // All users start as approved for now.
    );
 
    // ── Step 9: Save user profile to Firestore ───────────────────────────────
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(newUser.toMap());
    } catch (e) {
      // Firestore write failed.  Delete the Auth account so we do not leave an
      // orphaned auth entry without a matching Firestore profile.
      try {
        await credential.user?.delete();
      } catch (_) {
        // Ignore any error from the cleanup delete — there is nothing more we
        // can do here.  Log this in a real app (e.g. Firebase Crashlytics).
      }
      throw Exception(
        'Your account was created but your profile could not be saved. '
        'Please try registering again.',
      );
    }
 
    // ── Step 10: Return the saved UserModel ──────────────────────────────────
    return newUser;
  }
 
  // ── _friendlyAuthError ────────────────────────────────────────────────────
  /// Converts a [FirebaseAuthException] error code into a short, user-facing
  /// message.  Add more codes here as needed.
  String _friendlyAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email address already exists. '
            'Try logging in instead.';
      case 'invalid-email':
        return 'The email address entered is not valid.';
      case 'weak-password':
        return 'Your password is too weak. '
            'Please use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password registration is not enabled. '
            'Please contact support.';
      case 'network-request-failed':
        return 'No internet connection. '
            'Please check your network and try again.';
      default:
        return 'Registration failed ($code). Please try again.';
    }
  }
}