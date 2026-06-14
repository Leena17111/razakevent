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

  const BorrowedEquipmentTab({
    super.key,
    required this.event,
    required this.repository,
  });

  @override
  State<BorrowedEquipmentTab> createState() => _BorrowedEquipmentTabState();
}

class _BorrowedEquipmentTabState extends State<BorrowedEquipmentTab> {
  String _filter = 'all';

  bool _canCancel(BorrowedEquipmentRequestModel request) {
    final date = request.eventDate ?? widget.event.eventDate;
    return request.status == 'borrowed' &&
        date.isAfter(DateTime.now().add(const Duration(days: 3)));
  }

  Future<void> _cancel(BorrowedEquipmentRequestModel request) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await widget.repository.cancelBorrowRequest(request.id);
      if (!mounted) return;
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
          content: Text(l10n.borrowCancelError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<BorrowedEquipmentRequestModel>>(
      stream: widget.repository.watchBorrowedEquipmentForEvent(widget.event.id),
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
            _FilterBar(
              selected: _filter,
              filters: {
                'all': l10n.borrowFilterAll,
                'borrowed': l10n.borrowFilterBorrowed,
                'returned': l10n.borrowFilterReturned,
              },
              onSelected: (value) => setState(() => _filter = value),
            ),
            Expanded(
              child: items.isEmpty
                  ? _EmptyState(
                      icon: Icons.inventory_2_outlined,
                      text: l10n.borrowedEmpty,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final request = items[index];
                        return _BorrowedCard(
                          request: request,
                          eventDate:
                              request.eventDate ?? widget.event.eventDate,
                          canCancel: _canCancel(request),
                          onCancel: () => _cancel(request),
                          onReturn: () => Navigator.of(context).pushNamed(
                            AppRoutes.returnBorrowedEquipment,
                            arguments: ReturnBorrowedEquipmentArguments(
                              request: request,
                              eventDate:
                                  request.eventDate ?? widget.event.eventDate,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class SpecialRequestsTab extends StatefulWidget {
  final EligibleEvent event;
  final EquipmentBorrowRepository repository;

  const SpecialRequestsTab({
    super.key,
    required this.event,
    required this.repository,
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
            _FilterBar(
              selected: _filter,
              filters: {
                'all': l10n.borrowFilterAll,
                'pending': l10n.specialFilterPending,
                'approved': l10n.specialFilterApproved,
                'rejected': l10n.specialFilterRejected,
              },
              onSelected: (value) => setState(() => _filter = value),
            ),
            Expanded(
              child: items.isEmpty
                  ? _EmptyState(
                      icon: Icons.playlist_add_check_circle_outlined,
                      text: l10n.specialRequestsEmpty,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _SpecialRequestCard(
                        request: items[index],
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
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: filters.entries.map((entry) {
          final active = entry.key == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: active,
              onSelected: (_) => onSelected(entry.key),
              selectedColor: AppColors.primary,
              labelStyle: AppTextStyles.caption.copyWith(
                color: active ? AppColors.textWhite : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              side: const BorderSide(color: AppColors.border),
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
  final bool canCancel;
  final VoidCallback onCancel;
  final VoidCallback onReturn;

  const _BorrowedCard({
    required this.request,
    required this.eventDate,
    required this.canCancel,
    required this.onCancel,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final format = DateFormat('d MMM yyyy');
    final deadline = eventDate.add(const Duration(hours: 24));
    return _RequestCard(
      title: request.equipmentName,
      status: _statusLabel(l10n, request.status),
      statusColor: _statusColor(request.status),
      children: [
        _InfoLine(Icons.numbers, '${l10n.borrowQuantity}: ${request.quantity}'),
        _InfoLine(
          Icons.calendar_today_outlined,
          '${l10n.borrowDate}: ${format.format(request.createdAt)}',
        ),
        _InfoLine(
          Icons.event_outlined,
          '${l10n.borrowEvent}: ${request.eventName}',
        ),
        if (request.storageLocation.isNotEmpty)
          _InfoLine(
            Icons.location_on_outlined,
            '${l10n.storageLocation}: ${request.storageLocation}',
          ),
        _InfoLine(
          Icons.schedule,
          '${l10n.returnDeadline}: ${format.format(deadline)}',
        ),
        _InfoLine(Icons.info_outline, l10n.returnInstruction),
        if (request.status == 'borrowed') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (canCancel) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: Text(l10n.cancelRequest),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: onReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                  ),
                  child: Text(l10n.returnEquipmentAction),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SpecialRequestCard extends StatelessWidget {
  final SpecialEquipmentRequest request;
  final VoidCallback onCancel;

  const _SpecialRequestCard({required this.request, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _RequestCard(
      title: request.itemName,
      status: _statusLabel(l10n, request.status),
      statusColor: _statusColor(request.status),
      children: [
        _InfoLine(
          Icons.numbers,
          '${l10n.borrowQuantity}: ${request.quantityRequired}',
        ),
        _InfoLine(
          Icons.notes_outlined,
          '${l10n.specialRequestReason}: ${request.reason}',
        ),
        _InfoLine(
          Icons.calendar_today_outlined,
          '${l10n.specialCreatedAt}: ${DateFormat('d MMM yyyy').format(request.createdAt)}',
        ),
        if (request.status == 'pending') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCancel,
              child: Text(l10n.cancelRequest),
            ),
          ),
        ],
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final List<Widget> children;

  const _RequestCard({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.h3)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: AppTextStyles.caption)),
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

String _statusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'borrowed':
      return l10n.statusBorrowed;
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

Color _statusColor(String status) {
  switch (status) {
    case 'borrowed':
    case 'approved':
      return AppColors.success;
    case 'returned':
      return AppColors.primary;
    case 'rejected':
    case 'cancelled':
      return AppColors.error;
    default:
      return AppColors.warning;
  }
}
