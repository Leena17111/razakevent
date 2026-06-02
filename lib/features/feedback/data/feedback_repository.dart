import 'package:cloud_firestore/cloud_firestore.dart';
import 'feedback_model.dart';

class FeedbackRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get feedback form (questions) for a specific event
  Future<Map<String, dynamic>?> getFeedbackForm(String eventId) async {
    final query = await _firestore
        .collection('feedbackForms')
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return {'id': query.docs.first.id, ...query.docs.first.data()};
  }

  // Check if student already submitted feedback for this event
  Future<bool> hasSubmittedFeedback(String eventId, String studentId) async {
    final query = await _firestore
        .collection('feedbackResponses')
        .where('eventId', isEqualTo: eventId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  // Submit feedback
  Future<void> submitFeedback(FeedbackModel feedback) async {
    await _firestore
        .collection('feedbackResponses')
        .add(feedback.toMap());
  }

  // Get all feedback responses for an event (for organizer)
  Future<List<FeedbackModel>> getEventFeedback(String eventId) async {
    final query = await _firestore
        .collection('feedbackResponses')
        .where('eventId', isEqualTo: eventId)
        .orderBy('submittedAt', descending: true)
        .get();

    return query.docs
        .map((doc) => FeedbackModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Get events that a student registered for and have ended (pending feedback)
  Future<List<Map<String, dynamic>>> getPendingFeedbackEvents(String studentId) async {
    final registrations = await _firestore
        .collection('eventRegistrations')
        .where('userId', isEqualTo: studentId)
        .get();

    if (registrations.docs.isEmpty) return [];

    final List<Map<String, dynamic>> pendingEvents = [];
    final now = DateTime.now();

    for (final reg in registrations.docs) {
      final eventId = reg.data()['eventId'] as String?;
      if (eventId == null) continue;

      // Check if already submitted
      final submitted = await hasSubmittedFeedback(eventId, studentId);
      if (submitted) continue;

      // Get event details
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) continue;

      final eventData = eventDoc.data()!;

      // Only show if event has ended AND within 3-day feedback window
      final eventDateTime = (eventData['eventDateTime'] as Timestamp?)?.toDate();
      if (eventDateTime == null || eventDateTime.isAfter(now)) continue;

      // Calculate deadline (3 days after event ends)
      final feedbackDeadline = eventDateTime.add(const Duration(days: 3));

      // Skip if deadline has passed
      if (now.isAfter(feedbackDeadline)) continue;

      // Check if feedback form exists for this event
      final form = await getFeedbackForm(eventId);
      if (form == null) continue;

      pendingEvents.add({
        'eventId': eventId,
        'eventTitle': eventData['title'] ?? '',
        'organizationName': eventData['organizationName'] ?? '',
        'eventDate': eventData['eventDateTime'],
        'formId': form['id'],
        'feedbackDeadline': eventDateTime.add(const Duration(days: 3)),  // NEW LINE
      });
    }

    return pendingEvents;
  }
// Get all registrants for an event (for organizer)
  Future<List<Map<String, dynamic>>> getEventRegistrants(String eventId) async {
    final query = await _firestore
        .collection('eventRegistrations')
        .where('eventId', isEqualTo: eventId)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }
}