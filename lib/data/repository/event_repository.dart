import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore;

  EventRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _eventsCollection =>
      _firestore.collection('events');

  Stream<List<EventModel>> getEventsCreatedByOrganizer({
    required String organizerUid,
  }) {
    return _eventsCollection
        .where('createdBy', isEqualTo: organizerUid)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();

      events.sort((a, b) => a.eventDateTime.compareTo(b.eventDateTime));
      return events;
    });
  }

  Future<String> createEvent(EventModel event) async {
    final docRef = await _eventsCollection.add(event.toCreateMap());
    return docRef.id;
  }

  Future<void> updateEvent(EventModel event) async {
    await _eventsCollection.doc(event.eventId).update(event.toUpdateMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }
}