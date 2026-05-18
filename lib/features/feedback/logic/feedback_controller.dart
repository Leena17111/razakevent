// lib/features/feedback/logic/feedback_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/event_model.dart';

class FeedbackController extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _storage   = FirebaseStorage.instance;
  final _auth      = FirebaseAuth.instance;

  // ── State ────────────────────────────────────────────────────────
  bool _isLoading  = false;
  bool _isSaving   = false;
  String? _errorMessage;
  String? _successMessage;

  EventModel? _selectedEvent;
  final List<String> _customQuestions = [];

  XFile?  _qrCodeFile;
  String? _qrCodeFileName;
  String  _meritLink = '';
  bool    _useQrCode = true;

  List<EventModel> _events = [];

  // ── Getters ──────────────────────────────────────────────────────
  bool     get isLoading      => _isLoading;
  bool     get isSaving       => _isSaving;
  String?  get errorMessage   => _errorMessage;
  String?  get successMessage => _successMessage;
  EventModel? get selectedEvent => _selectedEvent;
  List<String> get customQuestions => List.unmodifiable(_customQuestions);
  XFile?   get qrCodeFile     => _qrCodeFile;
  String?  get qrCodeFileName => _qrCodeFileName;
  String   get meritLink      => _meritLink;
  bool     get useQrCode      => _useQrCode;
  List<EventModel> get events => _events;

  // ── Load Events ──────────────────────────────────────────────────
  Future<void> loadEvents() async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _auth.currentUser?.uid;
      debugPrint('=== FeedbackController: Current UID: $uid ===');

      if (uid == null) throw Exception('Not authenticated');

      final snapshot = await _firestore
      .collection('events')
      .orderBy('createdAt', descending: true)
      .get();

      debugPrint('=== FeedbackController: Events found: ${snapshot.docs.length} ===');

      _events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      debugPrint('=== FeedbackController: Error loading events: $e ===');
      _events = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Select Event ─────────────────────────────────────────────────
  void selectEvent(EventModel event) {
    _selectedEvent = event;
    _errorMessage  = null;
    notifyListeners();
  }

  // ── Custom Questions ─────────────────────────────────────────────
  void addCustomQuestion(String question) {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;
    _customQuestions.add(trimmed);
    notifyListeners();
  }

  void removeCustomQuestion(int index) {
    if (index >= 0 && index < _customQuestions.length) {
      _customQuestions.removeAt(index);
      notifyListeners();
    }
  }

  // ── Merit Mode ───────────────────────────────────────────────────
  void setUseQrCode(bool value) {
    _useQrCode = value;
    notifyListeners();
  }

  void setMeritLink(String value) {
    _meritLink = value;
    notifyListeners();
  }

  // ── QR Code Image ────────────────────────────────────────────────
  Future<void> pickQrCode() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    final bytes    = await picked.readAsBytes();
    final sizeInMb = bytes.length / (1024 * 1024);

    if (sizeInMb > 2) {
      _errorMessage = 'QR code image must be under 2MB.';
      notifyListeners();
      return;
    }

    _qrCodeFile     = picked;
    _qrCodeFileName = picked.name;
    _errorMessage   = null;
    notifyListeners();
  }

  void removeQrCode() {
    _qrCodeFile     = null;
    _qrCodeFileName = null;
    notifyListeners();
  }

  // ── Validate ─────────────────────────────────────────────────────
  bool _validate() {
    if (_selectedEvent == null) {
      _errorMessage = 'Please select an event.';
      notifyListeners();
      return false;
    }
    if (!_useQrCode && _meritLink.trim().isEmpty) {
      _errorMessage =
          'Please paste a merit link or switch to QR upload.';
      notifyListeners();
      return false;
    }
    return true;
  }

  // ── Save Feedback Form ───────────────────────────────────────────
  Future<bool> saveFeedbackForm() async {
    if (!_validate()) return false;

    _isSaving       = true;
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');

      String? qrCodeUrl;

      if (_useQrCode && _qrCodeFile != null) {
        final ref = _storage
            .ref()
            .child('feedback_qr')
            .child(uid!)                          
            .child(
                '${DateTime.now().millisecondsSinceEpoch}_$_qrCodeFileName');

        final bytes = await _qrCodeFile!.readAsBytes();
        await ref.putData(bytes);
        qrCodeUrl = await ref.getDownloadURL();
      }

      await _firestore.collection('feedbackForms').add({
        'eventId':          _selectedEvent!.eventId,
        'eventTitle':       _selectedEvent!.title,
        'organizationName': _selectedEvent!.organizationName,
        'organizationType': _selectedEvent!.organizationType,
        'createdBy':        uid,
        'createdAt':        FieldValue.serverTimestamp(),
        'builtInQuestions': const [
          'How satisfied are you with this event?',
          'Was the event well-organized?',
          'Would you recommend this event to others?',
          'Any additional feedback or suggestions?',
        ],
        'customQuestions': _customQuestions,
        'meritType':       _useQrCode ? 'qr' : 'link',
        'qrCodeUrl':       qrCodeUrl,
        'meritLink':       _useQrCode ? null : _meritLink.trim(),
        'status':          'active',
      });

      _successMessage = 'Feedback form saved successfully!';
      _isSaving       = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('=== FeedbackController: Error saving: $e ===');
      _errorMessage = 'Failed to save. Please try again.';
      _isSaving     = false;
      notifyListeners();
      return false;
    }
  }

  // ── Preview Data ─────────────────────────────────────────────────
  Map<String, dynamic> buildPreviewData(List<String> builtInQuestions) {
    return {
      'eventTitle':       _selectedEvent?.title ?? '—',
      'builtInQuestions': builtInQuestions,
      'customQuestions':  List<String>.from(_customQuestions),
      'meritType':        _useQrCode ? 'QR Code' : 'Merit Link',
      'meritLink':        _useQrCode ? null : _meritLink,
      'hasQr':            _qrCodeFile != null,
    };
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}