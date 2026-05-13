class FileConstants {
  FileConstants._();

  // UC006 Manage Event Documentation
  // Event documents are PDF only.
  static const int maxDocumentFileSizeMB = 10;
  static const List<String> allowedDocumentExtensions = [
    'pdf',
  ];

  // UC009 Manage Event Details
  // Event poster image.
  static const int maxPosterFileSizeMB = 5;
  static const List<String> allowedPosterExtensions = [
    'png',
    'jpg',
    'jpeg',
  ];

  // UC010 Create Event Feedback Form
  // UTM Smart Merit QR image.
  static const int maxMeritQrFileSizeMB = 2;
  static const List<String> allowedMeritQrExtensions = [
    'png',
    'jpg',
    'jpeg',
  ];
}