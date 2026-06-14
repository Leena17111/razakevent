import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/certificate_model.dart';
import '../../../data/models/volunteer_application_model.dart';
import '../../../data/repository/certificate_repository.dart';

class CertificateTriggerService {
  final CertificateRepository _repo = CertificateRepository();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // AD-190 — call this after a student successfully submits feedback
  Future<void> onFeedbackSubmitted({
    required String userId,
    required String eventId,
  }) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final eventName = data['title'] as String? ?? '';
      final eventDateTime =
          (data['eventDateTime'] as Timestamp?)?.toDate();

      if (eventDateTime == null || eventDateTime.isAfter(DateTime.now())) {
        return; // event hasn't ended yet
      }

      await _repo.issueCertificate(
        userId: userId,
        eventId: eventId,
        eventName: eventName,
        certType: CertificateType.participation,
      );
    } catch (_) {
      // Silent fail — certificate can be retried next time
    }
  }

  // AD-191 — call this after a volunteer application is approved
  Future<void> onVolunteerApproved({
    required String userId,
    required String eventId,
  }) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final eventName = data['title'] as String? ?? '';
      final eventDateTime =
          (data['eventDateTime'] as Timestamp?)?.toDate();

      if (eventDateTime == null || eventDateTime.isAfter(DateTime.now())) {
        return; // event hasn't ended yet
      }

      await _repo.issueCertificate(
        userId: userId,
        eventId: eventId,
        eventName: eventName,
        certType: CertificateType.volunteer,
      );
    } catch (_) {
      // Silent fail
    }
  }

  // Runs every time the certificates page loads — picks up any
  // feedback responses or approved volunteer applications that
  // haven't had a certificate issued yet (covers old data and any
  // future trigger failures). issueCertificate() is idempotent,
  // so this is safe to call repeatedly.
  Future<void> syncCertificatesForUser(String userId) async {
    try {
      // Participation certs — from feedback responses
      final feedbackDocs = await _db
          .collection('feedbackResponses')
          .where('studentId', isEqualTo: userId)
          .get();

      for (final doc in feedbackDocs.docs) {
        final eventId = doc.data()['eventId'] as String?;
        if (eventId == null) continue;
        await onFeedbackSubmitted(userId: userId, eventId: eventId);
      }

      // Volunteer certs — from approved volunteer applications
      final volunteerDocs = await _db
          .collection('volunteerApplications')
          .where('studentUid', isEqualTo: userId)
          .where('status', isEqualTo: VolunteerApplicationStatus.approved)
          .get();

      for (final doc in volunteerDocs.docs) {
        final eventId = doc.data()['eventId'] as String?;
        if (eventId == null) continue;
        await onVolunteerApproved(userId: userId, eventId: eventId);
      }
    } catch (_) {
      // Silent fail — certificates page just shows whatever's already issued
    }
  }
}