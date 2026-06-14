import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentCategory {
  EquipmentCategory._();

  static const String audio = 'Audio';
  static const String presentation = 'Presentation';
  static const String furniture = 'Furniture';
  static const String decoration = 'Decoration';
  static const String sports = 'Sports';
  static const String electrical = 'Electrical';
  static const String others = 'Others';

  static const List<String> values = [
    audio,
    presentation,
    furniture,
    decoration,
    sports,
    electrical,
    others,
  ];
}

class EquipmentStatus {
  EquipmentStatus._();

  static const String active = 'Active';
  static const String inactive = 'Inactive';
}

class EquipmentModel {
  final String equipmentId;
  final String category;
  final String itemName;
  final String description;
  final String storageLocation;
  final int totalQuantity;
  final int borrowedQuantity;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EquipmentModel({
    required this.equipmentId,
    required this.category,
    required this.itemName,
    required this.description,
    required this.storageLocation,
    required this.totalQuantity,
    required this.borrowedQuantity,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Calculated value, not stored in Firestore.
  /// availableQuantity = totalQuantity - borrowedQuantity.
  int get availableQuantity {
    final available = totalQuantity - borrowedQuantity;
    return available < 0 ? 0 : available;
  }

  bool get isActive => status == EquipmentStatus.active;

  bool get isInactive => status == EquipmentStatus.inactive;

  factory EquipmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return EquipmentModel(
      equipmentId: doc.id,
      category: data['category'] ?? EquipmentCategory.others,
      itemName: data['itemName'] ?? '',
      description: data['description'] ?? '',
      storageLocation: data['storageLocation'] ?? '',
      totalQuantity: _toInt(data['totalQuantity']),
      borrowedQuantity: _toInt(data['borrowedQuantity']),
      status: data['status'] ?? EquipmentStatus.active,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'category': category,
      'itemName': itemName,
      'description': description,
      'storageLocation': storageLocation,
      'totalQuantity': totalQuantity,
      'borrowedQuantity': borrowedQuantity,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'category': category,
      'itemName': itemName,
      'description': description,
      'storageLocation': storageLocation,
      'totalQuantity': totalQuantity,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  EquipmentModel copyWith({
    String? equipmentId,
    String? category,
    String? itemName,
    String? description,
    String? storageLocation,
    int? totalQuantity,
    int? borrowedQuantity,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EquipmentModel(
      equipmentId: equipmentId ?? this.equipmentId,
      category: category ?? this.category,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      storageLocation: storageLocation ?? this.storageLocation,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      borrowedQuantity: borrowedQuantity ?? this.borrowedQuantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}