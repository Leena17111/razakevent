import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/secretary_proposed_events_controller.dart';

class SecretaryProposedEventsScreen extends StatelessWidget {
  const SecretaryProposedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SecretaryProposedEventsController(),
      child: const _SecretaryProposedEventsView(),
    );
  }
}

class _SecretaryProposedEventsView extends StatefulWidget {
  const _SecretaryProposedEventsView();

  @override
  State<_SecretaryProposedEventsView> createState() =>
      _SecretaryProposedEventsViewState();
}

class _SecretaryProposedEventsViewState
    extends State<_SecretaryProposedEventsView> {
  static const Color _navy = Color(0xFF1A237E);
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SecretaryProposedEventsController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _buildHeader(context, l10n),
          _buildFilterTabs(l10n),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: controller.getProposedEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data ?? [];

                if (events.isEmpty) {
                  return _buildEmptyState(l10n);
                }

                return _FilteredEventsList(
                  events: events,
                  controller: controller,
                  l10n: l10n,
                  filter: _filter,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _filterTab(l10n.allEvents, 'All'),
          _filterTab(l10n.filterNeedsPaperwork, 'Needs Paperwork'),
          _filterTab(l10n.filterSubmitted, 'Submitted'),
        ],
      ),
    );
  }

  Widget _filterTab(String label, String value) {
    final selected = _filter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? _navy : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              color: selected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      color: _navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              LanguageToggle(
                selectedLocale: Localizations.localeOf(context),
                onLocaleChanged: (locale) {
                  localeController.value = locale;
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.secretaryProposedEvents,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.secretaryProposedEventsSubtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            l10n.noProposedEventsYet,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noProposedEventsSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Filtered Events List ──────────────────────────────────────────────────────
class _FilteredEventsList extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final SecretaryProposedEventsController controller;
  final AppLocalizations l10n;
  final String filter;

  const _FilteredEventsList({
    required this.events,
    required this.controller,
    required this.l10n,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _filteredStream(controller),
      builder: (context, snapshot) {
        final filtered = snapshot.data ?? [];
        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy_rounded,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  filter == 'Needs Paperwork'
                      ? l10n.allEventsPaperworkDone
                      : filter == 'Submitted'
                          ? l10n.noSubmittedPaperworkYet
                          : l10n.noProposedEventsYet,
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _EventProposedCard(
              event: filtered[index],
              controller: controller,
              l10n: l10n,
            );
          },
        );
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _filteredStream(
      SecretaryProposedEventsController controller) {
    return controller.getProposedEvents().asyncMap((events) async {
      final List<Map<String, dynamic>> result = [];
      for (final event in events) {
        final eventId = event['eventId'] as String? ?? '';
        final docSnap = await FirebaseFirestore.instance
            .collection('documents')
            .where('eventId', isEqualTo: eventId)
            .limit(1)
            .get();
        final hasDoc = docSnap.docs.isNotEmpty;
        if (filter == 'All' ||
            (filter == 'Needs Paperwork' && !hasDoc) ||
            (filter == 'Submitted' && hasDoc)) {
          result.add(event);
        }
      }
      return result;
    });
  }
}

// ── Event Card with live paperwork status ────────────────────────────────────
class _EventProposedCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final SecretaryProposedEventsController controller;
  final AppLocalizations l10n;

  const _EventProposedCard({
    required this.event,
    required this.controller,
    required this.l10n,
  });

  static const Color _navy = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    final eventId = event['eventId'] as String? ?? '';
    final title = event['title'] as String? ?? '';
    final orgType = event['organizationType'] as String? ?? '';
    final orgName = event['organizationName'] as String? ?? '';
    final category = event['category'] as String? ?? '';
    final eventDateTime = event['eventDateTime'];
    final venue = event['venue'] as String? ?? '';

    return StreamBuilder<Map<String, dynamic>?>(
      stream: controller.getLinkedDocument(eventId),
      builder: (context, snapshot) {
        final doc = snapshot.data;
        final status = doc?['status'] as String?;

        return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.secretaryEventDetail,
            arguments: {
              'event': event,
              'document': doc,
            },
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
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
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _paperworkBadge(status, l10n),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _orgTypeBadge(orgType, l10n),
                    const SizedBox(width: 8),
                    Text(
                      orgName,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(eventDateTime),
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      venue,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
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

  Widget _paperworkBadge(String? status, AppLocalizations l10n) {
    if (status == null) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l10n.noPaperworkYet,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    Color color;
    Color bg;
    IconData icon;
    String label;

    switch (status) {
      case 'Approved':
        color = Colors.green.shade700;
        bg = Colors.green.shade50;
        icon = Icons.check_circle_outline;
        label = l10n.statusApproved;
        break;
      case 'Needs Correction':
        color = Colors.orange.shade700;
        bg = Colors.orange.shade50;
        icon = Icons.error_outline;
        label = l10n.statusNeedsCorrection;
        break;
      case 'Rejected':
        color = Colors.red.shade700;
        bg = Colors.red.shade50;
        icon = Icons.cancel_outlined;
        label = l10n.statusRejected;
        break;
      default:
        color = Colors.blue.shade700;
        bg = Colors.blue.shade50;
        icon = Icons.access_time_rounded;
        label = l10n.statusPendingReview;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orgTypeBadge(String type, AppLocalizations l10n) {
    final label = type == 'Exco' ? l10n.exco : l10n.club;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _navy,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(dynamic value) {
    if (value == null) return '';
    final dt = value is Timestamp ? value.toDate() : DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}