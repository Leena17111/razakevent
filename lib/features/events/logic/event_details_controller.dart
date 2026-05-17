import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/event_model.dart';
import '../../../data/repository/event_repository.dart';

class OrganizerProfileInfo {
  final String uid;
  final String fullName;
  final String organizationName;
  final String organizationType;

  const OrganizerProfileInfo({
    required this.uid,
    required this.fullName,
    required this.organizationName,
    required this.organizationType,
  });
}

class EventDetailsController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final EventRepository _eventRepository;

  EventDetailsController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    EventRepository? eventRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _eventRepository = eventRepository ?? EventRepository();

  String? get currentUserId => _auth.currentUser?.uid;

  Future<OrganizerProfileInfo?> getOrganizerProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();

    if (data == null) return null;

    return OrganizerProfileInfo(
      uid: uid,
      fullName: data['fullName'] ?? '',
      organizationName: data['organizationName'] ?? '',
      organizationType: data['organizationType'] ?? '',
    );
  }

  Stream<List<EventModel>> getEventsCreatedByOrganizer(String organizerUid) {
    return _eventRepository.getEventsCreatedByOrganizer(
      organizerUid: organizerUid,
    );
  }

  Future<String> createEvent(EventModel event) {
    return _eventRepository.createEvent(event);
  }

  Future<void> updateEvent(EventModel event) {
    return _eventRepository.updateEvent(event);
  }

  Future<void> deleteEvent(String eventId) {
    return _eventRepository.deleteEvent(eventId);
  }
}