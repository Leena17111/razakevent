// lib/data/repository/user_repository.dart
//
// Handles Firestore operations for user profiles.
// Responsibilities:
//   - Get the current user's profile from Firestore.
//   - Update editable profile fields.
//   - Keep Firebase/Auth logic outside the UI.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reads a user profile from Firestore using the Firebase Auth UID.
  Future<UserModel?> getUserById(String uid) async {
    final docSnapshot =
        await _firestore.collection(_usersCollection).doc(uid).get();

    if (!docSnapshot.exists) return null;

    final data = docSnapshot.data();
    if (data == null) return null;

    return UserModel.fromMap(data);
  }

  /// Updates editable profile fields.
  ///
  /// For Admin:
  /// - Only fullName is updated.
  ///
  /// For Student / Organizer Head / Secretary:
  /// - fullName, matricNumber, and phoneNumber are updated.
  ///
  /// Email and role are not updated here because:
  /// - Email belongs to Firebase Auth.
  /// - Role should not be freely changed by the user.
  Future<void> updateUserProfile({
    required String uid,
    required String fullName,
    String? phoneNumber,
    String? matricNumber,
  }) async {
    final updatedData = <String, dynamic>{
      'fullName': fullName.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (phoneNumber != null) {
      updatedData['phoneNumber'] = phoneNumber.trim();
    }

    if (matricNumber != null) {
      updatedData['matricNumber'] = matricNumber.trim();
    }

    await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .update(updatedData);
  }
}