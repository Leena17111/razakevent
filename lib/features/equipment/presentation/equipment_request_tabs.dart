import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/borrowed_equipment_request_model.dart';
import '../../../data/models/special_equipment_request_model.dart';
import '../../../data/repository/equipment_borrow_repository.dart';
import '../../../l10n/app_localizations.dart';
import 'return_borrowed_equipment_screen.dart';

class BorrowedEquipmentTab extends StatefulWidget {
  final EligibleEvent event;
  final EquipmentBorrowRepository repository;
  final VoidCallback onInventoryChanged;
  final bool isCompleted;

  const BorrowedEquipmentTab({
    super.key,
    required this.event,
    required this.repository,
    required this.onInventoryChanged,
    this.isCompleted = false,
  });

  @override
  State<BorrowedEquipmentTab> createState() => _BorrowedEquipmentTabState();
}

class _BorrowedEquipmentTabState extends State<BorrowedEquipmentTab> {
  String _filter = 'all';

  bool _canCancel(DateTime eventDate) {
    return eventDate.isAfter(DateTime.now().add(const Duration(hours: 24)));
  }

  Future<void> _cancel(
    BorrowedEquipmentRequestModel request,
    DateTime eventDate,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_canCancel(eventDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.borrowCancelBlocked),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await widget.repository.cancelBorrowRequest(request.id);
      if (!mounted) return;
      widget.onInventoryChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.borrowCancelSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _canCancel(eventDate)
                ? l10n.borrowCancelError
                : l10n.borrowCancelBlocked,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<DateTime>(
      stream: widget.repository.watchEventDate(
        widget.event.id,
        widget.event.eventDate,
      ),
      builder: (context, eventDateSnapshot) {
        final currentEventDate =
            eventDateSnapshot.data ?? widget.event.eventDate;
        if (eventDateSnapshot.hasError) {
          return Center(child: Text(l10n.borrowedLoadError));
        }
        if (eventDateSnapshot.connectionState == ConnectionState.waiting &&
            !eventDateSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<BorrowedEquipmentRequestModel>>(
          stream: widget.repository.watchBorrowedEquipmentForEvent(
            widget.event.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(l10n.borrowedLoadError));
            }
            final all = snapshot.data ?? const [];
            final items = _filter == 'all'
                ? all
                : all.where((item) => item.status == _filter).toList();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _BorrowedPolicyNote(
                    text: l10n.borrowedReturnPolicyNote,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _FilterBar(
                    selected: _filter,
                    filters: {
                      'all': l10n.borrowFilterAll,
                      'borrowed': l10n.borrowFilterBorrowed,
                      'returned': l10n.borrowFilterReturned,
                    },
                    onSelected: (value) => setState(() => _filter = value),
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? _EmptyState(
                          icon: Icons.inventory_2_outlined,
                          text: l10n.borrowedEmpty,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final request = items[index];
                            final arguments = ReturnBorrowedEquipmentArguments(
                              request: request,
                              eventDate: currentEventDate,
                            );
                            return _BorrowedCard(
                              request: request,
                              eventDate: currentEventDate,
                              isCompleted: widget.isCompleted,
                              onCancel: () =>
                                  _cancel(request, currentEventDate),
                              onReturn: () async {
                                final returned = await Navigator.of(context)
                                    .push<bool>(
                                      MaterialPageRoute<bool>(
                                        settings: RouteSettings(
                                          name:
                                              AppRoutes.returnBorrowedEquipment,
                                          arguments: arguments,
                                        ),
                                        builder: (_) =>
                                            ReturnBorrowedEquipmentScreen(
                                              request: arguments.request,
                                              eventDate: arguments.eventDate,
                                            ),
                                      ),
                                    );
                                if (returned == true && mounted) {
                                  widget.onInventoryChanged();
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class SpecialRequestsTab extends StatefulWidget {
  final EligibleEvent event;
  final EquipmentBorrowRepository repository;
  final bool isCompleted;

  const SpecialRequestsTab({
    super.key,
    required this.event,
    required this.repository,
    this.isCompleted = false,
  });

  @override
  State<SpecialRequestsTab> createState() => _SpecialRequestsTabState();
}

class _SpecialRequestsTabState extends State<SpecialRequestsTab> {
  String _filter = 'all';

  Future<void> _cancel(SpecialEquipmentRequest request) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await widget.repository.cancelSpecialRequest(request.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.specialCancelSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.specialCancelError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<SpecialEquipmentRequest>>(
      stream: widget.repository.watchSpecialRequestsForEvent(widget.event.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(l10n.specialRequestsLoadError));
        }
        final all = snapshot.data ?? const [];
        final items = _filter == 'all'
            ? all
            : all.where((item) => item.status == _filter).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FilterBar(
                selected: _filter,
                filters: {
                  'all': l10n.borrowFilterAll,
                  'pending': l10n.specialFilterPending,
                  'approved': l10n.specialFilterApproved,
                  'rejected': l10n.specialFilterRejected,
                },
                onSelected: (value) => setState(() => _filter = value),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? _EmptyState(
                      icon: Icons.playlist_add_check_circle_outlined,
                      text: l10n.specialRequestsEmpty,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _SpecialRequestCard(
                        request: items[index],
                        isCompleted: widget.isCompleted,
                        onCancel: () => _cancel(items[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final Map<String, String> filters;
  final ValueChanged<String> onSelected;

  const _FilterBar({
    required this.selected,
    required this.filters,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        children: filters.entries.map((entry) {
          final active = entry.key == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: active,
              onSelected: (_) => onSelected(entry.key),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: AppTextStyles.caption.copyWith(
                color: active ? AppColors.textWhite : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BorrowedCard extends StatelessWidget {
  final BorrowedEquipmentRequestModel request;
  final DateTime eventDate;
  final bool isCompleted;
  final VoidCallback onCancel;
  final VoidCallback onReturn;

  const _BorrowedCard({
    required this.request,
    required this.eventDate,
    this.isCompleted = false,
    required this.onCancel,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final returnDeadline = eventDate.add(const Duration(hours: 24));
    final isBorrowed = request.status == 'borrowed';
    final isOverdue = isBorrowed && DateTime.now().isAfter(returnDeadline);
    final canCancel = eventDate.isAfter(
      DateTime.now().add(const Duration(hours: 24)),
    );
    final deadlineText = DateFormat(
      'd MMM yyyy, h:mm a',
      l10n.localeName,
    ).format(returnDeadline);
    return _EquipmentCard(
      icon: _categoryIcon(request.category),
      iconColor: _categoryColor(request.category),
      title: request.equipmentName,
      quantity: request.quantity,
      date: request.createdAt,
      status: isOverdue ? 'overdue' : request.status,
      children: [
        if (isBorrowed) ...[
          const SizedBox(height: 10),
          _ReturnDeadlineLine(text: l10n.returnBy(deadlineText)),
        ],
        if (isOverdue) ...[
          const SizedBox(height: 10),
          _ReturnReminder(message: l10n.returnRequiredMessage),
        ],
        if (isBorrowed) ...[
          const Divider(height: 22, color: AppColors.borderLight),
          Row(
            children: [
              Expanded(
                child: _OutlinedActionButton(
                  label: l10n.returnEquipmentAction,
                  icon: Icons.check_circle_outline,
                  color: isOverdue ? AppColors.error : AppColors.success,
                  onPressed: onReturn,
                ),
              ),
              if (!isCompleted && canCancel) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _OutlinedActionButton(
                    label: l10n.cancelRequest,
                    icon: Icons.close,
                    color: AppColors.error,
                    onPressed: onCancel,
                  ),
                ),
              ],
            ],
          ),
          if (!isCompleted && !canCancel) ...[
            const SizedBox(height: 10),
            _ReturnReminder(message: l10n.borrowCancelBlocked),
          ],
        ],
      ],
    );
  }
}

class _BorrowedPolicyNote extends StatelessWidget {
  final String text;

  const _BorrowedPolicyNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_outlined,
            size: 15,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySm.copyWith(
                color: const Color(0xFF1E40AF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReturnDeadlineLine extends StatelessWidget {
  final String text;

  const _ReturnDeadlineLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.event_available_outlined,
          size: 15,
          color: Color(0xFF475569),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySm.copyWith(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReturnReminder extends StatelessWidget {
  final String message;

  const _ReturnReminder({required this.message});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFB91C1C);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_none_outlined, size: 15, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySm.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialRequestCard extends StatelessWidget {
  final SpecialEquipmentRequest request;
  final bool isCompleted;
  final VoidCallback onCancel;

  const _SpecialRequestCard({
    required this.request,
    this.isCompleted = false,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final note =
        request.status == 'rejected' &&
            (request.adminNote?.trim().isNotEmpty ?? false)
        ? request.adminNote!.trim()
        : request.reason.trim();
    return _EquipmentCard(
      icon: Icons.inventory_2_outlined,
      iconColor: request.status == 'rejected'
          ? const Color(0xFFF59E0B)
          : const Color(0xFF64748B),
      title: request.itemName,
      quantity: request.quantityRequired,
      date: request.createdAt,
      status: request.status,
      specialBadge: l10n.specialRequestBadge,
      children: [
        if (note.isNotEmpty) ...[
          const SizedBox(height: 10),
          _RequestNote(text: note, isRejected: request.status == 'rejected'),
        ],
        if (request.status == 'pending' && !isCompleted) ...[
          const Divider(height: 22, color: AppColors.borderLight),
          SizedBox(
            width: double.infinity,
            child: _OutlinedActionButton(
              label: l10n.cancelRequest,
              icon: Icons.close,
              color: AppColors.error,
              onPressed: onCancel,
            ),
          ),
        ],
      ],
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int quantity;
  final DateTime date;
  final String status;
  final String? specialBadge;
  final List<Widget> children;

  const _EquipmentCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.quantity,
    required this.date,
    required this.status,
    this.specialBadge,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF171717),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${l10n.borrowQuantityShort}: $quantity · ${DateFormat('d MMM yyyy').format(date)}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    if (specialBadge != null) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF7C3AED),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          specialBadge!,
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF7C3AED),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: status),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = _statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 12, color: colors.foreground),
          const SizedBox(width: 4),
          Text(
            _statusLabel(l10n, status),
            style: AppTextStyles.caption.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _OutlinedActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        textStyle: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

class _RequestNote extends StatelessWidget {
  final String text;
  final bool isRejected;

  const _RequestNote({required this.text, required this.isRejected});

  @override
  Widget build(BuildContext context) {
    final color = isRejected
        ? const Color(0xFFEF4444)
        : AppColors.textSecondary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isRejected ? const Color(0xFFFFF1F2) : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRejected ? Icons.cancel_outlined : Icons.notes_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySm.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.border),
          const SizedBox(height: 10),
          Text(text, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'audio':
      return Icons.mic_none_outlined;
    case 'furniture':
      return Icons.chair_outlined;
    case 'presentation':
      return Icons.present_to_all_outlined;
    case 'electrical':
      return Icons.electrical_services_outlined;
    default:
      return Icons.inventory_2_outlined;
  }
}

Color _categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'audio':
      return const Color(0xFF7C3AED);
    case 'furniture':
      return const Color(0xFFF59E0B);
    case 'presentation':
      return const Color(0xFF2563EB);
    case 'electrical':
      return const Color(0xFF64748B);
    default:
      return AppColors.primary;
  }
}

String _statusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'borrowed':
      return l10n.statusBorrowed;
    case 'overdue':
      return l10n.statusOverdue;
    case 'returned':
      return l10n.statusReturned;
    case 'approved':
      return l10n.statusApprovedEquipment;
    case 'rejected':
      return l10n.statusRejectedEquipment;
    case 'cancelled':
      return l10n.statusCancelled;
    default:
      return l10n.statusPendingEquipment;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'returned':
      return Icons.task_alt;
    case 'rejected':
    case 'cancelled':
      return Icons.cancel_outlined;
    case 'overdue':
      return Icons.warning_amber_rounded;
    case 'approved':
      return Icons.check_circle_outline;
    default:
      return Icons.info_outline;
  }
}

({Color background, Color foreground}) _statusColors(String status) {
  switch (status) {
    case 'borrowed':
    case 'pending':
      return (
        background: const Color(0xFFFFF3C4),
        foreground: const Color(0xFFD97706),
      );
    case 'approved':
      return (
        background: const Color(0xFFDCFCE7),
        foreground: const Color(0xFF15803D),
      );
    case 'rejected':
      return (
        background: const Color(0xFFFFE4E6),
        foreground: const Color(0xFFE11D48),
      );
    case 'cancelled':
    case 'overdue':
      return (
        background: const Color(0xFFFEE2E2),
        foreground: const Color(0xFFB91C1C),
      );
    default:
      return (
        background: const Color(0xFFF1F5F9),
        foreground: const Color(0xFF475569),
      );
  }
}
