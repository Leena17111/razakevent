import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum RegistrationStep { form, payment, success }

class EventRegistrationController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  RegistrationStep _step = RegistrationStep.form;
  RegistrationStep get step => _step;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => Map.unmodifiable(_fieldErrors);

  // Profile fields — loaded once from Firestore.
  String _userName = '';
  String _userMatric = '';
  String _userPhone = '';
  String get userName => _userName;
  String get userMatric => _userMatric;
  String get userPhone => _userPhone;

  bool _profileLoaded = false;

  String _selectedFaculty = '';
  String get selectedFaculty => _selectedFaculty;

  // ---------------------------------------------------------------------------
  // Profile loading
  // ---------------------------------------------------------------------------

  Future<void> loadUserProfile() async {
    if (_profileLoaded) return;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final d = doc.data()!;
        _userName = (d['fullName'] as String?) ?? '';
        _userMatric = (d['matricNumber'] as String?) ?? '';
        _userPhone = (d['phoneNumber'] as String?) ?? '';
        _profileLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('EventRegistrationController.loadUserProfile error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Field setters
  // ---------------------------------------------------------------------------

  void setFaculty(String faculty) {
    _selectedFaculty = faculty;
    _fieldErrors.remove('faculty');
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Form → next step
  // ---------------------------------------------------------------------------

  /// Called when the user taps the primary button on the form step.
  ///
  /// • Free event  → validate → save to Firestore → show success.
  /// • Paid event  → validate → advance to payment step (Stripe, TBD).
  Future<void> proceedFromForm({
    required bool isFreeEvent,
    required bool isEn,
    required String eventId,
  }) async {
    if (!_validate(isEn)) return;

    if (isFreeEvent) {
      await _saveFreeRegistration(eventId: eventId);
    } else {
      _step = RegistrationStep.payment;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Free registration — writes to Firestore atomically.
  // ---------------------------------------------------------------------------

  Future<void> _saveFreeRegistration({required String eventId}) async {
    _setLoading(true);

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');

      // 1. Load the event to check capacity and deadline.
      final eventDoc =
          await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) throw Exception('Event not found.');
      final d = eventDoc.data()!;

      // 2. Deadline guard.
      final deadline = _toDateTime(d['registrationDeadline']);
      if (deadline != null && DateTime.now().isAfter(deadline)) {
        throw Exception('Registration deadline has passed.');
      }

      // 3. Capacity guard.
      final capacity = _toInt(d['participantCapacity']) ?? 0;
      final registered = _toInt(d['registeredCount']) ?? 0;
      if (capacity > 0 && registered >= capacity) {
        throw Exception('This event is fully booked.');
      }

      // 4. Duplicate check.
      final dup = await _firestore
          .collection('eventRegistrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();
      if (dup.docs.isNotEmpty) {
        throw Exception('You have already registered for this event.');
      }

      // 5. Atomic batch write.
      final batch = _firestore.batch();

      final regRef = _firestore.collection('eventRegistrations').doc();
      batch.set(regRef, {
        'eventId': eventId,
        'userId': uid,
        'fullName': _userName,
        'matricNumber': _userMatric,
        'phoneNumber': _userPhone,
        'faculty': _selectedFaculty,
        'paymentStatus': 'free',
        'registeredAt': FieldValue.serverTimestamp(),
      });

      batch.update(_firestore.collection('events').doc(eventId), {
        'registeredCount': FieldValue.increment(1),
      });

      await batch.commit();

      _step = RegistrationStep.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Paid registration — Stripe (to be implemented).
  // ---------------------------------------------------------------------------

  /// Placeholder for the Stripe Cloud Function call.
  /// The UI navigates to the payment step; this method is called when the user
  /// taps "Pay with Stripe" inside the payment step.
  Future<void> initiateStripePayment({required String eventId}) async {
    _setLoading(true);

    try {
      // TODO: Replace with real Stripe + Cloud Function call.
      // See STRIPE_SETUP.md for full instructions.
      await Future.delayed(const Duration(seconds: 2));
      _step = RegistrationStep.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  void goBackToForm() {
    _step = RegistrationStep.form;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  bool _validate(bool isEn) {
    _fieldErrors = {};
    if (_selectedFaculty.isEmpty) {
      _fieldErrors['faculty'] =
          isEn ? 'Please select your faculty' : 'Sila pilih fakulti anda';
    }
    notifyListeners();
    return _fieldErrors.isEmpty;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}