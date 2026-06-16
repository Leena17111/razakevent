import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/borrowed_equipment_request_model.dart';
import '../models/equipment_model.dart';

import '../models/special_equipment_request_model.dart';

/// Represents a single inventory equipment item from Firestore.
class EquipmentItem {
  final String id;
  final String name;
  final String description;
  final String
  category; // Audio, Presentation, Furniture, Decoration, Sports, Electrical, Others
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
      doc as DocumentSnapshot<Map<String, dynamic>>,
    );
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
  final FirebaseStorage _storage = FirebaseStorage.instance;
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

        eligible.add(
          EligibleEvent(
            id: doc.id,
            name: data['title'] ?? '',
            eventDate: eventDate,
            venue: data['venue'] ?? '',
            borrowedItemsCount: borrowSnap.docs.length,
          ),
        );
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
    required DateTime eventDate,
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
          throw Exception(
            'Equipment ${cartItem.equipment.name} no longer exists.',
          );
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

        final requestRef = _firestore
            .collection('equipmentBorrowRequests')
            .doc();
        transaction.set(requestRef, {
          'eventId': eventId,
          'eventName': eventName,
          'organizerHeadId': user.uid,
          'equipmentId': cartItem.equipment.id,
          'equipmentName': cartItem.equipment.name,
          'category': cartItem.equipment.category,
          'quantity': cartItem.quantity,
          'storageLocation': cartItem.equipment.storageLocation,
          'eventDate': Timestamp.fromDate(eventDate),
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
    SpecialEquipmentRequest request,
  ) async {
    await _firestore
        .collection('specialEquipmentRequests')
        .add(request.toFirestore());
  }

  Stream<List<BorrowedEquipmentRequestModel>> watchBorrowedEquipmentForEvent(
    String eventId,
  ) {
    final userId = currentUserId;
    if (userId.isEmpty) return Stream.value(const []);
    return _firestore
        .collection('equipmentBorrowRequests')
        .where('eventId', isEqualTo: eventId)
        .where('organizerHeadId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          const statuses = {'borrowed', 'returned', 'cancelled'};
          final requests =
              snapshot.docs
                  .where(
                    (doc) =>
                        doc.data()['isSpecialRequest'] != true &&
                        statuses.contains(doc.data()['status']),
                  )
                  .map(BorrowedEquipmentRequestModel.fromFirestore)
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  Stream<List<SpecialEquipmentRequest>> watchSpecialRequestsForEvent(
    String eventId,
  ) {
    final userId = currentUserId;
    if (userId.isEmpty) return Stream.value(const []);
    return _firestore
        .collection('specialEquipmentRequests')
        .where('eventId', isEqualTo: eventId)
        .where('organizerHeadId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          const statuses = {'pending', 'approved', 'rejected', 'cancelled'};
          final requests =
              snapshot.docs
                  .where((doc) => statuses.contains(doc.data()['status']))
                  .map(SpecialEquipmentRequest.fromFirestore)
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  Future<void> cancelBorrowRequest(String requestId) async {
    final requestRef = _firestore
        .collection('equipmentBorrowRequests')
        .doc(requestId);
    await _firestore.runTransaction((transaction) async {
      final request = await transaction.get(requestRef);
      if (!request.exists) throw Exception('Borrow request not found.');
      final data = request.data()!;
      if (data['organizerHeadId'] != currentUserId ||
          data['isSpecialRequest'] == true ||
          data['status'] != 'borrowed') {
        throw Exception('Borrow request cannot be cancelled.');
      }
      DateTime? eventDate = (data['eventDate'] as Timestamp?)?.toDate();
      if (eventDate == null) {
        final eventId = data['eventId'] as String? ?? '';
        final event = await transaction.get(
          _firestore.collection('events').doc(eventId),
        );
        eventDate = (event.data()?['eventDateTime'] as Timestamp?)?.toDate();
      }
      if (eventDate == null ||
          !eventDate.isAfter(DateTime.now().add(const Duration(days: 3)))) {
        throw Exception('Borrow request can no longer be cancelled.');
      }

      final equipmentId = data['equipmentId'] as String? ?? '';
      final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
      final equipmentRef = _firestore.collection('equipment').doc(equipmentId);
      final equipment = await transaction.get(equipmentRef);
      if (!equipment.exists || equipmentId.isEmpty || quantity <= 0) {
        throw Exception('Equipment inventory could not be restored.');
      }
      final borrowed =
          (equipment.data()?['borrowedQuantity'] as num?)?.toInt() ?? 0;
      final updatedBorrowed = borrowed > quantity ? borrowed - quantity : 0;
      transaction.update(requestRef, {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(equipmentRef, {
        'borrowedQuantity': updatedBorrowed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelSpecialRequest(String requestId) async {
    final requestRef = _firestore
        .collection('specialEquipmentRequests')
        .doc(requestId);
    await _firestore.runTransaction((transaction) async {
      final request = await transaction.get(requestRef);
      if (!request.exists) throw Exception('Special request not found.');
      final data = request.data()!;
      if (data['organizerHeadId'] != currentUserId ||
          data['status'] != 'pending') {
        throw Exception('Special request cannot be cancelled.');
      }
      transaction.update(requestRef, {
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> returnBorrowedEquipment(
    String requestId,
    String equipmentId,
    int quantity,
    XFile evidenceFile,
  ) async {
    final userId = currentUserId;
    if (userId.isEmpty) throw Exception('Not authenticated');

    final extension = evidenceFile.name.split('.').last.toLowerCase();
    final storageRef = _storage
        .ref()
        .child('equipment_return_evidence')
        .child(userId)
        .child(requestId)
        .child('${DateTime.now().millisecondsSinceEpoch}.$extension');
    final upload = await storageRef.putData(
      await evidenceFile.readAsBytes(),
      SettableMetadata(contentType: evidenceFile.mimeType ?? 'image/jpeg'),
    );
    final evidenceUrl = await upload.ref.getDownloadURL();

    final requestRef = _firestore
        .collection('equipmentBorrowRequests')
        .doc(requestId);
    final equipmentRef = _firestore.collection('equipment').doc(equipmentId);
    try {
      await _firestore.runTransaction((transaction) async {
        final request = await transaction.get(requestRef);
        final equipment = await transaction.get(equipmentRef);
        if (!request.exists || !equipment.exists) {
          throw Exception('Borrow request or equipment not found.');
        }
        final data = request.data()!;
        final requestQuantity = (data['quantity'] as num?)?.toInt() ?? 0;
        if (data['organizerHeadId'] != userId ||
            data['isSpecialRequest'] == true ||
            data['status'] != 'borrowed' ||
            data['equipmentId'] != equipmentId ||
            requestQuantity != quantity ||
            requestQuantity <= 0) {
          throw Exception('Borrow request is no longer returnable.');
        }
        final borrowed =
            (equipment.data()?['borrowedQuantity'] as num?)?.toInt() ?? 0;
        final updatedBorrowed = borrowed > requestQuantity
            ? borrowed - requestQuantity
            : 0;
        transaction.update(requestRef, {
          'status': 'returned',
          'returnEvidenceUrl': evidenceUrl,
          'returnEvidencePath': upload.ref.fullPath,
          'returnedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(equipmentRef, {
          'borrowedQuantity': updatedBorrowed,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (_) {
      await upload.ref.delete().catchError((_) {});
      rethrow;
    }
  }

<<<<<<< Updated upstream
  // Completed Events With Borrowed Items

  /// Fetches past events (eventDateTime in past OR status == 'Completed')
  /// that have at least one borrow request (regular or special).
  Future<List<EligibleEvent>> fetchCompletedEventsWithBorrowedItems() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final now = DateTime.now();

    // 4 parallel queries instead of N×2 sequential ones
    final results = await Future.wait([
      // Query 1: completed status events
      _firestore
          .collection('events')
          .where('createdBy', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Completed')
          .get(),
      // Query 2: all events by this user (we filter by past date in Dart)
      _firestore
          .collection('events')
          .where('createdBy', isEqualTo: user.uid)
          .get(),
      // Query 3: all borrow requests by this user
      _firestore
          .collection('equipmentBorrowRequests')
          .where('organizerHeadId', isEqualTo: user.uid)
          .get(),
      // Query 4: all special requests by this user
      _firestore
          .collection('specialEquipmentRequests')
          .where('organizerHeadId', isEqualTo: user.uid)
          .get(),
    ]);

    // Build sets of eventIds that have at least one borrow or special request
    final borrowedEventIds = results[2].docs.map((d) => d.data()['eventId'] as String? ?? '').toSet();
    final specialEventIds = results[3].docs.map((d) => d.data()['eventId'] as String? ?? '').toSet();
    final allBorrowedEventIds = {...borrowedEventIds, ...specialEventIds};

    // Count per event for borrowedItemsCount
    final borrowCountMap = <String, int>{};
    for (final doc in results[2].docs) {
      final id = doc.data()['eventId'] as String? ?? '';
      borrowCountMap[id] = (borrowCountMap[id] ?? 0) + 1;
    }
    for (final doc in results[3].docs) {
      final id = doc.data()['eventId'] as String? ?? '';
      borrowCountMap[id] = (borrowCountMap[id] ?? 0) + 1;
    }

    // Merge and deduplicate events
    final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> merged = {};
    for (final doc in results[0].docs) {
      merged[doc.id] = doc;
    }
    for (final doc in results[1].docs) {
      final ts = doc.data()['eventDateTime'];
      if (ts is Timestamp && ts.toDate().isBefore(now)) {
        merged[doc.id] = doc;
      }
    }

    final List<EligibleEvent> result = [];

    for (final doc in merged.values) {
      // Skip if no borrow activity
      if (!allBorrowedEventIds.contains(doc.id)) continue;

      final data = doc.data();
      final Timestamp? ts = data['eventDateTime'] as Timestamp?;
      if (ts == null) continue;

      result.add(EligibleEvent(
        id: doc.id,
        name: data['title'] ?? '',
        eventDate: ts.toDate(),
        venue: data['venue'] ?? '',
        borrowedItemsCount: borrowCountMap[doc.id] ?? 0,
      ));
    }

    result.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return result;
=======
  // ── Admin: Review Special Requests ───────────────────────────────────────

  /// Streams ALL special equipment requests for admin review, ordered newest first.
  Stream<List<SpecialEquipmentRequest>> watchAllSpecialRequests() {
    return _firestore
        .collection('specialEquipmentRequests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map(SpecialEquipmentRequest.fromFirestore)
            .toList());
  }

  /// Approves a special equipment request.
  /// [location] is where the item can be collected (required).
  /// [note] is an optional message to the organizer.
  Future<void> approveSpecialRequest({
    required String requestId,
    required String location,
    String? note,
  }) async {
    await _firestore
        .collection('specialEquipmentRequests')
        .doc(requestId)
        .update({
      'status': 'approved',
      'approvalLocation': location.trim(),
      'adminNote': note?.trim().isNotEmpty == true ? note!.trim() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Rejects a special equipment request with a mandatory reason.
  Future<void> rejectSpecialRequest({
    required String requestId,
    required String reason,
  }) async {
    await _firestore
        .collection('specialEquipmentRequests')
        .doc(requestId)
        .update({
      'status': 'rejected',
      'adminNote': reason.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
>>>>>>> Stashed changes
  }
}
