import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/equipment_model.dart';

class EquipmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _equipmentCollection =>
      _firestore.collection('equipment');

  /// Admin inventory should see both Active and Inactive equipment.
  Stream<List<EquipmentModel>> watchEquipment() {
    return _equipmentCollection.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => EquipmentModel.fromFirestore(doc))
          .toList();

      items.sort(
        (a, b) => a.itemName.toLowerCase().compareTo(
              b.itemName.toLowerCase(),
            ),
      );

      return items;
    });
  }

  /// Organizer browse screen later should use this
  Stream<List<EquipmentModel>> watchActiveEquipment() {
    return _equipmentCollection
        .where('status', isEqualTo: EquipmentStatus.active)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => EquipmentModel.fromFirestore(doc))
          .where((item) => item.availableQuantity > 0)
          .toList();

      items.sort(
        (a, b) => a.itemName.toLowerCase().compareTo(
              b.itemName.toLowerCase(),
            ),
      );

      return items;
    });
  }

  Future<void> addEquipment(EquipmentModel equipment) async {
    final docRef = _equipmentCollection.doc();

    await docRef.set({
      ...equipment.toCreateMap(),
      'equipmentId': docRef.id,
    });
  }

  Future<void> updateEquipment(EquipmentModel equipment) async {
    if (equipment.equipmentId.isEmpty) {
      throw Exception('equipmentIdMissing');
    }

    final docRef = _equipmentCollection.doc(equipment.equipmentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('equipmentNotFound');
      }

      final current = EquipmentModel.fromFirestore(snapshot);

      if (equipment.totalQuantity < current.borrowedQuantity) {
        throw Exception('quantityCannotBeLessThanBorrowed');
      }

      transaction.update(docRef, equipment.toUpdateMap());
    });
  }

  Future<void> markEquipmentStatus({
    required String equipmentId,
    required String status,
  }) async {
    if (equipmentId.isEmpty) {
      throw Exception('equipmentIdMissing');
    }

    if (status != EquipmentStatus.active &&
        status != EquipmentStatus.inactive) {
      throw Exception('invalidEquipmentStatus');
    }

    final docRef = _equipmentCollection.doc(equipmentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('equipmentNotFound');
      }

      transaction.update(docRef, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}