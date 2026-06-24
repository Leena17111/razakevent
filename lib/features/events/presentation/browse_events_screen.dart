import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/event_model.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/event_browse_controller.dart';

class BrowseEventsScreen extends StatefulWidget {
  const BrowseEventsScreen({super.key});

  @override
  State<BrowseEventsScreen> createState() => _BrowseEventsScreenState();
}

class _BrowseEventsScreenState extends State<BrowseEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late EventBrowseController _controller;

  // Cache of eventIds the current user has already registered for.
  Set<String> _registeredEventIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = EventBrowseController();
    _controller.loadEvents();
    _searchController.addListener(() {
      _controller.setSearchQuery(_searchController.text);
    });
    _loadRegisteredEventIds();
  }

  /// Fetches all eventIds the current user has registered for so we can
  /// disable the "Details" button / show a badge on already-registered events.
  Future<void> _loadRegisteredEventIds() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('eventRegistrations')
        .where('userId', isEqualTo: uid)
        .get();
    if (!mounted) return;
    setState(() {
      _registeredEventIds = snap.docs
          .map((d) => d.data()['eventId'] as String)
          .toSet();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _getCategoryLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'All':
        return l10n.categoryAll;
      case 'Sports':
        return l10n.categorySports;
      case 'Academic':
        return l10n.categoryAcademic;
      case 'Spiritual':
        return l10n.categorySpiritual;
      case 'Welfare':
        return l10n.categoryWelfare;
      case 'Entrepreneurship':
        return l10n.categoryEntrepreneurship;
      case 'Culture':
        return l10n.categoryCulture;
      case 'Arts & Media':
        return l10n.categoryArtsMedia;
      case 'Food':
        return l10n.categoryFood;
      case 'Safety':
        return l10n.categorySafety;
      case 'Others':
        return l10n.categoryOthers;
      default:
        return key;
    }
  }

  Widget _langButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => localeController.value = Locale(label == 'EN' ? 'en' : 'ms'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(l10n),
              _buildSearchBar(l10n),
              _buildCategoryFilters(l10n),
              Expanded(child: _buildEventsList(l10n)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<Locale>(
            valueListenable: localeController,
            builder: (context, locale, _) {
              final isBM = locale.languageCode == 'ms';
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: [
                        _langButton('EN', !isBM),
                        _langButton('BM', isBM),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.browseEvents,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
                const SizedBox(height: 4),
                Text(
                  l10n.browseEventsSubtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 14),
                _buildTabBar(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIX 2 ── Tab bar: both selected and unselected labels are white;
  // the active tab gets a white pill background with primary-coloured text.
  Widget _buildTabBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(2),
      child: TabBar(
        controller: _tabController,
        // White pill for the active tab
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        // Active label: primary colour (readable on white pill)
        labelColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        // Inactive label: white (readable on translucent dark background)
        unselectedLabelColor: Colors.white,
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        tabs: [
          Tab(text: l10n.browseTab),
          Tab(text: l10n.myRegisteredTab),
        ],
      ),
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────────

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: l10n.searchEvents,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => _searchController.clear(),
                child: const Icon(Icons.close, size: 18, color: Colors.grey),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  // ── Category Filters ────────────────────────────────────────────────────────

  Widget _buildCategoryFilters(AppLocalizations l10n) {
    return Consumer<EventBrowseController>(
      builder: (context, controller, _) {
        final keys = EventBrowseController.categoryKeys;
        return SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final isActive =
                  controller.selectedCategory.trim().toLowerCase() ==
                  key.trim().toLowerCase();
              final label = _getCategoryLabel(key, l10n);
              return GestureDetector(
                onTap: () => controller.setCategory(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Events List ─────────────────────────────────────────────────────────────

  Widget _buildEventsList(AppLocalizations l10n) {
    return Consumer<EventBrowseController>(
      builder: (context, controller, _) {
        return TabBarView(
          controller: _tabController,
          children: [
            _buildBrowseTab(controller, l10n),
            _buildRegisteredTab(controller, l10n),
          ],
        );
      },
    );
  }

  Widget _buildBrowseTab(
  EventBrowseController controller,
  AppLocalizations l10n,
) {
  if (controller.isLoading) return _buildShimmerList();

  if (controller.error != null) {
    return _buildErrorState(controller, l10n);
  }

  final visibleEvents = controller.filteredEvents
      .where((event) => !_registeredEventIds.contains(event.eventId))
      .toList();

  if (visibleEvents.isEmpty) return _buildEmptyState(l10n);

  return RefreshIndicator(
    onRefresh: () async {
      await controller.loadEvents();
      await _loadRegisteredEventIds();
    },
    color: AppColors.primary,
    child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: visibleEvents.length,
      itemBuilder: (context, index) {
        final event = visibleEvents[index];

        return _buildEventCard(event, controller, l10n, index)
            .animate()
            .fadeIn(delay: (index * 60).ms, duration: 400.ms)
            .slideY(begin: 0.15, curve: Curves.easeOut);
      },
    ),
  );
}

  // ── Registered Tab ──────────────────────────────────────────────────────────

  // FIX 3 ── Now takes the controller so the registered-events list can
  // respect the same category/search filters as the Browse tab, instead
  // of unconditionally showing every registered event regardless of the
  // active filter chip.
  Widget _buildRegisteredTab(
    EventBrowseController controller,
    AppLocalizations l10n,
  ) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Center(
        child: Text(
          l10n.noRegisteredEvents,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('eventRegistrations')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, regSnapshot) {
        if (regSnapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerList();
        }

        if (regSnapshot.hasError) {
          return Center(
            child: Text(
              l10n.errorLoadingEvents,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          );
        }

        if (!regSnapshot.hasData || regSnapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 56,
                  color: Colors.grey.shade300,
                ).animate().fadeIn().scale(),
                const SizedBox(height: 12),
                Text(
                  l10n.noRegisteredEvents,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.noRegisteredEventsDesc,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final registrations =
            List<QueryDocumentSnapshot>.from(regSnapshot.data!.docs)
              ..sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aTime =
                    (aData['registeredAt'] as Timestamp?)
                        ?.millisecondsSinceEpoch ??
                    0;
                final bTime =
                    (bData['registeredAt'] as Timestamp?)
                        ?.millisecondsSinceEpoch ??
                    0;
                return bTime.compareTo(aTime);
              });

        final eventIds = registrations
            .map(
              (d) => (d.data() as Map<String, dynamic>)['eventId'] as String?,
            )
            .whereType<String>()
            .toList();

        if (eventIds.isEmpty) {
          return Center(
            child: Text(
              l10n.noRegisteredEvents,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          );
        }

        return StreamBuilder<List<EventModel>>(
          stream: _streamEventsByIds(eventIds),
          builder: (context, eventSnapshot) {
            if (eventSnapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerList();
            }

            if (eventSnapshot.hasError) {
              return Center(
                child: Text(
                  l10n.errorLoadingEvents,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              );
            }

            final events = eventSnapshot.data ?? [];

            if (events.isEmpty) {
              return Center(
                child: Text(
                  l10n.noRegisteredEvents,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              );
            }

            final eventMap = {for (final e in events) e.eventId: e};

            // FIX 3 ── Apply the same category/search filter the Browse
            // tab uses, so picking a category chip (or typing a search
            // query) while on "My Registered" actually narrows this list
            // too, instead of always showing every registered event.
            final orderedEvents = eventIds
                .map((id) => eventMap[id])
                .whereType<EventModel>()
                .where(controller.matchesCurrentFilters)
                .toList();

            if (orderedEvents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.filter_alt_off_outlined,
                      size: 56,
                      color: Colors.grey.shade300,
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noRegisteredEvents,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.noRegisteredEventsDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: orderedEvents.length,
              itemBuilder: (context, index) {
                final event = orderedEvents[index];
                final reg = registrations.firstWhere(
                  (d) =>
                      (d.data() as Map<String, dynamic>)['eventId'] ==
                      event.eventId,
                );
                final regData = reg.data() as Map<String, dynamic>;
                final paymentStatus =
                    regData['paymentStatus'] as String? ?? 'free';
                final registeredAt = (regData['registeredAt'] as Timestamp?)
                    ?.toDate();

                return _buildRegisteredCard(
                      event,
                      paymentStatus,
                      registeredAt,
                      l10n,
                      index,
                    )
                    .animate()
                    .fadeIn(delay: (index * 60).ms, duration: 400.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOut);
              },
            );
          },
        );
      },
    );
  }

  Stream<List<EventModel>> _streamEventsByIds(List<String> eventIds) async* {
  if (eventIds.isEmpty) {
    yield [];
    return;
  }

  final events = <EventModel>[];

  for (var i = 0; i < eventIds.length; i += 10) {
    final end = (i + 10 > eventIds.length) ? eventIds.length : i + 10;
    final chunk = eventIds.sublist(i, end);

    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where(FieldPath.documentId, whereIn: chunk)
        .get();

    events.addAll(
      snap.docs.map((doc) => EventModel.fromFirestore(doc)),
    );
  }

  yield events;
}

  Widget _buildRegisteredCard(
    EventModel event,
    String paymentStatus,
    DateTime? registeredAt,
    AppLocalizations l10n,
    int index,
  ) {
    final isFree = event.registrationFee == 0;
    final isPaid = paymentStatus == 'paid';
    final categoryColor = _getCategoryColor(event.category);

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildPosterImage(event)),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor['bg'],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.category,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: categoryColor['text'],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              l10n.registeredLabel,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.organizationName,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'd MMM yyyy • h:mm a',
                        ).format(event.eventDateTime),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isFree
                              ? const Color(0xFFDBEAFE)
                              : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isFree
                              ? l10n.freeEvent
                              : isPaid
                              ? l10n.paid
                              : 'RM ${event.registrationFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isFree
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                      if (registeredAt != null)
                        Text(
                          '${l10n.registeredOn} ${DateFormat('d MMM yyyy').format(registeredAt)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Event Card ──────────────────────────────────────────────────────────────

  Widget _buildEventCard(
    EventModel event,
    EventBrowseController controller,
    AppLocalizations l10n,
    int index,
  ) {
    final isFull = controller.isEventFull(event);
    final progress = controller.getRegistrationProgress(event);
    final remaining = controller.getRemainingSlots(event);
    final categoryColor = _getCategoryColor(event.category);
    final isFree = event.registrationFee == 0;

    // FIX 1 ── Check if the current user is already registered for this event.
    final alreadyRegistered = _registeredEventIds.contains(event.eventId);

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardImage(
              event,
              isFull,
              isFree,
              remaining,
              categoryColor,
              l10n,
              alreadyRegistered: alreadyRegistered,
            ),
            _buildCardBody(
              event,
              progress,
              isFree,
              l10n,
              alreadyRegistered: alreadyRegistered,
            ),
          ],
        ),
      ),
    );
  }

  // ── Card Image ──────────────────────────────────────────────────────────────

  Widget _buildCardImage(
    EventModel event,
    bool isFull,
    bool isFree,
    int remaining,
    Map<String, Color> categoryColor,
    AppLocalizations l10n, {
    bool alreadyRegistered = false,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: _buildPosterImage(event)),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: categoryColor['bg'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.category,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: categoryColor['text'],
                  ),
                ),
              ),
            ),
            // FIX 1 ── Show "Registered" badge instead of Free/slots badge
            // when the user has already registered.
            if (alreadyRegistered)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        l10n.registeredLabel,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              if (isFree)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.freeEvent,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isFull
                        ? Colors.red.withOpacity(0.9)
                        : Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFull ? l10n.eventFull : '$remaining ${l10n.slotsLeft}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Poster ──────────────────────────────────────────────────────────────────

  Widget _buildPosterImage(EventModel event) {
    final url = event.posterUrl.trim();
    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _posterPlaceholder(),
      );
    }
    return _posterPlaceholder();
  }

  Widget _posterPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 36,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 4),
          Text(
            'No poster',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card Body ────────────────────────────────────────────────────────────────

  Widget _buildCardBody(
    EventModel event,
    double progress,
    bool isFree,
    AppLocalizations l10n, {
    bool alreadyRegistered = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            event.organizationName,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 11,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('d MMM yyyy • h:mm a').format(event.eventDateTime),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 11,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.venue,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (event.participantCapacity != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${event.registeredCount} / ${event.participantCapacity} ${l10n.registeredCount}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isFree
                        ? Colors.green.shade50
                        : const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isFree
                        ? l10n.freeEvent
                        : 'RM ${event.registrationFee.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isFree
                          ? Colors.green.shade700
                          : const Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.8 ? const Color(0xFFC8102E) : AppColors.primary,
                ),
                minHeight: 5,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (event.registrationDeadline != null)
                Text(
                  '${l10n.deadlineLabel}: ${DateFormat('d MMM yyyy').format(event.registrationDeadline!)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFC8102E),
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                const SizedBox(),
              // FIX 1 ── Show "Already Registered" label instead of Details
              // when the user has already registered for this event.
              if (alreadyRegistered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 11,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.registeredLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.eventDetail,
                    arguments: event,
                  ),
                  child: Row(
                    children: [
                      Text(
                        l10n.detailsButton,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── States ──────────────────────────────────────────────────────────────────

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: 4,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 120, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 5,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 56,
            color: Colors.grey.shade300,
          ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 12),
          Text(
            l10n.noEventsAvailable,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 4),
          Text(
            l10n.noEventsDesc,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ).animate().fadeIn(delay: 150.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    EventBrowseController controller,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 56,
            color: Colors.grey.shade300,
          ).animate().fadeIn().shake(),
          const SizedBox(height: 12),
          Text(
            l10n.errorLoadingEvents,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: controller.loadEvents,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(l10n.retryButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Map<String, Color> _getCategoryColor(String category) {
    const colors = {
      'Sports': {'bg': Color(0xFFDBEAFE), 'text': Color(0xFF1D4ED8)},
      'Academic': {'bg': Color(0xFFD1FAE5), 'text': Color(0xFF059669)},
      'Spiritual': {'bg': Color(0xFFE0E7FF), 'text': Color(0xFF6366F1)},
      'Welfare': {'bg': Color(0xFFFCE7F3), 'text': Color(0xFFDB2777)},
      'Entrepreneurship': {'bg': Color(0xFFFEF3C7), 'text': Color(0xFFD97706)},
      'Culture': {'bg': Color(0xFFEDE9FE), 'text': Color(0xFF7C3AED)},
      'Arts & Media': {'bg': Color(0xFFFFE4E6), 'text': Color(0xFFE11D48)},
      'Food': {'bg': Color(0xFFD1FAE5), 'text': Color(0xFF10B981)},
      'Safety': {'bg': Color(0xFFFEE2E2), 'text': Color(0xFFDC2626)},
      'Others': {'bg': Color(0xFFF5F6FA), 'text': Color(0xFF6B7280)},
    };
    return {
      'bg': colors[category]?['bg'] ?? const Color(0xFFF5F6FA),
      'text': colors[category]?['text'] ?? const Color(0xFF6B7280),
    };
  }
}
