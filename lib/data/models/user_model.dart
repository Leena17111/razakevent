// lib/data/models/user_model.dart
//
// Represents a RazakEvent user stored in Firestore at users/{uid}.
// No Firebase Auth or UI logic here — pure data model.

import 'package:cloud_firestore/cloud_firestore.dart'; // needed for Timestamp

// ─────────────────────────────────────────────────────────────────────────────
// Role constants — use these strings everywhere so typos are caught at
// compile time rather than at runtime.
// ─────────────────────────────────────────────────────────────────────────────
class UserRole {
  UserRole._(); // prevent instantiation

  static const String student = 'Student';
  static const String organizerHead = 'Organizer Head';
  static const String secretary = 'Secretary';
  static const String admin = 'Admin';
}

// ─────────────────────────────────────────────────────────────────────────────
// Organization type constants (Organizer Head only)
// ─────────────────────────────────────────────────────────────────────────────
class OrgType {
  OrgType._();

  static const String exco = 'Exco';
  static const String club = 'Club';
}

// ─────────────────────────────────────────────────────────────────────────────
// Organization name constants (Organizer Head only)
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// UserModel
// ─────────────────────────────────────────────────────────────────────────────
class UserModel {
  /// Firebase Auth UID — also used as the Firestore document ID.
  final String uid;

  final String fullName;
  final String email;

  /// One of [UserRole.student], [UserRole.organizerHead], [UserRole.secretary], [UserRole.admin].
  final String role;

  final String phoneNumber;
  final String matricNumber;

  /// Only set for Organizer Head: [OrgType.exco] or [OrgType.club].
  final String? organizationType;

  /// Only set for Organizer Head, e.g. "Exco Sukan" or "Kirana Razak".
  final String? organizationName;

  /// Only set for Organizer Head and Secretary.
  final String? verificationCode;

  /// Account approval status. Currently always `'approved'` on creation.
  final String status;

  /// When the user document was first written to Firestore.
  final DateTime? createdAt;

  // ── Constructor ────────────────────────────────────────────────────────────
  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.phoneNumber,
    required this.matricNumber,
    this.organizationType,
    this.organizationName,
    this.verificationCode,
    this.status = 'approved',
    this.createdAt,
  });

  // ── toMap ──────────────────────────────────────────────────────────────────
  /// Converts the model to a plain [Map] for writing to Firestore.
  /// Uses [FieldValue.serverTimestamp()] for [createdAt] so the value is set
  /// by Firestore's clock (more reliable than the device clock).
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'matricNumber': matricNumber,
      // Omit nullable fields from the map when they are null so the Firestore
      // document stays clean (no 'null' string values).
      if (organizationType != null) 'organizationType': organizationType,
      if (organizationName != null) 'organizationName': organizationName,
      if (verificationCode != null) 'verificationCode': verificationCode,
      'status': status,
      // Always write a fresh server timestamp when creating the document.
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // ── fromMap ────────────────────────────────────────────────────────────────
  /// Constructs a [UserModel] from a Firestore document snapshot map.
  /// Handles the case where [createdAt] arrives as a Firestore [Timestamp]
  /// (normal) or as null (e.g. before the server timestamp resolves).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Safely parse createdAt whether it is a Timestamp or null.
    DateTime? parsedCreatedAt;
    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    }
    // If it is already a DateTime (unit-test mocks, etc.) keep it as-is.
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
      organizationType: map['organizationType'] as String?,
      organizationName: map['organizationName'] as String?,
      verificationCode: map['verificationCode'] as String?,
      status: map['status'] as String? ?? 'approved',
      createdAt: parsedCreatedAt,
    );
  }

  // ── copyWith ───────────────────────────────────────────────────────────────
  /// Returns a new [UserModel] with the given fields replaced.
  /// Useful for updating a single field without reconstructing the whole object.
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? role,
    String? phoneNumber,
    String? matricNumber,
    // Use a sentinel so callers can explicitly pass null to clear these fields.
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

  // ── toString ───────────────────────────────────────────────────────────────
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

/// Private sentinel object used by [UserModel.copyWith] to distinguish
/// "caller did not pass this argument" from "caller explicitly passed null".
const Object _sentinel = Object();