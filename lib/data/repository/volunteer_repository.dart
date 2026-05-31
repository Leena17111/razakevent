import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';
import '../models/volunteer_position_model.dart';
import '../models/volunteer_application_model.dart';

class VolunteerRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<List<EventModel>> getOrganizerUpcomingEvents(
    String organizerId,
  ) async {
    final now = DateTime.now();

    // Step 1: Get approved pre-event paperwork event IDs
    final approvedDocs = await _firestore
        .collection('documents')
        .where('status', isEqualTo: 'Approved')
        .where(
          'documentType',
          isEqualTo: 'Pre-event Paperwork',
        )
        .get();

    final approvedEventIds = approvedDocs.docs
        .map(
          (doc) => doc.data()['eventId'] as String?,
        )
        .whereType<String>()
        .toSet();

    if (approvedEventIds.isEmpty) {
      return [];
    }

    // Step 2: Get organizer Open events
    final snapshot = await _firestore
        .collection('events')
        .where('createdBy', isEqualTo: organizerId)
        .where('status', isEqualTo: 'Open')
        .get();

    // Step 3: Keep only approved + future events
    final events = snapshot.docs
        .map(
          (doc) => EventModel.fromFirestore(doc),
        )
        .where((event) {
          return event.eventDateTime.isAfter(now) &&
              approvedEventIds.contains(
                event.eventId,
              );
        })
        .toList();

    // Step 4: Sort nearest upcoming first
    events.sort(
      (a, b) =>
          a.eventDateTime.compareTo(
            b.eventDateTime,
          ),
    );

    return events;
  }

  Stream<List<VolunteerPositionModel>>
      getPositionsForEvent(
    String eventId,
  ) {
    return _firestore
        .collection('volunteerPositions')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    VolunteerPositionModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> addVolunteerPosition(
    VolunteerPositionModel position,
  ) async {
    final docRef =
        _firestore.collection(
          'volunteerPositions',
        ).doc();

    await docRef.set({
      ...position.toMap(),
      'positionId': docRef.id,

      // Use local timestamp for instant realtime updates
      'createdAt': Timestamp.now(),
    });
  }
    Future<List<VolunteerPositionModel>> fetchOpenPositions() async {
  final snapshot = await _firestore.collection('volunteerPositions').get();

  final positions = snapshot.docs
      .map((doc) => VolunteerPositionModel.fromMap(doc.data(), doc.id))
      .where((position) => position.isAcceptingApplications)
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
  final positionRef =
      _firestore.collection('volunteerPositions').doc(position.positionId);

  final applicationRef = _firestore
      .collection('volunteerApplications')
      .doc('${position.positionId}_$studentUid');

  return _firestore.runTransaction<String>((transaction) async {
    final positionSnapshot = await transaction.get(positionRef);
    final applicationSnapshot = await transaction.get(applicationRef);

    if (!positionSnapshot.exists) {
      throw Exception('Volunteer position no longer exists.');
    }

    if (applicationSnapshot.exists) {
      throw Exception('You have already applied for this position.');
    }

    final currentPosition = VolunteerPositionModel.fromMap(
      positionSnapshot.data() as Map<String, dynamic>,
      positionSnapshot.id,
    );

    final maxApplications = currentPosition.maxApplications;

    if (currentPosition.status.toLowerCase() != 'open') {
      throw Exception('This volunteer position is no longer open.');
    }

    if (DateTime.now().isAfter(currentPosition.applicationDeadline)) {
      throw Exception('The application deadline has passed.');
    }

    if (currentPosition.isFull) {
      throw Exception('This volunteer position is already full.');
    }

    if (currentPosition.totalApplications >= maxApplications) {
      transaction.update(positionRef, {'status': 'closed'});
      throw Exception('Application limit reached for this position.');
    }

    final newTotalApplications = currentPosition.totalApplications + 1;

    transaction.set(applicationRef, {
      'applicationId': applicationRef.id,
      'positionId': currentPosition.positionId,
      'positionRoleName': currentPosition.roleName,
      'eventId': currentPosition.eventId,
      'eventTitle': currentPosition.eventTitle,
      'organizationName': '',
      'studentUid': studentUid,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'faculty': faculty,
      'previousExperience': previousExperience,
      'status': VolunteerApplicationStatus.pending,
      'appliedAt': FieldValue.serverTimestamp(),
    });

    transaction.update(positionRef, {
      'totalApplications': newTotalApplications,
      if (newTotalApplications >= maxApplications) 'status': 'closed',
    });

    return applicationRef.id;
  });
}
  
  Future<List<VolunteerApplicationModel>> fetchMyApplications(
    String studentUid,
  ) async {
    final snapshot = await _firestore
        .collection('volunteerApplications')
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

