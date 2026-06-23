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
  //
  // Uses a deterministic document ID (userId_eventId_certType) + a
  // transaction instead of a "query then add()" check. This makes
  // duplicate issuance structurally impossible, even if this method
  // gets called twice concurrently for the same user/event/type.
  Future<void> issueCertificate({
    required String userId,
    required String eventId,
    required String eventName,
    required CertificateType certType,
  }) async {
    final typeStr =
        certType == CertificateType.volunteer ? 'volunteer' : 'participation';

    final docRef = _col.doc('${userId}_${eventId}_$typeStr');

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) return; // already issued — no-op

      transaction.set(docRef, {
        'userId': userId,
        'eventId': eventId,
        'eventName': eventName,
        'certType': typeStr,
        'issuedAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  // Permanent safety net: cleans up duplicate certificates for a single
  // user, and migrates the surviving copy in each eventId+certType group
  // onto the canonical deterministic ID (userId_eventId_certType) that
  // issueCertificate() expects.
  //
  // Migration matters: old documents created before issueCertificate()
  // switched to deterministic IDs still live at random auto-generated
  // IDs. If we only deleted extras and left the survivor at its old
  // random ID, issueCertificate()'s existence check (which looks at the
  // canonical ID) would never find it — and would create a brand new
  // doc on every sync, undoing the cleanup on every load. Writing the
  // survivor to the canonical ID closes that gap for good.
  //
  // Safe to call on every load — once everything is migrated, this
  // becomes a no-op (zero changes).
  Future<int> cleanupDuplicateCertificates(String userId) async {
    final snap = await _col.where('userId', isEqualTo: userId).get();

    final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
        grouped = {};

    for (final doc in snap.docs) {
      final data = doc.data();
      final key = '${data['eventId']}_${data['certType']}';
      grouped.putIfAbsent(key, () => []).add(doc);
    }

    final batch = _db.batch();
    int changes = 0;

    for (final entry in grouped.entries) {
      final docs = entry.value;
      final eventId = docs.first.data()['eventId'];
      final certType = docs.first.data()['certType'];
      final canonicalId = '${userId}_${eventId}_$certType';

      final alreadyCanonical = docs.any((d) => d.id == canonicalId);
      if (docs.length == 1 && alreadyCanonical) {
        continue; // single doc, already at the right ID — nothing to do
      }

      // Prefer the doc already sitting at the canonical ID (if any);
      // otherwise keep the earliest-issued copy.
      docs.sort((a, b) {
        final aTime = (a.data()['issuedAt'] as Timestamp).toDate();
        final bTime = (b.data()['issuedAt'] as Timestamp).toDate();
        return aTime.compareTo(bTime);
      });
      final canonicalMatch = docs.where((d) => d.id == canonicalId);
      final keptData = canonicalMatch.isNotEmpty
          ? canonicalMatch.first.data()
          : docs.first.data();

      // Write the kept data to the canonical ID.
      batch.set(_col.doc(canonicalId), keptData);
      changes++;

      // Delete every doc in this group that isn't the canonical one.
      for (final d in docs) {
        if (d.id != canonicalId) {
          batch.delete(d.reference);
          changes++;
        }
      }
    }

    if (changes > 0) {
      await batch.commit();
    }

    return changes;
  }
}