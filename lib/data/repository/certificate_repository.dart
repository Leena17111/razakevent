import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/certificate_model.dart';

class CertificateRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('certificates');

  // AD-192 — fetch all certificates for the current user, newest first
  Future<List<CertificateModel>> fetchForUser(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .get();

    final certs = snap.docs.map((doc) => CertificateModel.fromDoc(doc)).toList();
    certs.sort((a, b) => b.issuedAt.compareTo(a.issuedAt)); // newest first
    return certs;
  }

  // AD-190 / AD-191 — auto-issue, idempotent (no duplicates)
  Future<void> issueCertificate({
    required String userId,
    required String eventId,
    required String eventName,
    required CertificateType certType,
  }) async {
    final typeStr =
        certType == CertificateType.volunteer ? 'volunteer' : 'participation';

    final existing = await _col
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .where('certType', isEqualTo: typeStr)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // already issued, skip

    await _col.add({
      'userId': userId,
      'eventId': eventId,
      'eventName': eventName,
      'certType': typeStr,
      'issuedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}