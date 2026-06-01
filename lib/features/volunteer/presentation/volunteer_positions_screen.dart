import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/volunteer_position_model.dart';
import '../logic/volunteer_position_controller.dart';
import 'add_position_screen.dart';

class VolunteerPositionsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final DateTime eventDateTime;

  const VolunteerPositionsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventDateTime,
  });

  @override
  State<VolunteerPositionsScreen> createState() =>
      _VolunteerPositionsScreenState();
}

class _VolunteerPositionsScreenState extends State<VolunteerPositionsScreen> {
  final VolunteerPositionController _controller =
      VolunteerPositionController();

  static const Color _openColor = Color(0xFF2E7D32);
  static const Color _fullColor = Color(0xFFB3261E);
  static const Color _closedColor = Color(0xFF6B7280);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPositionScreen(
                eventId: widget.eventId,
                eventTitle: widget.eventTitle,
                eventDateTime: widget.eventDateTime,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.addNewPosition,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n, currentLocale),
            Expanded(
              child: StreamBuilder<List<VolunteerPositionModel>>(
                stream: _controller.streamPositionsForEvent(widget.eventId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final positions = snapshot.data ?? [];

                  if (positions.isEmpty) {
                    return _buildEmptyState(l10n);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: positions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildPositionCard(positions[index], l10n);
                    },
                  );
                },
              ),
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
          const SizedBox(height: 18),
          Text(
            l10n.volunteerPositions,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textWhite,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.eventTitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textWhite.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCard(
    VolunteerPositionModel position,
    AppLocalizations l10n,
  ) {
    final progress = position.volunteersNeeded == 0
        ? 0.0
        : (position.approvedCount / position.volunteersNeeded).clamp(0.0, 1.0);

    final isFull = position.approvedCount >= position.volunteersNeeded;
    final statusValue = position.status.toLowerCase();

    final Color statusColor;
    final String statusLabel;

    if (isFull || statusValue == 'full') {
      statusColor = _fullColor;
      statusLabel = l10n.full;
    } else if (statusValue == 'open') {
      statusColor = _openColor;
      statusLabel = l10n.open;
    } else {
      statusColor = _closedColor;
      statusLabel = l10n.closed;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  position.roleName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${position.approvedCount}/${position.volunteersNeeded}',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.label.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${position.totalApplications} ${l10n.applications}',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Text(
                'filled',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE8E9F0),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              _miniInfo(
                icon: Icons.people_alt_rounded,
                text: '${position.volunteersNeeded} slots',
              ),
              const SizedBox(width: 8),
              _miniInfo(
                icon: Icons.access_time_rounded,
                text: _formatDate(position.applicationDeadline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
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
                size: 56,
                color: AppColors.primary.withOpacity(0.45),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noPositionsYet,
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tapBelowToAddPosition,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}