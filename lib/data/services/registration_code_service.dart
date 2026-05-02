// lib/data/services/registration_code_service.dart
//
// Validates registration codes stored in the Firestore collection
// `registrationCodes`.
//
// Firestore structure
// ───────────────────
// Collection : registrationCodes
// Document ID: the code itself, e.g. "KTR-SEC", "EXCO-HEAD", "CLUB-HEAD"
//
// Each document contains:
//   role             String   e.g. "Organizer Head" | "Secretary"
//   organizationType String?  e.g. "Exco" | "Club"  (only for Organizer Head)
//   isActive         bool     true = code is still valid
//
// Usage
// ─────
// Called only for Organizer Head and Secretary during registration.
// Student registration bypasses this service entirely.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // for UserRole constants

class RegistrationCodeService {
  // ── Dependencies ───────────────────────────────────────────────────────────
  final FirebaseFirestore _firestore;

  // Firestore collection name — declared as a constant so it can be updated in
  // one place if it ever changes.
  static const String _collection = 'registrationCodes';

  RegistrationCodeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── isValidCode ────────────────────────────────────────────────────────────
  /// Checks whether [code] is a valid, active registration code for the given
  /// [role] and (optionally) [organizationType].
  ///
  /// Returns `true` only when ALL of the following conditions are met:
  ///   1. [code] is not empty after trimming.
  ///   2. The document `registrationCodes/{code}` exists in Firestore.
  ///   3. The document field `isActive` is `true`.
  ///   4. The document field `role` matches [role].
  ///   5. If [role] is Organizer Head, the document field `organizationType`
  ///      matches [organizationType] (Exco or Club).
  ///
  /// Returns `false` for any other outcome, including network errors, so the
  /// UI can treat a false result as "invalid code" without crashing.
  ///
  /// NOTE: Students do not need a code — do not call this method for them.
  Future<bool> isValidCode({
    required String code,
    required String role,
    String? organizationType,
  }) async {
    // ── Step 1: reject empty codes immediately ─────────────────────────────
    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) return false;

    try {
      // ── Step 2: fetch the document ───────────────────────────────────────
      final docSnapshot = await _firestore
          .collection(_collection)
          .doc(trimmedCode)
          .get();

      // ── Step 3: document must exist ──────────────────────────────────────
      if (!docSnapshot.exists) return false;

      final data = docSnapshot.data();
      if (data == null) return false;

      // ── Step 4: code must be active ──────────────────────────────────────
      final isActive = data['isActive'];
      if (isActive != true) return false;

      // ── Step 5: role must match ──────────────────────────────────────────
      final storedRole = data['role'] as String?;
      if (storedRole == null || storedRole != role) return false;

      // ── Step 6: Organizer Head — also check organizationType ─────────────
      if (role == UserRole.organizerHead) {
        final storedOrgType = data['organizationType'] as String?;

        // organizationType must be provided by the caller.
        if (organizationType == null || organizationType.trim().isEmpty) {
          return false;
        }

        // The code's organizationType must match what the user selected.
        if (storedOrgType != organizationType.trim()) return false;
      }

      // ── All checks passed ────────────────────────────────────────────────
      return true;
    } catch (_) {
      // Network error, permission denied, or any other Firestore exception.
      // Treat as invalid rather than crashing the registration flow.
      // The controller layer can retry or show a generic error message.
      return false;
    }
  }
}