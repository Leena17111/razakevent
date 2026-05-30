import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerPositionModel {
  final String positionId;
  final String eventId;
  final String eventTitle;
  final String organizerId;

  final String roleName;
  final String description;
  final String requirements;

  final int volunteersNeeded;
  final int approvedCount;
  final int totalApplications;

  final DateTime applicationDeadline;
  final DateTime eventDateTime;

  final String status; // open | full | closed
  final DateTime createdAt;

  const VolunteerPositionModel({
    required this.positionId,
    required this.eventId,
    required this.eventTitle,
    required this.organizerId,
    required this.roleName,
    required this.description,
    required this.requirements,
    required this.volunteersNeeded,
    required this.approvedCount,
    required this.totalApplications,
    required this.applicationDeadline,
    required this.eventDateTime,
    required this.status,
    required this.createdAt,
  });

  bool get isFull => approvedCount >= volunteersNeeded;
  int get availableSlots => volunteersNeeded - approvedCount;

double get fillRatio {
  if (volunteersNeeded <= 0) return 0.0;
  return (approvedCount / volunteersNeeded).clamp(0.0, 1.0);
}

bool get isOpen => status.toLowerCase() == 'open' && !isFull;

  bool get isAcceptingApplications =>
    status == 'open' &&
    DateTime.now().isBefore(applicationDeadline) &&
    !isFull &&
    totalApplications < volunteersNeeded + 5;

  factory VolunteerPositionModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return VolunteerPositionModel(
      positionId: id,
      eventId: map['eventId'] ?? '',
      eventTitle: map['eventTitle'] ?? '',
      organizerId: map['organizerId'] ?? '',
      roleName: map['roleName'] ?? '',
      description: map['description'] ?? '',
      requirements: map['requirements'] ?? '',
      volunteersNeeded: map['volunteersNeeded'] ?? 0,
      approvedCount: map['approvedCount'] ?? 0,
      totalApplications: map['totalApplications'] ?? 0,
      applicationDeadline:
          (map['applicationDeadline'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      eventDateTime:
          (map['eventDateTime'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      status: map['status'] ?? 'open',
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'organizerId': organizerId,
      'roleName': roleName,
      'description': description,
      'requirements': requirements,
      'volunteersNeeded': volunteersNeeded,
      'approvedCount': approvedCount,
      'totalApplications': totalApplications,
      'applicationDeadline':
          Timestamp.fromDate(applicationDeadline),
      'eventDateTime':
          Timestamp.fromDate(eventDateTime),
      'status': status,
      'createdAt':
          Timestamp.fromDate(createdAt),
    };
  }
}