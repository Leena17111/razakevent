import 'package:cloud_firestore/cloud_firestore.dart';

import 'volunteer_application_model.dart';
import 'volunteer_position_model.dart';

class VolunteerRepository {
  final FirebaseFirestore _firestore;

  VolunteerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _positionsRef =>
      _firestore.collection('volunteerPositions');

  CollectionReference<Map<String, dynamic>> get _applicationsRef =>
      _firestore.collection('volunteerApplications');

  Future<List<VolunteerPositionModel>> fetchOpenPositions() async {
    final snapshot = await _positionsRef.get();

    final positions = snapshot.docs
        .map((doc) => VolunteerPositionModel.fromMap(doc.data(), doc.id))
        .where((position) => position.status == VolunteerPositionStatus.open)
        .toList();

    positions.sort(
      (a, b) => a.applicationDeadline.compareTo(b.applicationDeadline),
    );

    return positions;
  }

  Future<String> submitApplicationFromForm({
    required VolunteerPositionModel position,
    required String studentUid,
    required String fullName,
    required String phoneNumber,
    required String faculty,
    required String previousExperience,
  }) async {
    final existing = await _applicationsRef
        .where('studentUid', isEqualTo: studentUid)
        .where('positionId', isEqualTo: position.id)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You have already applied for this position.');
    }

    final docRef = _applicationsRef.doc();

    await docRef.set({
      'applicationId': docRef.id,
      'positionId': position.id,
      'positionRoleName': position.roleName,
      'eventId': position.eventId,
      'eventTitle': position.eventTitle,
      'organizationName': position.organizationName,
      'studentUid': studentUid,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'faculty': faculty,
      'previousExperience': previousExperience,
      'status': VolunteerApplicationStatus.pending,
      'appliedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<List<VolunteerApplicationModel>> fetchMyApplications(
    String studentUid,
  ) async {
    final snapshot = await _applicationsRef
        .where('studentUid', isEqualTo: studentUid)
        .get();

    final applications = snapshot.docs
        .map((doc) => VolunteerApplicationModel.fromMap(doc.data(), doc.id))
        .toList();

    applications.sort((a, b) {
      final aDate = a.appliedAt ?? DateTime(2000);
      final bDate = b.appliedAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return applications;
  }
}