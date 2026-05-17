import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String organizationName;
  final String organizationType;
  final String category;
  final String description;

  final String posterFileName;
  final String posterUrl;
  final String posterStoragePath;

  final String venue;
  final DateTime eventDateTime;

  final bool registrationEnabled;
  final DateTime? registrationDeadline;
  final int? participantCapacity;
  final double registrationFee;
  final String contactPerson;
  final int registeredCount;

  final String status;
  final String createdBy;

  // Future integration with approved proposal/document workflow.
  final String? proposalDocumentId;
  final String? proposalTitle;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventModel({
    required this.eventId,
    required this.title,
    required this.organizationName,
    required this.organizationType,
    required this.category,
    required this.description,
    required this.posterFileName,
    required this.posterUrl,
    required this.posterStoragePath,
    required this.venue,
    required this.eventDateTime,
    required this.registrationEnabled,
    required this.registrationFee,
    required this.contactPerson,
    required this.registeredCount,
    required this.status,
    required this.createdBy,
    this.registrationDeadline,
    this.participantCapacity,
    this.proposalDocumentId,
    this.proposalTitle,
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return EventModel(
      eventId: doc.id,
      title: data['title'] ?? '',
      organizationName: data['organizationName'] ?? '',
      organizationType: data['organizationType'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      posterFileName: data['posterFileName'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      posterStoragePath: data['posterStoragePath'] ?? '',
      venue: data['venue'] ?? '',
      eventDateTime: _toDateTime(data['eventDateTime']) ?? DateTime.now(),
      registrationEnabled: data['registrationEnabled'] ?? false,
      registrationDeadline: _toDateTime(data['registrationDeadline']),
      participantCapacity: _toInt(data['participantCapacity']),
      registrationFee: _toDouble(data['registrationFee']),
      contactPerson: data['contactPerson'] ?? '',
      registeredCount: _toInt(data['registeredCount']) ?? 0,
      status: data['status'] ?? 'Draft',
      createdBy: data['createdBy'] ?? '',
      proposalDocumentId: data['proposalDocumentId'],
      proposalTitle: data['proposalTitle'],
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'title': title,
      'organizationName': organizationName,
      'organizationType': organizationType,
      'category': category,
      'description': description,
      'posterFileName': posterFileName,
      'posterUrl': posterUrl,
      'posterStoragePath': posterStoragePath,
      'venue': venue,
      'eventDateTime': Timestamp.fromDate(eventDateTime),
      'registrationEnabled': registrationEnabled,
      'registrationDeadline': registrationDeadline == null
          ? null
          : Timestamp.fromDate(registrationDeadline!),
      'participantCapacity': participantCapacity,
      'registrationFee': registrationFee,
      'contactPerson': contactPerson,
      'registeredCount': registeredCount,
      'status': status,
      'createdBy': createdBy,
      'proposalDocumentId': proposalDocumentId,
      'proposalTitle': proposalTitle,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'organizationName': organizationName,
      'organizationType': organizationType,
      'category': category,
      'description': description,
      'posterFileName': posterFileName,
      'posterUrl': posterUrl,
      'posterStoragePath': posterStoragePath,
      'venue': venue,
      'eventDateTime': Timestamp.fromDate(eventDateTime),
      'registrationEnabled': registrationEnabled,
      'registrationDeadline': registrationDeadline == null
          ? null
          : Timestamp.fromDate(registrationDeadline!),
      'participantCapacity': participantCapacity,
      'registrationFee': registrationFee,
      'contactPerson': contactPerson,
      'registeredCount': registeredCount,
      'status': status,
      'proposalDocumentId': proposalDocumentId,
      'proposalTitle': proposalTitle,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}