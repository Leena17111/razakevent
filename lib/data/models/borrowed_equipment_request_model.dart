import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowedEquipmentRequestModel {
  final String id;
  final String eventId;
  final String eventName;
  final String organizerHeadId;
  final String equipmentId;
  final String equipmentName;
  final String category;
  final int quantity;
  final String status;
  final String storageLocation;
  final DateTime? eventDate;
  final DateTime createdAt;
  final DateTime? returnedAt;
  final String? returnEvidenceUrl;
  final String? returnEvidencePath;

  const BorrowedEquipmentRequestModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.organizerHeadId,
    required this.equipmentId,
    required this.equipmentName,
    required this.category,
    required this.quantity,
    required this.status,
    required this.createdAt,
    this.storageLocation = '',
    this.eventDate,
    this.returnedAt,
    this.returnEvidenceUrl,
    this.returnEvidencePath,
  });

  factory BorrowedEquipmentRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return BorrowedEquipmentRequestModel(
      id: doc.id,
      eventId: data['eventId'] as String? ?? '',
      eventName: data['eventName'] as String? ?? '',
      organizerHeadId: data['organizerHeadId'] as String? ?? '',
      equipmentId: data['equipmentId'] as String? ?? '',
      equipmentName: data['equipmentName'] as String? ?? '',
      category: data['category'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'borrowed',
      storageLocation: data['storageLocation'] as String? ?? '',
      eventDate: (data['eventDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnedAt: (data['returnedAt'] as Timestamp?)?.toDate(),
      returnEvidenceUrl: data['returnEvidenceUrl'] as String?,
      returnEvidencePath: data['returnEvidencePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'organizerHeadId': organizerHeadId,
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'category': category,
      'quantity': quantity,
      'status': status,
      'isSpecialRequest': false,
      'storageLocation': storageLocation,
      'eventDate': eventDate == null ? null : Timestamp.fromDate(eventDate!),
      'createdAt': Timestamp.fromDate(createdAt),
      'returnedAt': returnedAt == null ? null : Timestamp.fromDate(returnedAt!),
      'returnEvidenceUrl': returnEvidenceUrl,
      'returnEvidencePath': returnEvidencePath,
    };
  }
}
