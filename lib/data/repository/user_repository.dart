// lib/data/repository/user_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserModel?> getUserById(String uid) async {
    final docSnapshot =
        await _firestore.collection(_usersCollection).doc(uid).get();

    if (!docSnapshot.exists) return null;

    final data = docSnapshot.data();
    if (data == null) return null;

    return UserModel.fromMap(data);
  }

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

    await _firestore.collection(_usersCollection).doc(uid).update(updatedData);
  }

  Future<void> updateProfileImageUrl({
    required String uid,
    required String profileImageUrl,
  }) async {
    await _firestore.collection(_usersCollection).doc(uid).update({
      'profileImageUrl': profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeProfileImageUrl({
    required String uid,
  }) async {
    await _firestore.collection(_usersCollection).doc(uid).update({
      'profileImageUrl': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}