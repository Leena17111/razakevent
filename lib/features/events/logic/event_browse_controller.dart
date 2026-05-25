import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../data/models/event_model.dart';

class EventBrowseController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<EventModel> get filteredEvents => _filteredEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  static const List<String> categoryKeys = [
    'All',
    'Sports',
    'Academic',
    'Spiritual',
    'Welfare',
    'Entrepreneurship',
    'Culture',
    'Arts & Media',
    'Food',
    'Safety',
    'Others',
  ];

  // Known categories (lowercase for matching) — excludes All and Others
  static final Set<String> _knownCategories = categoryKeys
      .where((k) => k != 'All' && k != 'Others')
      .map((k) => k.toLowerCase())
      .toSet();

  // BM translations map — used by the screen for filter chip labels
  static const Map<String, String> categoryBM = {
    'All': 'Semua',
    'Sports': 'Sukan',
    'Academic': 'Akademik',
    'Spiritual': 'Kerohanian',
    'Welfare': 'Kebajikan',
    'Entrepreneurship': 'Keusahawanan',
    'Culture': 'Kebudayaan',
    'Arts & Media': 'Seni & Media',
    'Food': 'Makanan',
    'Safety': 'Keselamatan',
    'Others': 'Lain-lain',
  };

  // Returns display labels based on current language
  List<String> getCategories(bool isBM) {
    if (!isBM) return categoryKeys;
    return categoryKeys.map((k) => categoryBM[k] ?? k).toList();
  }

  // Returns the selected category display label
  String getSelectedCategoryLabel(bool isBM) {
    if (!isBM) return _selectedCategory;
    return categoryBM[_selectedCategory] ?? _selectedCategory;
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Get all approved document eventIds
      final approvedDocs = await _firestore
          .collection('documents')
          .where('status', isEqualTo: 'Approved')
          .get();

      final approvedEventIds = approvedDocs.docs
          .map((doc) {
            final data = doc.data();
            return data['eventId'] as String?;
          })
          .whereType<String>()
          .toSet();

      if (approvedEventIds.isEmpty) {
        _allEvents = [];
        _applyFilters();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Step 2: Fetch all Open + registrationEnabled events
      final snapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'Open')
          .where('registrationEnabled', isEqualTo: true)
          .get();

      // Step 3: Client-side filter
      _allEvents = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((event) {
            if (!approvedEventIds.contains(event.eventId)) return false;
            if (event.registrationDeadline != null) {
              return event.registrationDeadline!.isAfter(DateTime.now());
            }
            return true;
          })
          .toList();

      _allEvents.sort(
          (a, b) => a.eventDateTime.compareTo(b.eventDateTime));

      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String categoryKey) {
    _selectedCategory = categoryKey;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredEvents = _allEvents.where((event) {
      final matchCategory = _matchesCategory(event);
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          event.title.toLowerCase().contains(q) ||
          event.organizationName.toLowerCase().contains(q);
      return matchCategory && matchSearch;
    }).toList();
  }

  // ── FIX: normalizes "Other" → "Others" and catches anything
  // not in the known list under the "Others" filter chip ──
  bool _matchesCategory(EventModel event) {
    if (_selectedCategory == 'All') return true;

    // Normalize stored value — "Other" (old) treated same as "Others" (new)
    final eventCat = event.category.trim() == 'Other'
        ? 'Others'
        : event.category.trim();

    if (_selectedCategory == 'Others') {
      // Catches "Other", "Others", and anything else not in known list
      return eventCat == 'Others' ||
          !_knownCategories.contains(eventCat.toLowerCase());
    }

    // Case-insensitive exact match for all other categories
    return eventCat.toLowerCase() ==
        _selectedCategory.trim().toLowerCase();
  }

  bool isEventFull(EventModel event) {
    if (event.participantCapacity == null) return false;
    return event.registeredCount >= event.participantCapacity!;
  }

  bool isDeadlinePassed(EventModel event) {
    if (event.registrationDeadline == null) return false;
    return event.registrationDeadline!.isBefore(DateTime.now());
  }

  double getRegistrationProgress(EventModel event) {
    if (event.participantCapacity == null ||
        event.participantCapacity == 0) {
      return 0.0;
    }
    return (event.registeredCount / event.participantCapacity!)
        .clamp(0.0, 1.0);
  }

  int getRemainingSlots(EventModel event) {
    if (event.participantCapacity == null) return 999;
    return (event.participantCapacity! - event.registeredCount)
        .clamp(0, event.participantCapacity!);
  }
}