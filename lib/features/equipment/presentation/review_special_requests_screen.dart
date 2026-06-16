import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/special_equipment_request_model.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/review_special_requests_controller.dart';

class ReviewSpecialRequestsScreen extends StatefulWidget {
  const ReviewSpecialRequestsScreen({super.key});

  @override
  State<ReviewSpecialRequestsScreen> createState() =>
      _ReviewSpecialRequestsScreenState();
}

class _ReviewSpecialRequestsScreenState
    extends State<ReviewSpecialRequestsScreen> {
  String _activeFilter = 'pending';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewSpecialRequestsController(),
      child: Consumer<ReviewSpecialRequestsController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: Stack(
              children: [
                Column(
                  children: [
                    const _Header(),
                    _FilterPills(
                      activeFilter: _activeFilter,
                      onFilterChanged: (f) =>
                          setState(() => _activeFilter = f),
                    ),
                    Expanded(
                      child: StreamBuilder<List<SpecialEquipmentRequest>>(
                        stream: controller.watchAllRequests(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1A237E),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          final all = snapshot.data ?? [];
                          final filtered = all
                              .where((r) => r.status == _activeFilter)
                              .toList();

                          if (filtered.isEmpty) {
                            return _EmptyState(filter: _activeFilter);
                          }

                          return ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 32),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) => _RequestCard(
                              key: ValueKey(filtered[i].id),
                              request: filtered[i],
                              controller: controller,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (controller.successMessage != null ||
                    controller.errorMessage != null)
                  _SnackbarOverlay(
                    message: controller.successMessage != null
                        ? _resolveSuccess(
                            context, controller.successMessage!)
                        : controller.errorMessage!,
                    isError: controller.errorMessage != null,
                    onDone: controller.clearMessages,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _resolveSuccess(BuildContext context, String key) {
    final l = AppLocalizations.of(context)!;
    if (key == 'requestApprovedSuccess') return l.requestApprovedSuccess;
    if (key == 'requestRejected') return l.requestRejected;
    return key;
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, currentLocale, _) {
        final l = AppLocalizations.of(context)!;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E),
                Color(0xFF283593),
                Color(0xFF3949AB),
              ],
            ),
          ),
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 16, 16, 48),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.specialRequestsTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.specialRequestsSubtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              LanguageToggle(
                selectedLocale: currentLocale,
                onLocaleChanged: (locale) {
                  localeController.value = locale;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Filter Pills ──────────────────────────────────────────────────────────────

class _FilterPills extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const _FilterPills({
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, _, __) {
        final l = AppLocalizations.of(context)!;
        final filters = [
          ('pending', l.filterPending),
          ('approved', l.filterApproved),
          ('rejected', l.filterRejected),
        ];
        return Transform.translate(
          offset: const Offset(0, -24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: filters.map((entry) {
                final (value, label) = entry;
                final isActive = activeFilter == value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: value != 'rejected' ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => onFilterChanged(value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1A237E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF1A237E)
                                : const Color(0xFFE5E7EB),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

// ── Request Card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatefulWidget {
  final SpecialEquipmentRequest request;
  final ReviewSpecialRequestsController controller;

  const _RequestCard({
    super.key,
    required this.request,
    required this.controller,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  // ✅ FIX: Query by uid field instead of document ID
late final Future<String?> _nameFuture = () async {
  final id = widget.request.organizerHeadId;

  // If organizerHeadId exists, look up directly
  if (id.isNotEmpty) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();
    if (doc.exists) {
      return doc.data()?['fullName'] as String?;
    }

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: id)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return query.docs.first.data()['fullName'] as String?;
    }
  }

  // Fallback: trace through the event using eventId → createdBy → fullName
  final eventId = widget.request.eventId;
  if (eventId.isEmpty) return null;

  final eventDoc = await FirebaseFirestore.instance
      .collection('events')
      .doc(eventId)
      .get();
  if (!eventDoc.exists) return null;

  final createdBy = eventDoc.data()?['createdBy'] as String?;
  if (createdBy == null || createdBy.isEmpty) return null;

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(createdBy)
      .get();
  if (userDoc.exists) {
    return userDoc.data()?['fullName'] as String?;
  }

  return null;
}();

  @override
  Widget build(BuildContext context) {
    final statusConfig = _statusConfig(widget.request.status);
    final dateStr = _formatDate(widget.request.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Requester row ──
          FutureBuilder<String?>(
            future: _nameFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              String? displayName;
              if (snapshot.hasData && snapshot.data != null) {
                displayName = snapshot.data;
              } else if (!isLoading) {
                displayName = 'Unknown';
              }

              final initials =
                  displayName != null ? _initials(displayName) : '?';

              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLoading)
                          Container(
                            height: 12,
                            width: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          )
                        else
                          Text(
                            displayName ?? 'Unknown',
                            style: const TextStyle(
                              color: Color(0xFF1C1C1E),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusConfig['bg'] as Color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusConfig['icon'] as IconData,
                          size: 11,
                          color: statusConfig['text'] as Color,
                        ),
                        const SizedBox(width: 4),
                        ValueListenableBuilder<Locale>(
                          valueListenable: localeController,
                          builder: (context, _, __) {
                            final l = AppLocalizations.of(context)!;
                            return Text(
                              _statusLabel(widget.request.status, l),
                              style: TextStyle(
                                color: statusConfig['text'] as Color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          ValueListenableBuilder<Locale>(
            valueListenable: localeController,
            builder: (context, _, __) {
              final l = AppLocalizations.of(context)!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: l.borrowEvent,
                          value: widget.request.eventName,
                        ),
                        const Divider(
                            height: 16, color: Color(0xFFE5E7EB)),
                        _DetailRow(
                          label: l.itemName,
                          value:
                              '${widget.request.itemName} × ${widget.request.quantityRequired}',
                          valueBold: true,
                        ),
                        const Divider(
                            height: 16, color: Color(0xFFE5E7EB)),
                        _DetailRow(
                          label: l.specialRequestReason,
                          value: widget.request.reason,
                        ),
                      ],
                    ),
                  ),

                  if (widget.request.status == 'approved' &&
                      widget.request.approvalLocation != null) ...[
                    const SizedBox(height: 8),
                    _InfoBanner(
                      icon: Icons.location_on,
                      iconColor: const Color(0xFF059669),
                      backgroundColor: const Color(0xFFD1FAE5),
                      borderColor: const Color(0xFFA7F3D0),
                      title: l.collectionLocation,
                      message: widget.request.approvalLocation!,
                    ),
                  ],

                  if (widget.request.status == 'approved' &&
                      widget.request.adminNote != null &&
                      widget.request.adminNote!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoBanner(
                      icon: Icons.info_outline,
                      iconColor: const Color(0xFF3B82F6),
                      backgroundColor: const Color(0xFFEFF6FF),
                      borderColor: const Color(0xFFBFDBFE),
                      message: widget.request.adminNote!,
                    ),
                  ],

                  if (widget.request.status == 'rejected' &&
                      widget.request.adminNote != null) ...[
                    const SizedBox(height: 8),
                    _InfoBanner(
                      icon: Icons.cancel_outlined,
                      iconColor: const Color(0xFFDC2626),
                      backgroundColor: const Color(0xFFFEE2E2),
                      borderColor: const Color(0xFFFECACA),
                      message: widget.request.adminNote!,
                    ),
                  ],

                  if (widget.request.status == 'pending') ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: l.rejectRequest,
                            icon: Icons.cancel_outlined,
                            isDestructive: true,
                            onTap: () => _showRejectDialog(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: l.approveRequest,
                            icon: Icons.check_circle_outline,
                            isDestructive: false,
                            onTap: () => _showApproveDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _ApproveSheet(
            request: widget.request,
            onConfirm: (loc, note) async {
              Navigator.of(context).pop();
              await widget.controller.approveRequest(
                requestId: widget.request.id!,
                location: loc,
                note: note,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _RejectSheet(
            request: widget.request,
            onConfirm: (reason) async {
              Navigator.of(context).pop();
              await widget.controller.rejectRequest(
                requestId: widget.request.id!,
                reason: reason,
              );
            },
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status, AppLocalizations l) {
    switch (status) {
      case 'approved':
        return l.approved;
      case 'rejected':
        return l.rejected;
      default:
        return l.pending;
    }
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (trimmed.length >= 2) return trimmed.substring(0, 2).toUpperCase();
    return trimmed.toUpperCase();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Map<String, dynamic> _statusConfig(String status) {
    switch (status) {
      case 'approved':
        return {
          'icon': Icons.check_circle,
          'bg': const Color(0xFFD1FAE5),
          'text': const Color(0xFF059669),
        };
      case 'rejected':
        return {
          'icon': Icons.cancel,
          'bg': const Color(0xFFFEE2E2),
          'text': const Color(0xFFDC2626),
        };
      default:
        return {
          'icon': Icons.access_time,
          'bg': const Color(0xFFFEF3C7),
          'text': const Color(0xFFD97706),
        };
    }
  }
}

// ── Approve Dialog ────────────────────────────────────────────────────────────

class _ApproveSheet extends StatefulWidget {
  final SpecialEquipmentRequest request;
  final Future<void> Function(String location, String? note) onConfirm;

  const _ApproveSheet({required this.request, required this.onConfirm});

  @override
  State<_ApproveSheet> createState() => _ApproveSheetState();
}

class _ApproveSheetState extends State<_ApproveSheet> {
  final _locationCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _locationError;
  bool _loading = false;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, _, __) {
        final l = AppLocalizations.of(context)!;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l.confirmApproveSpecial,
                      style: const TextStyle(
                        color: Color(0xFF1C1C1E),
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.request.itemName} × ${widget.request.quantityRequired}',
                        style: const TextStyle(
                          color: Color(0xFF1C1C1E),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.request.eventName,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: '${l.itemLocation} ',
                    style: const TextStyle(
                      color: Color(0xFF1C1C1E),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    children: const [
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Color(0xFFC8102E)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationCtrl,
                  onChanged: (_) =>
                      setState(() => _locationError = null),
                  decoration: InputDecoration(
                    hintText: l.itemLocationHint,
                    hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: _locationError != null
                            ? Colors.red
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: _locationError != null
                            ? Colors.red
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFF1A237E)),
                    ),
                    errorText: _locationError,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l.additionalNote,
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: l.additionalNoteHint,
                    hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFF1A237E)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                              color: Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          l.cancelBtn,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : () => _submit(l),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l.confirmApproveSpecial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit(AppLocalizations l) async {
    if (_locationCtrl.text.trim().isEmpty) {
      setState(() => _locationError = l.itemLocationRequired);
      return;
    }
    setState(() => _loading = true);
    await widget.onConfirm(
      _locationCtrl.text.trim(),
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
  }
}

// ── Reject Dialog ─────────────────────────────────────────────────────────────

class _RejectSheet extends StatefulWidget {
  final SpecialEquipmentRequest request;
  final Future<void> Function(String reason) onConfirm;

  const _RejectSheet({required this.request, required this.onConfirm});

  @override
  State<_RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<_RejectSheet> {
  final _reasonCtrl = TextEditingController();
  String? _reasonError;
  bool _loading = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, _, __) {
        final l = AppLocalizations.of(context)!;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cancel,
                          size: 16, color: Color(0xFFC8102E)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.rejectRequest,
                            style: const TextStyle(
                              color: Color(0xFF1C1C1E),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.request.eventName,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: '${l.specialRejectionReason} ',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                    children: const [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: Color(0xFFC8102E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonCtrl,
                  maxLines: 3,
                  onChanged: (_) =>
                      setState(() => _reasonError = null),
                  decoration: InputDecoration(
                    hintText: l.specialRejectionReasonHint,
                    hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: _reasonError != null
                            ? Colors.red
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: _reasonError != null
                            ? Colors.red
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF1A237E), width: 2),
                    ),
                    errorText: _reasonError,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                              color: Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          l.cancelBtn,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading ? null : () => _submit(l),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                              color: Color(0xFFFECACA), width: 2),
                          foregroundColor: const Color(0xFFC8102E),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Color(0xFFC8102E),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l.confirmRejectSpecial,
                                style: const TextStyle(
                                  color: Color(0xFFC8102E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit(AppLocalizations l) async {
    if (_reasonCtrl.text.trim().isEmpty) {
      setState(
          () => _reasonError = l.specialRejectionReasonRequired);
      return;
    }
    setState(() => _loading = true);
    await widget.onConfirm(_reasonCtrl.text.trim());
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: const Color(0xFF1C1C1E),
              fontSize: 11,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String? title;
  final String message;

  const _InfoBanner({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                Text(
                  message,
                  style: TextStyle(color: iconColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isDestructive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isDestructive) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: const Color(0xFFC8102E)),
        label: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFC8102E),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Color(0xFFFECACA), width: 2),
          backgroundColor: Colors.white,
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: const Color(0xFF16A34A),
        elevation: 2,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, _, __) {
        final l = AppLocalizations.of(context)!;
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A237E).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 28,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l.noRequests,
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.noRequestsDesc(filter),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SnackbarOverlay extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDone;

  const _SnackbarOverlay({
    required this.message,
    required this.isError,
    required this.onDone,
  });

  @override
  State<_SnackbarOverlay> createState() => _SnackbarOverlayState();
}

class _SnackbarOverlayState extends State<_SnackbarOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _anim.reverse().then((_) => widget.onDone());
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: widget.isError
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.isError ? Icons.close : Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}