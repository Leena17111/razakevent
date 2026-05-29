// lib/features/volunteer/data/models/volunteer_application_model.dart
//
// Represents a student's application for a volunteer position.
// Stored in Firestore at: volunteer_applications/{applicationId}
//
// UC015 (Student) writes this on submission.
// UC016 (Organizer Head) reads and updates status.
// UC017 (Student) reads status back.

import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Application status constants
// ─────────────────────────────────────────────────────────────────────────────
class VolunteerApplicationStatus {
  VolunteerApplicationStatus._();

  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
}

// ─────────────────────────────────────────────────────────────────────────────
// VolunteerApplicationModel
// ─────────────────────────────────────────────────────────────────────────────
class VolunteerApplicationModel {
  final String id;

  /// The volunteer position being applied for.
  final String positionId;
  final String positionRoleName;

  /// Denormalized event info for display in My Applications.
  final String eventId;
  final String eventTitle;

  /// Denormalized organizer info.
  final String organizationName;

  // ── Applicant info ─────────────────────────────────────────────────────────

  /// UID of the student submitting the application.
  final String studentUid;

  /// Pre-filled from user profile.
  final String fullName;
  final String phoneNumber;

  /// Required faculty selection.
  final String faculty;

  /// Optional textarea field.
  final String previousExperience;

  // ── Status ─────────────────────────────────────────────────────────────────

  /// One of [VolunteerApplicationStatus].
  final String status;

  /// Populated by UC016 when organizer rejects.
  final String? rejectionReason;

  final DateTime? appliedAt;
  final DateTime? reviewedAt;

  /// UID of organizer who reviewed. Populated by UC016.
  final String? reviewedByUid;

  const VolunteerApplicationModel({
    required this.id,
    required this.positionId,
    required this.positionRoleName,
    required this.eventId,
    required this.eventTitle,
    required this.organizationName,
    required this.studentUid,
    required this.fullName,
    required this.phoneNumber,
    required this.faculty,
    required this.previousExperience,
    required this.status,
    this.rejectionReason,
    this.appliedAt,
    this.reviewedAt,
    this.reviewedByUid,
  });

  // ── fromMap ────────────────────────────────────────────────────────────────
  factory VolunteerApplicationModel.fromMap(
      Map<String, dynamic> map, String docId) {
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return VolunteerApplicationModel(
      id: docId,
      positionId: map['positionId'] as String? ?? '',
      positionRoleName: map['positionRoleName'] as String? ?? '',
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? '',
      organizationName: map['organizationName'] as String? ?? '',
      studentUid: map['studentUid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      faculty: map['faculty'] as String? ?? '',
      previousExperience: map['previousExperience'] as String? ?? '',
      status: map['status'] as String? ?? VolunteerApplicationStatus.pending,
      rejectionReason: map['rejectionReason'] as String?,
      appliedAt: parseTimestamp(map['appliedAt']),
      reviewedAt: parseTimestamp(map['reviewedAt']),
      reviewedByUid: map['reviewedByUid'] as String?,
    );
  }

  // ── toMap ──────────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'positionId': positionId,
      'positionRoleName': positionRoleName,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'organizationName': organizationName,
      'studentUid': studentUid,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'faculty': faculty,
      'previousExperience': previousExperience,
      'status': status,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      'appliedAt': FieldValue.serverTimestamp(),
      if (reviewedAt != null) 'reviewedAt': Timestamp.fromDate(reviewedAt!),
      if (reviewedByUid != null) 'reviewedByUid': reviewedByUid,
    };
  }

  @override
  String toString() =>
      'VolunteerApplicationModel(id: $id, positionRoleName: $positionRoleName, status: $status)';
}