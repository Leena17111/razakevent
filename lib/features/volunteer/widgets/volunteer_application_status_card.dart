import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/volunteer_application_model.dart';
import '../../../l10n/app_localizations.dart';

class VolunteerApplicationStatusCard extends StatefulWidget {
  final VolunteerApplicationModel application;

  const VolunteerApplicationStatusCard({
    super.key,
    required this.application,
  });

  @override
  State<VolunteerApplicationStatusCard> createState() =>
      _VolunteerApplicationStatusCardState();
}

class _VolunteerApplicationStatusCardState
    extends State<VolunteerApplicationStatusCard> {
  bool _showRejectionReason = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final app = widget.application;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.positionRoleName,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app.eventTitle,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        app.organizationName,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _ApplicationStatusBadge(status: app.status),
              ],
            ),
            const SizedBox(height: 10),
            if (app.appliedAt != null)
              Text(
                '${l10n.registeredOn}: ${DateFormat('d MMM yyyy').format(app.appliedAt!)}',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            if (app.status == VolunteerApplicationStatus.rejected &&
                app.rejectionReason != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(
                  () => _showRejectionReason = !_showRejectionReason,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      l10n.rejectionReason,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showRejectionReason
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
              if (_showRejectionReason) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    app.rejectionReason!,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12.5,
                      color: AppColors.accent,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ApplicationStatusBadge extends StatelessWidget {
  final String status;

  const _ApplicationStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final Color bg;
    final Color textColor;
    final IconData icon;
    final String label;

    switch (status) {
      case VolunteerApplicationStatus.approved:
        bg = AppColors.studentBadgeBg;
        textColor = AppColors.studentBadgeText;
        icon = Icons.check_circle_rounded;
        label = l10n.statusApproved;
        break;
      case VolunteerApplicationStatus.rejected:
        bg = AppColors.adminBadgeBg;
        textColor = AppColors.adminBadgeText;
        icon = Icons.cancel_rounded;
        label = l10n.statusRejected;
        break;
      default:
        bg = AppColors.clubBadgeBg;
        textColor = AppColors.clubBadgeText;
        icon = Icons.access_time_rounded;
        label = l10n.statusPendingReview;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}