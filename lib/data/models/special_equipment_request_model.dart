import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialEquipmentRequest {
  final String? id;
  final String eventId;
  final String eventName;
  final String organizerHeadId;
  final String itemName;
  final int quantityRequired;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String? adminNote; // rejection reason or approval location note
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SpecialEquipmentRequest({
    this.id,
    required this.eventId,
    required this.eventName,
    required this.organizerHeadId,
    required this.itemName,
    required this.quantityRequired,
    required this.reason,
    this.status = 'pending',
    this.adminNote,
    required this.createdAt,
    this.updatedAt,
  });

  factory SpecialEquipmentRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpecialEquipmentRequest(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      eventName: data['eventName'] ?? '',
      organizerHeadId: data['organizerHeadId'] ?? '',
      itemName: data['itemName'] ?? '',
      quantityRequired: data['quantityRequired'] ?? 1,
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      adminNote: data['adminNote'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'organizerHeadId': organizerHeadId,
      'itemName': itemName,
      'quantityRequired': quantityRequired,
      'reason': reason,
      'status': status,
      'adminNote': adminNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  SpecialEquipmentRequest copyWith({
    String? id,
    String? eventId,
    String? eventName,
    String? organizerHeadId,
    String? itemName,
    int? quantityRequired,
    String? reason,
    String? status,
    String? adminNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SpecialEquipmentRequest(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      organizerHeadId: organizerHeadId ?? this.organizerHeadId,
      itemName: itemName ?? this.itemName,
      quantityRequired: quantityRequired ?? this.quantityRequired,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
