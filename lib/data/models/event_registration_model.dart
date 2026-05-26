import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum RegistrationStep { form, payment, success }

class EventRegistrationController extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  RegistrationStep _step = RegistrationStep.form;
  RegistrationStep get step => _step;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

  String _userName = '';
  String _userMatric = '';
  String _userPhone = '';
  String get userName => _userName;
  String get userMatric => _userMatric;
  String get userPhone => _userPhone;

  bool _profileLoaded = false;

  String _selectedFaculty = '';
  String get selectedFaculty => _selectedFaculty;

  Future<void> loadUserProfile() async {
    if (_profileLoaded) return;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final d = doc.data()!;
        _userName = d['fullName'] ?? '';
        _userMatric = d['matricNumber'] ?? '';
        _userPhone = d['phoneNumber'] ?? '';
        _profileLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('loadUserProfile error: $e');
    }
  }

  void setFaculty(String faculty) {
    _selectedFaculty = faculty;
    _fieldErrors.remove('faculty');
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool _validate(bool isEn) {
    _fieldErrors = {};
    if (_selectedFaculty.isEmpty) {
      _fieldErrors['faculty'] =
          isEn ? 'Please select your faculty' : 'Sila pilih fakulti anda';
    }
    notifyListeners();
    return _fieldErrors.isEmpty;
  }

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

  Future<void> _saveFreeRegistration({required String eventId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');

      final eventDoc =
          await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) throw Exception('Event not found.');
      final d = eventDoc.data()!;

      final deadline =
          (d['registrationDeadline'] as Timestamp?)?.toDate();
      if (deadline != null && DateTime.now().isAfter(deadline)) {
        throw Exception('Registration deadline has passed.');
      }

      final capacity = (d['participantCapacity'] as num?)?.toInt() ?? 0;
      final registered = (d['registeredCount'] as num?)?.toInt() ?? 0;
      if (capacity > 0 && registered >= capacity) {
        throw Exception('This event is fully booked.');
      }

      final dup = await _firestore
          .collection('eventRegistrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: uid)
          .get();
      if (dup.docs.isNotEmpty) {
        throw Exception('You have already registered for this event.');
      }

      final batch = _firestore.batch();
      final regRef =
          _firestore.collection('eventRegistrations').doc();
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
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initiateStripePayment({required String eventId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // TODO: Replace with real Stripe + Cloud Function call
      // See STRIPE_SETUP.md for full instructions
      await Future.delayed(const Duration(seconds: 2));
      _step = RegistrationStep.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void goBackToForm() {
    _step = RegistrationStep.form;
    _errorMessage = null;
    notifyListeners();
  }
}