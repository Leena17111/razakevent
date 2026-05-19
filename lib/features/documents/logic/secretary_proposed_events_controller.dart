import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SecretaryProposedEventsController extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  SecretaryProposedEventsController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Stream ───────────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getProposedEvents() {
    return _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['eventId'] = doc.id;
              return data;
            }).toList()
          ..sort((a, b) {
            final aTime = a['eventDateTime'];
            final bTime = b['eventDateTime'];
            if (aTime == null || bTime == null) return 0;
            final aDate = aTime is Timestamp ? aTime.toDate() : DateTime.now();
            final bDate = bTime is Timestamp ? bTime.toDate() : DateTime.now();
            return aDate.compareTo(bDate);
          }));
  }

  // ── Paperwork status per event ───────────────────────────────────────────
  // Returns a stream of the document linked to this eventId submitted by
  // the secretary, or null if none exists yet.
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