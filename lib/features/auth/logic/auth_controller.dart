// lib/features/auth/logic/auth_controller.dart
//
// State manager for the authentication feature.
// Extends ChangeNotifier so the UI can listen with Provider / Consumer.
//
// Responsibilities:
//   - Call AuthRepository.registerUser and surface the result to the UI.
//   - Hold loading state, error messages, and the last registered user.
//   - Convert raw exceptions into simple, user-friendly strings.
//
// This class does NOT contain:
//   - Any Widget or BuildContext.
//   - Firebase imports.
//   - Firestore or AuthService calls (those live in AuthRepository).
//   - Form-field validation (email format, password length, etc.) — keep that
//     in the UI layer before calling register().

import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repository/auth_repository.dart';

class AuthController extends ChangeNotifier {
  // ── Dependencies ───────────────────────────────────────────────────────────
  final AuthRepository _repository;

  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  // ── Private state ──────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _registeredUser;

  // ── Public getters ─────────────────────────────────────────────────────────

  /// True while an async operation (registration, login, etc.) is in progress.
  /// Use this to show a loading spinner and disable the submit button.
  bool get isLoading => _isLoading;

  /// Holds the most recent error message, or null if there is no error.
  /// Reset by [clearError] or at the start of any new operation.
  String? get errorMessage => _errorMessage;

  /// The [UserModel] returned from the most recent successful registration.
  /// Null before registration or if registration failed.
  UserModel? get registeredUser => _registeredUser;

  // ── register ───────────────────────────────────────────────────────────────
  /// Calls [AuthRepository.registerUser] and manages loading + error state.
  ///
  /// Returns `true` on success; `false` on failure (error stored in
  /// [errorMessage]).
  ///
  /// The UI should check [isLoading] to show a spinner and [errorMessage] to
  /// show an inline error.
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String matricNumber,
    String? organizationType,
    String? organizationName,
    String? verificationCode,
  }) async {
    // ── Step 1: Set loading and clear any previous error ───────────────────
    _setLoading(true);
    _clearErrorSilently();

    try {
      // ── Step 2: Delegate to the repository ────────────────────────────────
      final user = await _repository.registerUser(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        phoneNumber: phoneNumber,
        matricNumber: matricNumber,
        organizationType: organizationType,
        organizationName: organizationName,
        verificationCode: verificationCode,
      );

      // ── Step 3: Store the returned user ───────────────────────────────────
      _registeredUser = user;

      // ── Step 4: Stop loading ───────────────────────────────────────────────
      _setLoading(false);

      // ── Step 5: Report success ─────────────────────────────────────────────
      return true;
    } catch (error) {
      // ── Step 6: Store a friendly error and stop loading ───────────────────
      _errorMessage = _toFriendlyMessage(error);
      _setLoading(false);

      return false;
    }
  }

  // ── clearError ─────────────────────────────────────────────────────────────
  /// Clears the current error message and notifies listeners.
  /// Call this when the user starts typing again after an error, so the
  /// error banner/text disappears immediately.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Updates [_isLoading] and notifies listeners in one call.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clears the error without notifying listeners.
  /// Used internally at the start of [register] because [_setLoading] already
  /// calls [notifyListeners] immediately after.
  void _clearErrorSilently() {
    _errorMessage = null;
  }

  /// Converts any [Exception] or [Error] thrown by the repository into a
  /// concise, user-facing string.
  ///
  /// The repository already converts FirebaseAuthException codes into readable
  /// messages, so most of the time [error.toString()] is good enough here.
  /// This method strips the "Exception: " prefix that Dart adds automatically.
  String _toFriendlyMessage(Object error) {
    final raw = error.toString();

    // Dart wraps thrown strings as "Exception: <message>" — remove the prefix.
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '');
    }

    // Fallback for any unexpected error types.
    return 'Something went wrong. Please try again.';
  }
}