import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerPositionStatus {
  VolunteerPositionStatus._();

  static const String open = 'Open';
  static const String full = 'Full';
  static const String closed = 'Closed';
}

class VolunteerPositionModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String organizationName;
  final String roleName;
  final String description;
  final String requirements;
  final int totalSlots;
  final int filledSlots;
  final DateTime applicationDeadline;
  final DateTime? eventDate;
  final String status;
  final String createdByUid;
  final DateTime? createdAt;

  const VolunteerPositionModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.organizationName,
    required this.roleName,
    required this.description,
    required this.requirements,
    required this.totalSlots,
    required this.filledSlots,
    required this.applicationDeadline,
    this.eventDate,
    required this.status,
    required this.createdByUid,
    this.createdAt,
  });

  int get availableSlots => totalSlots - filledSlots;

  bool get isFull => totalSlots > 0 && filledSlots >= totalSlots;

  bool get isOpen => status == VolunteerPositionStatus.open && !isFull;

  double get fillRatio {
    if (totalSlots <= 0) return 0.0;
    return (filledSlots / totalSlots).clamp(0.0, 1.0);
  }

  static String _normalizeStatus(String? status) {
    final value = status?.toLowerCase().trim();

    if (value == 'open') return VolunteerPositionStatus.open;
    if (value == 'full') return VolunteerPositionStatus.full;
    if (value == 'closed') return VolunteerPositionStatus.closed;

    return VolunteerPositionStatus.open;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  factory VolunteerPositionModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    final totalSlots = (map['totalSlots'] as num?)?.toInt() ??
        (map['volunteersNeeded'] as num?)?.toInt() ??
        (map['slots'] as num?)?.toInt() ??
        0;

    final filledSlots = (map['filledSlots'] as num?)?.toInt() ??
        (map['approvedCount'] as num?)?.toInt() ??
        0;

    return VolunteerPositionModel(
      id: docId,
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? '',
      organizationName: map['organizationName'] as String? ??
          map['organization'] as String? ??
          '',
      roleName: map['roleName'] as String? ??
          map['positionName'] as String? ??
          map['title'] as String? ??
          '',
      description: map['description'] as String? ?? '',
      requirements: map['requirements'] as String? ?? '',
      totalSlots: totalSlots,
      filledSlots: filledSlots,
      applicationDeadline: _parseTimestamp(map['applicationDeadline']) ??
          _parseTimestamp(map['deadline']) ??
          _parseTimestamp(map['eventDateTime']) ??
          DateTime.now().add(const Duration(days: 7)),
      eventDate: _parseTimestamp(map['eventDate']) ??
          _parseTimestamp(map['eventDateTime']),
      status: _normalizeStatus(map['status'] as String?),
      createdByUid: map['createdByUid'] as String? ??
          map['organizerId'] as String? ??
          '',
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'organizationName': organizationName,
      'roleName': roleName,
      'description': description,
      'requirements': requirements,
      'totalSlots': totalSlots,
      'volunteersNeeded': totalSlots,
      'filledSlots': filledSlots,
      'approvedCount': filledSlots,
      'applicationDeadline': Timestamp.fromDate(applicationDeadline),
      if (eventDate != null) 'eventDateTime': Timestamp.fromDate(eventDate!),
      'status': status.toLowerCase(),
      'createdByUid': createdByUid,
      'organizerId': createdByUid,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() =>
      'VolunteerPositionModel(id: $id, roleName: $roleName, status: $status)';
}