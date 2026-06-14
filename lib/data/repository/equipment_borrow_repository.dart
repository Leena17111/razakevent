import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/equipment_model.dart';

import '../models/special_equipment_request_model.dart';

/// Represents a single inventory equipment item from Firestore.
class EquipmentItem {
  final String id;
  final String name;
  final String description;
  final String category; // Audio, Presentation, Furniture, Decoration, Sports, Electrical, Others
  final int totalQuantity;
  final int availableQuantity;
  final String storageLocation;

  const EquipmentItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.totalQuantity,
    required this.availableQuantity,
    this.storageLocation = '',
  });

  factory EquipmentItem.fromFirestore(DocumentSnapshot doc) {
    final m = EquipmentModel.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>);
    return EquipmentItem(
      id: m.equipmentId,
      name: m.itemName,
      description: m.description,
      category: m.category,
      totalQuantity: m.totalQuantity,
      availableQuantity: m.availableQuantity,
      storageLocation: m.storageLocation,
    );
  }
}

/// Represents an eligible event that an organizer head can borrow equipment for.
class EligibleEvent {
  final String id;
  final String name;
  final DateTime eventDate;
  final String venue;
  final int borrowedItemsCount;

  const EligibleEvent({
    required this.id,
    required this.name,
    required this.eventDate,
    required this.venue,
    required this.borrowedItemsCount,
  });
}

/// Represents one item in the organizer head's borrow cart (in-stock).
class BorrowCartItem {
  final EquipmentItem equipment;
  int quantity;

  BorrowCartItem({required this.equipment, required this.quantity});
}

class EquipmentBorrowRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Eligible Events 

  /// Fetches events organized by the current user that fall within the next
  /// 3 days (inclusive). Events further away are excluded so equipment cannot
  /// be hoarded for distant dates.
  Future<List<EligibleEvent>> fetchEligibleEvents() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day + 3, 23, 59, 59);

    // Fetch events where this user is the organizer head and the event date
    // is within the next 3 days.
    final snapshot = await _firestore
        .collection('events')
        .where('createdBy', isEqualTo: user.uid)
        .where('status', whereIn: ['Open', 'Draft'])
        .get();

    final List<EligibleEvent> eligible = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final Timestamp? ts = data['eventDateTime'] as Timestamp?;
      if (ts == null) continue;
      final eventDate = ts.toDate();

      // Only include events whose date is today or within the next 3 days.
      if (eventDate.isAfter(now) && eventDate.isBefore(cutoff)) {
        // Count borrowed items for this event (in-stock borrow requests).
        final borrowSnap = await _firestore
            .collection('equipmentBorrowRequests')
            .where('eventId', isEqualTo: doc.id)
            .where('organizerHeadId', isEqualTo: user.uid)
            .get();

        eligible.add(EligibleEvent(
          id: doc.id,
          name: data['title'] ?? '',
          eventDate: eventDate,
          venue: data['venue'] ?? '',
          borrowedItemsCount: borrowSnap.docs.length,
        ));
      }
    }

    // Sort by soonest first.
    eligible.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return eligible;
  }

  // Available Equipment

  /// Fetches all equipment items that have at least 1 unit available.
  Future<List<EquipmentItem>> fetchAvailableEquipment() async {
    final snapshot = await _firestore
        .collection('equipment')
        .where('status', isEqualTo: EquipmentStatus.active)
        .get();

    return snapshot.docs
        .map((doc) {
          final m = EquipmentModel.fromFirestore(doc);
          return EquipmentItem(
            id: m.equipmentId,
            name: m.itemName,
            description: m.description,
            category: m.category,
            totalQuantity: m.totalQuantity,
            availableQuantity: m.availableQuantity,
            storageLocation: m.storageLocation,
          );
        })
        .where((item) => item.availableQuantity > 0)
        .toList();
  }

  // Submit Borrow Request (in-stock)

  /// Submits a borrow request for a list of in-stock items for the given event.
  /// Each item has its availableQuantity decremented atomically via a batch.
  Future<void> submitBorrowRequest({
    required String eventId,
    required String eventName,
    required List<BorrowCartItem> cartItems,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _firestore.runTransaction((transaction) async {
      // First pass: read all inventory docs and validate availability.
      final inventoryRefs = cartItems
          .map((ci) => _firestore.collection('equipment').doc(ci.equipment.id))
          .toList();

      final snapshots = await Future.wait(
        inventoryRefs.map((ref) => transaction.get(ref)),
      );

      for (int i = 0; i < cartItems.length; i++) {
        final cartItem = cartItems[i];
        final snap = snapshots[i];

        if (!snap.exists) {
          throw Exception('Equipment ${cartItem.equipment.name} no longer exists.');
        }

        final data = snap.data() as Map<String, dynamic>;
        final total = (data['totalQuantity'] as num?)?.toInt() ?? 0;
        final borrowed = (data['borrowedQuantity'] as num?)?.toInt() ?? 0;
        final available = total - borrowed;

        if (cartItem.quantity > available) {
          throw Exception(
            'Not enough stock for ${cartItem.equipment.name}. '
            'Only $available unit(s) available.',
          );
        }
      }

      // Second pass: write borrow request docs and update inventory.
      for (int i = 0; i < cartItems.length; i++) {
        final cartItem = cartItems[i];

        final requestRef =
            _firestore.collection('equipmentBorrowRequests').doc();
        transaction.set(requestRef, {
          'eventId': eventId,
          'eventName': eventName,
          'organizerHeadId': user.uid,
          'equipmentId': cartItem.equipment.id,
          'equipmentName': cartItem.equipment.name,
          'category': cartItem.equipment.category,
          'quantity': cartItem.quantity,
          'status': 'borrowed',
          'isSpecialRequest': false,
          'returnedAt': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.update(inventoryRefs[i], {
          'borrowedQuantity': FieldValue.increment(cartItem.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Submit Special Equipment

  /// Creates a special equipment request (item not in inventory).
  /// Starts with status = 'pending' for admin review.
  Future<void> submitSpecialEquipmentRequest(
      SpecialEquipmentRequest request) async {
    await _firestore
        .collection('specialEquipmentRequests')
        .add(request.toFirestore());
  }
}







