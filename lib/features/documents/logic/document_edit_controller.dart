import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DocumentEditController extends ChangeNotifier {
  // ── Form field state ──────────────────────────────────────────────
  String _organizationType = 'Exco';
  String? _organizationName;
  String _title = '';
  String? _documentType;
  String _remarks = '';

  // ── Existing file state (from Firestore) ─────────────────────────
  String _existingFileUrl = '';
  String _existingFileName = '';
  int _existingFileSize = 0;

  // ── New file state (if secretary replaces PDF) ────────────────────
  PlatformFile? _newPickedFile;
  bool _fileReplaced = false;

  // ── UI state ─────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────────────
  String get organizationType => _organizationType;
  String? get organizationName => _organizationName;
  String get title => _title;
  String? get documentType => _documentType;
  String get remarks => _remarks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get fileReplaced => _fileReplaced;

  // Shows new file name if replaced, otherwise existing
  String get displayFileName =>
      _fileReplaced ? (_newPickedFile?.name ?? '') : _existingFileName;

  double get displayFileSizeMB => _fileReplaced
      ? ((_newPickedFile?.size ?? 0) / (1024 * 1024))
      : (_existingFileSize / (1024 * 1024));

  bool get hasFile => _fileReplaced || _existingFileName.isNotEmpty;

  // ── Load existing document data ───────────────────────────────────
  void loadFromData(Map<String, dynamic> data) {
    _organizationType = data['organizationType'] as String? ?? 'Exco';
    _organizationName = data['organizationName'] as String?;
    _title = data['title'] as String? ?? '';
    _documentType = data['documentType'] as String?;
    _remarks = data['remarks'] as String? ?? '';
    _existingFileUrl = data['fileUrl'] as String? ?? '';
    _existingFileName = data['fileName'] as String? ?? '';
    _existingFileSize = data['fileSize'] as int? ?? 0;
    _fileReplaced = false;
    _newPickedFile = null;
    notifyListeners();
  }

  // ── Setters ──────────────────────────────────────────────────────
  void setOrganizationType(String type) {
    _organizationType = type;
    _organizationName = null;
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
  Future<void> pickNewFile() async {
    _errorMessage = null;
    notifyListeners();

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
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

    _newPickedFile = file;
    _fileReplaced = true;
    notifyListeners();
  }

  void cancelFileReplacement() {
    _newPickedFile = null;
    _fileReplaced = false;
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
    if (!hasFile) {
      return 'Please upload a PDF document.';
    }
    return null;
  }

  // ── Update ───────────────────────────────────────────────────────
  Future<bool> update(String docId) async {
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
      String fileUrl = _existingFileUrl;
      String fileName = _existingFileName;
      int fileSize = _existingFileSize;

      // If secretary replaced the PDF, upload new one to Storage
      if (_fileReplaced && _newPickedFile != null) {
        // Delete old file from Storage if it exists
        if (_existingFileUrl.isNotEmpty) {
          try {
            await FirebaseStorage.instance
                .refFromURL(_existingFileUrl)
                .delete();
          } catch (_) {
            // Old file may not exist, ignore
          }
        }

        // Upload new file
        final user = FirebaseAuth.instance.currentUser!;
        final ref = FirebaseStorage.instance
            .ref()
            .child('event_documents')
            .child(user.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}_${_newPickedFile!.name}');

        UploadTask uploadTask;
        if (kIsWeb || _newPickedFile!.bytes != null) {
          uploadTask = ref.putData(
            _newPickedFile!.bytes!,
            SettableMetadata(contentType: 'application/pdf'),
          );
        } else {
          uploadTask = ref.putFile(
            File(_newPickedFile!.path!),
            SettableMetadata(contentType: 'application/pdf'),
          );
        }

        final snapshot = await uploadTask;
        fileUrl = await snapshot.ref.getDownloadURL();
        fileName = _newPickedFile!.name;
        fileSize = _newPickedFile!.size;
      }

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('documents')
          .doc(docId)
          .update({
        'title': _title.trim(),
        'organizationType': _organizationType,
        'organizationName': _organizationName,
        'documentType': _documentType,
        'remarks': _remarks.trim(),
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileSize': fileSize,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('UPDATE ERROR: $e');
      _errorMessage = 'Update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Delete ───────────────────────────────────────────────────────
  static Future<bool> delete(String docId, String fileUrl) async {
    try {
      // Delete file from Storage if it exists
      if (fileUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(fileUrl).delete();
        } catch (_) {
          // File may not exist, ignore
        }
      }

      // Delete Firestore document
      await FirebaseFirestore.instance
          .collection('documents')
          .doc(docId)
          .delete();

      return true;
    } catch (e) {
      print('DELETE ERROR: $e');
      return false;
    }
  }
}