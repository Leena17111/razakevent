import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/volunteer_position_model.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/review_applications_controller.dart';
import '../logic/volunteer_position_controller.dart';
import 'review_applications_screen.dart';
import 'volunteer_positions_screen.dart';

class VolunteerEventSelectScreen extends StatefulWidget {
  final String mode;

  const VolunteerEventSelectScreen({
    super.key,
    required this.mode,
  });

  @override
  State<VolunteerEventSelectScreen> createState() =>
      _VolunteerEventSelectScreenState();
}

class _VolunteerEventSelectScreenState
    extends State<VolunteerEventSelectScreen> {
  final VolunteerPositionController _controller =
      VolunteerPositionController();

  final ReviewApplicationsController _reviewController =
      ReviewApplicationsController();

  String? _organizerId;
  late String _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.mode;
    _organizerId = FirebaseAuth.instance.currentUser?.uid;

    if (_organizerId != null) {
      _controller.loadOrganizerEvents(_organizerId!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _setTab(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n, currentLocale),
            Expanded(
              child: _selectedTab == 'add'
                  ? _buildAddPositionsTab(l10n)
                  : _buildReviewApplicationsTab(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, Locale currentLocale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textWhite,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              LanguageToggle(
                selectedLocale: currentLocale,
                onLocaleChanged: (locale) {
                  localeController.value = locale;
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE89A24).withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.organizerHead,
              style: AppTextStyles.label.copyWith(
                color: const Color(0xFFE89A24),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.volunteerManagement,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textWhite,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _selectedTab == 'add'
                ? l10n.addVolunteerPositionsForYourEvent
                : l10n.reviewVolunteerApplications,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textWhite.withOpacity(0.86),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          _buildTabs(l10n),
        ],
      ),
    );
  }

  Widget _buildTabs(AppLocalizations l10n) {
  return Container(
    height: 50,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: AppColors.textWhite.withOpacity(0.14),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        _buildTabButton(
          label: l10n.addVolunteerPosition,
          icon: Icons.add_rounded,
          isActive: _selectedTab == 'add',
          onTap: () => _setTab('add'),
        ),
        const SizedBox(width: 6),
        _buildTabButton(
          label: l10n.reviewVolunteerApplications,
          icon: Icons.groups_rounded,
          isActive: _selectedTab == 'review',
          onTap: () => _setTab('review'),
        ),
      ],
    ),
  );
}

Widget _buildTabButton({
  required String label,
  required IconData icon,
  required bool isActive,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.textWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? AppColors.primary : AppColors.textWhite,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textWhite,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildAddPositionsTab(AppLocalizations l10n) {
    if (_organizerId == null) {
      return _buildEmptyReviewState(l10n.unableToLoadOrganizerAccount);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        if (_controller.isLoadingEvents) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (_controller.hasLoadError) {
          return _buildErrorState(l10n);
        }

        if (_controller.organizerEvents.isEmpty) {
          return _buildEmptyState(l10n);
        }

        return StreamBuilder<List<VolunteerPositionModel>>(
          stream: _reviewController.streamOrganizerVolunteerPositions(
            _organizerId!,
          ),
          builder: (context, snapshot) {
            final allPositions = snapshot.data ?? [];

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              itemCount: _controller.organizerEvents.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 13),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSectionTitle(l10n.selectEvent);
                }

                final event = _controller.organizerEvents[index - 1];

                final eventPositions = allPositions
                    .where((position) => position.eventId == event.eventId)
                    .toList();

                final applicationCount = eventPositions.fold<int>(
                  0,
                  (sum, position) => sum + position.totalApplications,
                );

                return _buildEventCard(
                  icon: Icons.event_rounded,
                  title: event.title,
                  date: event.eventDateTime,
                  positionCount: eventPositions.length,
                  applicationCount: applicationCount,
                  l10n: l10n,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VolunteerPositionsScreen(
                          eventId: event.eventId,
                          eventTitle: event.title,
                          eventDateTime: event.eventDateTime,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReviewApplicationsTab(AppLocalizations l10n) {
    if (_organizerId == null) {
      return _buildEmptyReviewState(l10n.unableToLoadOrganizerAccount);
    }

    return StreamBuilder<List<VolunteerPositionModel>>(
      stream: _reviewController.streamOrganizerVolunteerPositions(
        _organizerId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final positions = snapshot.data ?? [];

        if (positions.isEmpty) {
          return _buildEmptyReviewState(l10n.noVolunteerPositionsForReview);
        }

        final groupedByEvent = <String, List<VolunteerPositionModel>>{};

        for (final position in positions) {
          groupedByEvent.putIfAbsent(position.eventId, () => []);
          groupedByEvent[position.eventId]!.add(position);
        }

        final eventGroups = groupedByEvent.values.toList()
          ..sort(
            (a, b) => a.first.eventTitle.compareTo(b.first.eventTitle),
          );

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          itemCount: eventGroups.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 13),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildSectionTitle(l10n.reviewVolunteerApplications);
            }

            final eventPositions = eventGroups[index - 1];
            return _buildReviewEventCard(eventPositions, l10n);
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 2),
      child: Text(
        title,
        style: AppTextStyles.subtitle.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildReviewEventCard(
    List<VolunteerPositionModel> eventPositions,
    AppLocalizations l10n,
  ) {
    final eventTitle = eventPositions.first.eventTitle;
    final eventDateTime = eventPositions.first.eventDateTime;

    final positionCount = eventPositions.length;
    final applicationCount = eventPositions.fold<int>(
      0,
      (sum, position) => sum + position.totalApplications,
    );

    return _buildEventCard(
      icon: Icons.event_available_rounded,
      title: eventTitle,
      date: eventDateTime,
      positionCount: positionCount,
      applicationCount: applicationCount,
      l10n: l10n,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewApplicationsScreen(
              eventTitle: eventTitle,
              positions: eventPositions,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventCard({
    required IconData icon,
    required String title,
    required DateTime date,
    required int positionCount,
    required int applicationCount,
    required AppLocalizations l10n,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(date),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _statItem(
                          icon: Icons.groups_rounded,
                          value: '$positionCount',
                          label: l10n.positions,
                          color: const Color(0xFFE89A24),
                        ),
                        const SizedBox(width: 16),
                        _statItem(
                          icon: Icons.assignment_rounded,
                          value: '$applicationCount',
                          label: l10n.applications,
                          color: const Color(0xFF19A7A8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return _buildEmptyReviewState(l10n.addEventsFirstBeforePositions);
  }

  Widget _buildEmptyReviewState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_organizerId != null) {
            _controller.loadOrganizerEvents(_organizerId!);
          }
        },
        child: Text(l10n.tryAgain),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}