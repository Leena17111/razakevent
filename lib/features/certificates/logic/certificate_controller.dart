import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/certificate_model.dart';
import '../../../data/repository/certificate_repository.dart';
import 'certificate_trigger_service.dart';

class CertificateController extends ChangeNotifier {
  final CertificateRepository _repo = CertificateRepository();
  final CertificateTriggerService _triggerService =
      CertificateTriggerService();

  List<CertificateModel> certificates = [];
  bool isLoading = false;
  String? error;
  String studentName = 'Student';

  int get participationCount => certificates
      .where((c) => c.certType == CertificateType.participation)
      .length;

  int get volunteerCount => certificates
      .where((c) => c.certType == CertificateType.volunteer)
      .length;

  Future<void> fetchCertificates() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      error = 'userNotAuthenticated';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Pick up any certificates that haven't been issued yet
      // (covers old feedback/volunteer approvals + new ones).
      await _triggerService.syncCertificatesForUser(uid);

      certificates = await _repo.fetchForUser(uid);
      await _loadStudentName(uid);
    } catch (_) {
      error = 'somethingWentWrong';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStudentName(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      studentName = (data?['fullName'] as String?) ??
          (data?['name'] as String?) ??
          FirebaseAuth.instance.currentUser?.displayName ??
          'Student';
    } catch (_) {
      studentName = FirebaseAuth.instance.currentUser?.displayName ?? 'Student';
    }
  }
}