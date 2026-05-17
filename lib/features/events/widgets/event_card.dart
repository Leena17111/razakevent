import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/event_model.dart';
import '../../../l10n/app_localizations.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final dateText = DateFormat('dd MMM yyyy • h:mm a').format(
      event.eventDateTime,
    );

    final registrationText = event.registrationEnabled
        ? '${event.registeredCount}/${event.participantCapacity ?? '-'} ${l10n.registered}'
        : l10n.registrationDisabled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _EventChip(
                      label: event.status,
                      type: _EventChipType.status,
                    ),
                    _EventChip(
                      label: event.category,
                      type: _EventChipType.category,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoLine(
                  icon: Icons.calendar_today_outlined,
                  text: dateText,
                ),
                const SizedBox(height: 6),
                _InfoLine(
                  icon: Icons.location_on_outlined,
                  text: event.venue,
                ),
                const SizedBox(height: 6),
                _InfoLine(
                  icon: Icons.people_alt_outlined,
                  text: registrationText,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onEdit,
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.textWhite,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onDelete,
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.textWhite,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.subtitle.copyWith(fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

enum _EventChipType { status, category }

class _EventChip extends StatelessWidget {
  final String label;
  final _EventChipType type;

  const _EventChip({
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();

    Color bg = AppColors.primarySoft;
    Color fg = AppColors.primary;

    if (type == _EventChipType.status) {
      if (lower == 'open') {
        bg = AppColors.studentBadgeBg;
        fg = AppColors.success;
      } else if (lower == 'draft') {
        bg = AppColors.surfaceSoft;
        fg = AppColors.textSecondary;
      } else if (lower == 'closed') {
        bg = AppColors.borderLight;
        fg = AppColors.textSecondary;
      } else if (lower == 'completed') {
        bg = AppColors.communityBadgeBg;
        fg = AppColors.communityBadgeText;
      }
    } else {
      bg = AppColors.primarySoft;
      fg = AppColors.primaryLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}