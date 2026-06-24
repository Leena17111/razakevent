import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SecretaryProposedEventsController extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  SecretaryProposedEventsController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── All events stream ─────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getProposedEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      final events = snapshot.docs.map((doc) {
        final data = doc.data();
        data['eventId'] = doc.id;
        return data;
      }).toList();

      events.sort((a, b) {
        final aTime = a['eventDateTime'];
        final bTime = b['eventDateTime'];
        if (aTime == null || bTime == null) return 0;
        final aDate =
            aTime is Timestamp ? aTime.toDate() : DateTime.now();
        final bDate =
            bTime is Timestamp ? bTime.toDate() : DateTime.now();
        return aDate.compareTo(bDate);
      });

      return events;
    });
  }

  // ── BATCHED: fetch all documents for a list of eventIds in one query ──────
  // Returns a map of eventId → document data (or null if none exists).
  // Call this once per events list instead of one listener per card.
  Future<Map<String, Map<String, dynamic>?>> fetchDocumentsForEvents(
      List<String> eventIds) async {
    if (eventIds.isEmpty) return {};

    // Firestore whereIn supports up to 30 values; chunk if needed.
    final Map<String, Map<String, dynamic>?> result = {
      for (final id in eventIds) id: null,
    };

    const chunkSize = 30;
    for (var i = 0; i < eventIds.length; i += chunkSize) {
      final chunk = eventIds.sublist(
          i, i + chunkSize > eventIds.length ? eventIds.length : i + chunkSize);

      final snapshot = await _firestore
          .collection('documents')
          .where('eventId', whereIn: chunk)
          .get();

      // Keep only the first document per event (same as the old limit(1) logic).
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final eventId = data['eventId'] as String?;
        if (eventId != null && result[eventId] == null) {
          data['documentId'] = doc.id;
          result[eventId] = data;
        }
      }
    }

    return result;
  }

  // ── Single card listener — only used when navigating into a card detail ───
  Stream<Map<String, dynamic>?> getLinkedDocument(String eventId) {
    return _firestore
        .collection('documents')
        .where('eventId', isEqualTo: eventId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      data['documentId'] = doc.id;
      return data;
    });
  }
}