import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class AdminDocumentReviewController extends ChangeNotifier {
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

  bool get isApprove => _selectedAction == 'Approve';
  bool get isRequestCorrection => _selectedAction == 'Request Correction';
  bool get isReject => _selectedAction == 'Reject';

  void setSelectedAction(String action) {
    _selectedAction = action;

    if (action != 'Approve') {
      _signedFile = null;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void setAdminComment(String value) {
    _adminComment = value;
    notifyListeners();
  }

  Future<void> pickSignedFile() async {
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

    if (sizeMB > 10) {
      _errorMessage =
          'File size must not exceed 10MB. Your file is ${sizeMB.toStringAsFixed(1)}MB.';
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

  String? validate() {
    if (_selectedAction == null) {
      return 'Please select a review action.';
    }

    if (_selectedAction == 'Request Correction' &&
        _adminComment.trim().isEmpty) {
      return 'Please provide an admin comment when requesting correction.';
    }

    if (_selectedAction == 'Reject' && _adminComment.trim().isEmpty) {
      return 'Please provide a reason for rejection.';
    }

    return null;
  }

  Future<bool> submitReview(String docId) async {
    _errorMessage = null;

    final validationError = validate();
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
        throw Exception('User not authenticated.');
      }

      String? signedDocumentUrl;
      String? signedDocumentFileName;

      if (_selectedAction == 'Approve' && _signedFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('signed_documents')
            .child(user.uid)
            .child(
              '${DateTime.now().millisecondsSinceEpoch}_${_signedFile!.name}',
            );

        UploadTask uploadTask;

        if (kIsWeb) {
          final bytes = _signedFile!.bytes;

          if (bytes == null) {
            throw Exception('Unable to read selected PDF file.');
          }

          uploadTask = ref.putData(
            bytes,
            SettableMetadata(contentType: 'application/pdf'),
          );
        } else {
          final path = _signedFile!.path;

          if (path == null) {
            throw Exception('Unable to read selected PDF file path.');
          }

          uploadTask = ref.putFile(
            File(path),
            SettableMetadata(contentType: 'application/pdf'),
          );
        }

        final snapshot = await uploadTask;
        signedDocumentUrl = await snapshot.ref.getDownloadURL();
        signedDocumentFileName = _signedFile!.name;
      }

      final String status;

      switch (_selectedAction) {
        case 'Approve':
          status = 'Approved';
          break;
        case 'Request Correction':
          status = 'Needs Correction';
          break;
        case 'Reject':
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
      _errorMessage = 'Submission failed: ${e.toString()}';
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