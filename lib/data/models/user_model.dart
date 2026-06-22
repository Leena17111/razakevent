// lib/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserRole {
  UserRole._();

  static const String student = 'Student';
  static const String organizerHead = 'Organizer Head';
  static const String secretary = 'Secretary';
  static const String admin = 'Admin';
}

class OrgType {
  OrgType._();

  static const String exco = 'Exco';
  static const String club = 'Club';
}

class OrgName {
  OrgName._();

  static const List<String> excos = [
    'Exco Sukan',
    'Exco Dokumentasi',
    'Exco Keselamatan',
    'Exco Akademik',
    'Exco Kerohanian',
    'Exco Kebajikan',
    'Exco Keusahawanan',
    'Exco Kebudayaan',
  ];

  static const List<String> clubs = [
    'Kirana Razak',
    'Senimas',
    'RASREC',
    'INVICTUS',
    'KSTAR',
    'UNLOC',
  ];
}

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String phoneNumber;
  final String matricNumber;

  final String? profileImageUrl;

  final String? organizationType;
  final String? organizationName;
  final String? verificationCode;

  final String status;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.phoneNumber,
    required this.matricNumber,
    this.profileImageUrl,
    this.organizationType,
    this.organizationName,
    this.verificationCode,
    this.status = 'approved',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'matricNumber': matricNumber,
      if (profileImageUrl != null && profileImageUrl!.isNotEmpty)
        'profileImageUrl': profileImageUrl,
      if (organizationType != null) 'organizationType': organizationType,
      if (organizationName != null) 'organizationName': organizationName,
      if (verificationCode != null) 'verificationCode': verificationCode,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;
    final rawCreatedAt = map['createdAt'];

    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    }

    if (rawCreatedAt is DateTime) {
      parsedCreatedAt = rawCreatedAt;
    }

    return UserModel(
      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      matricNumber: map['matricNumber'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String?,
      organizationType: map['organizationType'] as String?,
      organizationName: map['organizationName'] as String?,
      verificationCode: map['verificationCode'] as String?,
      status: map['status'] as String? ?? 'approved',
      createdAt: parsedCreatedAt,
    );
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? role,
    String? phoneNumber,
    String? matricNumber,
    Object? profileImageUrl = _sentinel,
    Object? organizationType = _sentinel,
    Object? organizationName = _sentinel,
    Object? verificationCode = _sentinel,
    String? status,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      matricNumber: matricNumber ?? this.matricNumber,
      profileImageUrl: profileImageUrl == _sentinel
          ? this.profileImageUrl
          : profileImageUrl as String?,
      organizationType: organizationType == _sentinel
          ? this.organizationType
          : organizationType as String?,
      organizationName: organizationName == _sentinel
          ? this.organizationName
          : organizationName as String?,
      verificationCode: verificationCode == _sentinel
          ? this.verificationCode
          : verificationCode as String?,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel('
        'uid: $uid, '
        'fullName: $fullName, '
        'email: $email, '
        'role: $role, '
        'organizationType: $organizationType, '
        'organizationName: $organizationName, '
        'status: $status'
        ')';
  }
}

const Object _sentinel = Object();