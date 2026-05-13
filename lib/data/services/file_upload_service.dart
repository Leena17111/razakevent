// lib/data/services/file_upload_service.dart

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants/file_constants.dart';

enum UploadFileType {
  eventDocument,
  eventPoster,
  meritQr,
}

class PickedUploadFile {
  final String name;
  final String extension;
  final int sizeBytes;
  final Uint8List bytes;

  const PickedUploadFile({
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.bytes,
  });

  double get sizeMB => sizeBytes / (1024 * 1024);
}

class FileUploadResult {
  final String fileName;
  final String downloadUrl;
  final String storagePath;
  final int sizeBytes;
  final String extension;

  const FileUploadResult({
    required this.fileName,
    required this.downloadUrl,
    required this.storagePath,
    required this.sizeBytes,
    required this.extension,
  });
}

class FileUploadService {
  final FirebaseStorage _storage;

  FileUploadService({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  Future<PickedUploadFile?> pickEventDocument() {
    return _pickFile(
      allowedExtensions: FileConstants.allowedDocumentExtensions,
      maxFileSizeMB: FileConstants.maxDocumentFileSizeMB,
    );
  }

  Future<PickedUploadFile?> pickEventPoster() {
    return _pickFile(
      allowedExtensions: FileConstants.allowedPosterExtensions,
      maxFileSizeMB: FileConstants.maxPosterFileSizeMB,
    );
  }

  Future<PickedUploadFile?> pickMeritQr() {
    return _pickFile(
      allowedExtensions: FileConstants.allowedMeritQrExtensions,
      maxFileSizeMB: FileConstants.maxMeritQrFileSizeMB,
    );
  }

  Future<PickedUploadFile?> _pickFile({
  required List<String> allowedExtensions,
  required int maxFileSizeMB,
}) async {
  final fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
    type: fp.FileType.custom,
    allowedExtensions: allowedExtensions,
    allowMultiple: false,
    withData: true,
  );

  if (result == null || result.files.isEmpty) {
    return null;
  }

  final fp.PlatformFile file = result.files.single;
  final String extension = (file.extension ?? '').toLowerCase();

  if (!allowedExtensions.contains(extension)) {
    throw Exception(
      'Invalid file type. Allowed: ${allowedExtensions.join(', ')}.',
    );
  }

  final int maxSizeBytes = maxFileSizeMB * 1024 * 1024;

  if (file.size > maxSizeBytes) {
    throw Exception('File size must not exceed ${maxFileSizeMB}MB.');
  }

  final Uint8List? bytes = file.bytes;

  if (bytes == null) {
    throw Exception('Could not read selected file.');
  }

  return PickedUploadFile(
    name: file.name,
    extension: extension,
    sizeBytes: file.size,
    bytes: bytes,
  );
}

  Future<FileUploadResult> uploadPickedFile({
    required PickedUploadFile file,
    required UploadFileType uploadType,
    required String ownerId,
    String? recordId,
  }) async {
    final String storageFolder = _storageFolderForType(uploadType);
    final String safeFileName = _safeFileName(file.name);
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    final List<String> pathParts = [
      storageFolder,
      ownerId,
      if (recordId != null && recordId.trim().isNotEmpty) recordId,
      '${timestamp}_$safeFileName',
    ];

    final String storagePath = pathParts.join('/');
    final Reference reference = _storage.ref().child(storagePath);

    final SettableMetadata metadata = SettableMetadata(
      contentType: _contentTypeForExtension(file.extension),
      customMetadata: {
        'originalFileName': file.name,
        'extension': file.extension,
        'uploadType': uploadType.name,
      },
    );

    final TaskSnapshot snapshot = await reference.putData(
      file.bytes,
      metadata,
    );

    final String downloadUrl = await snapshot.ref.getDownloadURL();

    return FileUploadResult(
      fileName: file.name,
      downloadUrl: downloadUrl,
      storagePath: storagePath,
      sizeBytes: file.sizeBytes,
      extension: file.extension,
    );
  }

  Future<void> deleteFileByPath(String storagePath) async {
    if (storagePath.trim().isEmpty) return;

    await _storage.ref().child(storagePath).delete();
  }

  String _storageFolderForType(UploadFileType uploadType) {
    switch (uploadType) {
      case UploadFileType.eventDocument:
        return 'event_documents';
      case UploadFileType.eventPoster:
        return 'event_posters';
      case UploadFileType.meritQr:
        return 'merit_qr_codes';
    }
  }

  String _contentTypeForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  String _safeFileName(String fileName) {
    return fileName
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');
  }
}