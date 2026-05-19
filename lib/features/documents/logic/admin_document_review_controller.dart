import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../l10n/app_localizations.dart';

class AdminDocumentReviewController extends ChangeNotifier {
  // Keep these as internal logic values. Do not localize them.
  static const String actionApprove = 'Approve';
  static const String actionRequestCorrection = 'Request Correction';
  static const String actionReject = 'Reject';

  String? _selectedAction;
  String _adminComment = '';

  PlatformFile? _signedFile;

  bool _isLoading = false;
  String? _errorMessage;
  bool _submitted = false;

  String? get selectedAction => _selectedAction;
  String get adminComment => _adminComment;
  PlatformFile? get signedFile => _signedFile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get submitted => _submitted;

  bool get hasSignedFile => _signedFile != null;
  String get signedFileName => _signedFile?.name ?? '';
  double get signedFileSizeMB => (_signedFile?.size ?? 0) / (1024 * 1024);

  bool get isApprove => _selectedAction == actionApprove;
  bool get isRequestCorrection => _selectedAction == actionRequestCorrection;
  bool get isReject => _selectedAction == actionReject;

  void setSelectedAction(String action) {
    _selectedAction = action;

    if (action != actionApprove) {
      _signedFile = null;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void setAdminComment(String value) {
    _adminComment = value;
    notifyListeners();
  }

  Future<void> pickSignedFile(AppLocalizations l10n) async {
    _errorMessage = null;
    notifyListeners();

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final sizeMB = file.size / (1024 * 1024);

    if ((file.extension ?? '').toLowerCase() != 'pdf') {
      _errorMessage = l10n.invalidSignedDocumentFile;
      notifyListeners();
      return;
    }

    if (sizeMB > 10) {
      _errorMessage = l10n.fileSizeMustNotExceed10mb(
        sizeMB.toStringAsFixed(1),
      );
      notifyListeners();
      return;
    }

    _signedFile = file;
    notifyListeners();
  }

  void removeSignedFile() {
    _signedFile = null;
    notifyListeners();
  }

  String? validate(AppLocalizations l10n) {
    if (_selectedAction == null) {
      return l10n.selectReviewActionError;
    }

    if (_selectedAction == actionRequestCorrection &&
        _adminComment.trim().isEmpty) {
      return l10n.correctionCommentRequired;
    }

    if (_selectedAction == actionReject && _adminComment.trim().isEmpty) {
      return l10n.rejectionReasonRequired;
    }

    return null;
  }

  Future<bool> submitReview(String docId, AppLocalizations l10n) async {
    _errorMessage = null;

    final validationError = validate(l10n);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _errorMessage = l10n.userNotAuthenticated;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      String? signedDocumentUrl;
      String? signedDocumentFileName;
      String? signedDocumentStoragePath;

      if (_selectedAction == actionApprove && _signedFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('signed_documents')
            .child(user.uid)
            .child(docId)
            .child(
              '${DateTime.now().millisecondsSinceEpoch}_${_signedFile!.name}',
            );

        UploadTask uploadTask;

        if (kIsWeb) {
          final bytes = _signedFile!.bytes;

          if (bytes == null) {
            _errorMessage = l10n.unableToReadSelectedPdf;
            _isLoading = false;
            notifyListeners();
            return false;
          }

          uploadTask = ref.putData(
            bytes,
            SettableMetadata(contentType: 'application/pdf'),
          );
        } else {
          final path = _signedFile!.path;

          if (path == null) {
            _errorMessage = l10n.unableToReadSelectedPdf;
            _isLoading = false;
            notifyListeners();
            return false;
          }

          uploadTask = ref.putFile(
            File(path),
            SettableMetadata(contentType: 'application/pdf'),
          );
        }

        final snapshot = await uploadTask;
        signedDocumentUrl = await snapshot.ref.getDownloadURL();
        signedDocumentFileName = _signedFile!.name;
        signedDocumentStoragePath = ref.fullPath;
      }

      // Keep Firestore status values stable because other screens may depend on them.
      final String status;

      switch (_selectedAction) {
        case actionApprove:
          status = 'Approved';
          break;
        case actionRequestCorrection:
          status = 'Needs Correction';
          break;
        case actionReject:
          status = 'Rejected';
          break;
        default:
          status = 'Pending Review';
      }

      final updateData = <String, dynamic>{
        'status': status,
        'adminComment':
            _adminComment.trim().isNotEmpty ? _adminComment.trim() : null,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': user.uid,
      };

      if (signedDocumentUrl != null) {
        updateData['signedDocumentUrl'] = signedDocumentUrl;
      }

      if (signedDocumentFileName != null) {
        updateData['signedDocumentFileName'] = signedDocumentFileName;
      }

      if (signedDocumentStoragePath != null) {
        updateData['signedDocumentStoragePath'] = signedDocumentStoragePath;
      }

      await FirebaseFirestore.instance
          .collection('documents')
          .doc(docId)
          .update(updateData);

      _submitted = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('REVIEW SUBMIT ERROR: $e');
      _errorMessage = l10n.submissionFailed;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _selectedAction = null;
    _adminComment = '';
    _signedFile = null;
    _isLoading = false;
    _errorMessage = null;
    _submitted = false;
    notifyListeners();
  }
}