import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class DocumentUploadController extends ChangeNotifier {
  // ── Event context (set when opened from secretary event detail) ───────────
  String? _eventId;
  String? _lockedOrganizationType;
  String? _lockedOrganizationName;
  String? _lockedEventTitle;

  // ── Form field state ──────────────────────────────────────────────────────
  String _organizationType = 'Exco';
  String? _organizationName;
  String _title = '';
  String? _documentType;
  String _remarks = '';

  // ── File state ────────────────────────────────────────────────────────────
  PlatformFile? _pickedFile;

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  bool _submitted = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  String? get eventId => _eventId;
  bool get hasEventContext => _eventId != null;
  String? get lockedOrganizationType => _lockedOrganizationType;
  String? get lockedOrganizationName => _lockedOrganizationName;
  String? get lockedEventTitle => _lockedEventTitle;

  String get organizationType =>
      _lockedOrganizationType ?? _organizationType;
  String? get organizationName =>
      _lockedOrganizationName ?? _organizationName;
  String get title => _lockedEventTitle ?? _title;
  String? get documentType => _documentType;
  String get remarks => _remarks;
  PlatformFile? get pickedFile => _pickedFile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get submitted => _submitted;

  bool get hasFile => _pickedFile != null;
  String get fileName => _pickedFile?.name ?? '';
  double get fileSizeMB => (_pickedFile?.size ?? 0) / (1024 * 1024);

  // ── Initialize with event context ─────────────────────────────────────────
  void initWithEventContext({
    required String eventId,
    required String organizationType,
    required String organizationName,
    required String eventTitle,
  }) {
    _eventId = eventId;
    _lockedOrganizationType = organizationType;
    _lockedOrganizationName = organizationName;
    _lockedEventTitle = eventTitle;
    _organizationType = organizationType;
    _organizationName = organizationName;
    _title = eventTitle;
    notifyListeners();
  }

  // ── Setters (only used when no event context) ─────────────────────────────
  void setOrganizationType(String type) {
    if (hasEventContext) return;
    _organizationType = type;
    _organizationName = null;
    notifyListeners();
  }

  void setOrganizationName(String? name) {
    if (hasEventContext) return;
    _organizationName = name;
    notifyListeners();
  }

  void setTitle(String value) {
    if (hasEventContext) return;
    _title = value;
    notifyListeners();
  }

  void setDocumentType(String? type) {
    _documentType = type;
    notifyListeners();
  }

  void setRemarks(String value) {
    _remarks = value;
    notifyListeners();
  }

  // ── File picking ──────────────────────────────────────────────────────────
  Future<void> pickFile() async {
    _errorMessage = null;
    notifyListeners();

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    if (file.extension?.toLowerCase() != 'pdf') {
      _errorMessage = 'Only PDF files are allowed.';
      notifyListeners();
      return;
    }

    final sizeMB = file.size / (1024 * 1024);
    if (sizeMB > 10) {
      _errorMessage =
          'File size must not exceed 10MB. Your file is ${sizeMB.toStringAsFixed(1)}MB.';
      notifyListeners();
      return;
    }

    _pickedFile = file;
    notifyListeners();
  }

  void removeFile() {
    _pickedFile = null;
    notifyListeners();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  String? validate() {
    if (organizationName == null || organizationName!.isEmpty) {
      return 'Please select an organization name.';
    }
    if (title.trim().isEmpty) {
      return 'Please enter the event or document title.';
    }
    if (_documentType == null || _documentType!.isEmpty) {
      return 'Please select a document type.';
    }
    if (_pickedFile == null) {
      return 'Please upload a PDF document.';
    }
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<bool> submit() async {
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
      if (user == null) throw Exception('User not authenticated.');

      // 1. Upload PDF to Firebase Storage
      final fileRef = FirebaseStorage.instance
          .ref()
          .child('event_documents')
          .child(user.uid)
          .child(
              '${DateTime.now().millisecondsSinceEpoch}_${_pickedFile!.name}');

      UploadTask uploadTask;
      if (kIsWeb || _pickedFile!.bytes != null) {
        uploadTask = fileRef.putData(
          _pickedFile!.bytes!,
          SettableMetadata(contentType: 'application/pdf'),
        );
      } else {
        uploadTask = fileRef.putFile(
          File(_pickedFile!.path!),
          SettableMetadata(contentType: 'application/pdf'),
        );
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 2. Save document metadata to Firestore
      await FirebaseFirestore.instance.collection('documents').add({
        'title': title.trim(),
        'organizationType': organizationType,
        'organizationName': organizationName,
        'documentType': _documentType,
        'remarks': _remarks.trim(),
        'fileUrl': downloadUrl,
        'fileName': _pickedFile!.name,
        'fileSize': _pickedFile!.size,
        'status': 'Pending Review',
        'submittedBy': user.uid,
        'submittedAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
        'adminComment': null,
        'signedDocumentUrl': null,
        // Link to event if opened from secretary event detail
        'eventId': _eventId,
      });

      _submitted = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Upload failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────
  void reset() {
    _eventId = null;
    _lockedOrganizationType = null;
    _lockedOrganizationName = null;
    _lockedEventTitle = null;
    _organizationType = 'Exco';
    _organizationName = null;
    _title = '';
    _documentType = null;
    _remarks = '';
    _pickedFile = null;
    _isLoading = false;
    _errorMessage = null;
    _submitted = false;
    notifyListeners();
  }
}