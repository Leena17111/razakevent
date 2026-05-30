import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/volunteer_position_model.dart';

class VolunteerPositionCard extends StatelessWidget {
  final VolunteerPositionModel position;
  final VoidCallback onApply;

  const VolunteerPositionCard({
    super.key,
    required this.position,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final status = position.status.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                        position.roleName,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        position.eventTitle,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        position.organizerId,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _StatusBadge(
                  status: position.status,
                  isFull: position.isFull,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              position.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REQUIREMENTS',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    position.requirements,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  size: 15,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  '${position.approvedCount}/${position.volunteersNeeded} slots',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  DateFormat('d MMM yyyy').format(position.applicationDeadline),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: position.fillRatio,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  position.isFull ? AppColors.accent : AppColors.primary,
                ),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: position.isOpen ? onApply : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.surfaceSoft,
                  disabledForegroundColor: AppColors.textMuted,
                  foregroundColor: AppColors.textWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  position.isFull
                      ? 'Full'
                      : status == 'closed'
                          ? 'Closed'
                          : 'Apply',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 15,
                    color: position.isOpen
                        ? AppColors.textWhite
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isFull;

  const _StatusBadge({
    required this.status,
    required this.isFull,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();

    final Color bg;
    final Color textColor;
    final String label;

    if (isFull || normalizedStatus == 'full') {
      bg = AppColors.adminBadgeBg;
      textColor = AppColors.adminBadgeText;
      label = 'Full';
    } else if (normalizedStatus == 'closed') {
      bg = AppColors.surfaceSoft;
      textColor = AppColors.textMuted;
      label = 'Closed';
    } else {
      bg = AppColors.studentBadgeBg;
      textColor = AppColors.studentBadgeText;
      label = 'Open';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}