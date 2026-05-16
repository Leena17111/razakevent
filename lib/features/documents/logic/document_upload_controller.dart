import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DocumentUploadController extends ChangeNotifier {
  // ── Form field state ──────────────────────────────────────────────
  String _organizationType = 'Exco'; // 'Exco' or 'Club'
  String? _organizationName;
  String _title = '';
  String? _documentType;
  String _remarks = '';

  // ── File state ───────────────────────────────────────────────────
  PlatformFile? _pickedFile;

  // ── UI state ─────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  bool _submitted = false;

  // ── Getters ──────────────────────────────────────────────────────
  String get organizationType => _organizationType;
  String? get organizationName => _organizationName;
  String get title => _title;
  String? get documentType => _documentType;
  String get remarks => _remarks;
  PlatformFile? get pickedFile => _pickedFile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get submitted => _submitted;

  bool get hasFile => _pickedFile != null;
  String get fileName => _pickedFile?.name ?? '';
  double get fileSizeMB =>
      (_pickedFile?.size ?? 0) / (1024 * 1024);

  // ── Setters ──────────────────────────────────────────────────────
  void setOrganizationType(String type) {
    _organizationType = type;
    _organizationName = null; // reset when type changes
    notifyListeners();
  }

  void setOrganizationName(String? name) {
    _organizationName = name;
    notifyListeners();
  }

  void setTitle(String value) {
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

  // ── File picking ─────────────────────────────────────────────────
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

    // Validate: PDF only
    if (file.extension?.toLowerCase() != 'pdf') {
      _errorMessage = 'Only PDF files are allowed.';
      notifyListeners();
      return;
    }

    // Validate: max 10MB
    final sizeMB = (file.size) / (1024 * 1024);
    if (sizeMB > 10) {
      _errorMessage = 'File size must not exceed 10MB. Your file is ${sizeMB.toStringAsFixed(1)}MB.';
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

  // ── Validation ───────────────────────────────────────────────────
  String? validate() {
    if (_organizationName == null || _organizationName!.isEmpty) {
      return 'Please select an organization name.';
    }
    if (_title.trim().isEmpty) {
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

  // ── Submit ───────────────────────────────────────────────────────
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

      await FirebaseFirestore.instance.collection('documents').add({
        'title': _title.trim(),
        'organizationType': _organizationType,
        'organizationName': _organizationName,
        'documentType': _documentType,
        'remarks': _remarks.trim(),
        'fileUrl': '',
        'fileName': _pickedFile!.name,
        'fileSize': _pickedFile!.size,
        'status': 'Pending Review',
        'submittedBy': user.uid,
        'submittedAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
        'adminComment': null,
        'signedDocumentUrl': null,
      });

      _submitted = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('UPLOAD ERROR: $e');
      _errorMessage = 'Submit failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Reset ────────────────────────────────────────────────────────
  void reset() {
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