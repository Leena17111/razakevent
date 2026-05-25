import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';
import '../models/volunteer_position_model.dart';

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
}