import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/event_model.dart';
import '../logic/volunteer_position_controller.dart';
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

class _VolunteerEventSelectScreenState extends State<VolunteerEventSelectScreen> {
  final VolunteerPositionController _controller = VolunteerPositionController();

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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textWhite,
                  size: 20,
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
          const SizedBox(height: 16),
          Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE89A24).withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            l10n.organizerHead,
            style: AppTextStyles.label.copyWith(
              color: const Color(0xFFE89A24),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
          const SizedBox(height: 14),
          Text(
            'Volunteer Recruitment',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textWhite,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedTab == 'add'
                ? l10n.addVolunteerPositionsForYourEvent
                : l10n.reviewVolunteerApplications,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textWhite.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          _buildTabs(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTabButton(
            label: 'Add Positions',
            icon: Icons.add_rounded,
            isActive: _selectedTab == 'add',
            onTap: () => _setTab('add'),
          ),
          _buildTabButton(
            label: 'Review Applications',
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
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.textWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
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
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPositionsTab(AppLocalizations l10n) {
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

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.organizerEvents.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                l10n.selectEvent,
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              );
            }

            final event = _controller.organizerEvents[index - 1];
            return _buildEventCard(event);
          },
        );
      },
    );
  }

  Widget _buildReviewApplicationsTab(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.groups_rounded,
                size: 54,
                color: AppColors.primary.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Review Applications',
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This section will be used later to approve or reject volunteer applications.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(event.eventDateTime),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          l10n.addEventsFirstBeforePositions,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
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