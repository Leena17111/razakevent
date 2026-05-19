import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

class SecretaryEventDetailScreen extends StatelessWidget {
  const SecretaryEventDetailScreen({super.key});

  static const Color _navy = Color(0xFF1A237E);
  static const Color _red = Color(0xFFC8102E);
  static const Color _inputBg = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final event = args['event'] as Map<String, dynamic>;
    final l10n = AppLocalizations.of(context)!;

    final eventId = event['eventId'] as String? ?? '';
    final title = event['title'] as String? ?? '';
    final orgType = event['organizationType'] as String? ?? '';
    final orgName = event['organizationName'] as String? ?? '';
    final category = event['category'] as String? ?? '';
    final description = event['description'] as String? ?? '';
    final venue = event['venue'] as String? ?? '';
    final eventDateTime = event['eventDateTime'];
    final registrationEnabled = event['registrationEnabled'] as bool? ?? false;
    final status = event['status'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .where('eventId', isEqualTo: eventId)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          Map<String, dynamic>? doc;
          String? documentId;

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final docSnap = snapshot.data!.docs.first;
            doc = docSnap.data() as Map<String, dynamic>;
            documentId = docSnap.id;
          }

          final docStatus = doc?['status'] as String?;

          return Column(
            children: [
              _buildHeader(context, title, l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventInfoCard(
                        context,
                        orgType: orgType,
                        orgName: orgName,
                        category: category,
                        description: description,
                        venue: venue,
                        eventDateTime: eventDateTime,
                        registrationEnabled: registrationEnabled,
                        status: status,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 16),
                      _buildPaperworkSection(
                        context,
                        eventId: eventId,
                        orgType: orgType,
                        orgName: orgName,
                        title: title,
                        doc: doc,
                        documentId: documentId,
                        docStatus: docStatus,
                        l10n: l10n,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
      BuildContext context, String title, AppLocalizations l10n) {
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
            l10n.secretaryEventDetail,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Event Info Card ───────────────────────────────────────────────────────
  Widget _buildEventInfoCard(
    BuildContext context, {
    required String orgType,
    required String orgName,
    required String category,
    required String description,
    required String venue,
    required dynamic eventDateTime,
    required bool registrationEnabled,
    required String status,
    required AppLocalizations l10n,
  }) {
    return Container(
      width: double.infinity,
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
          _sectionLabel(l10n.eventInfo),
          const SizedBox(height: 12),
          Row(
            children: [
              _orgTypeBadge(orgType, l10n),
              const SizedBox(width: 8),
              Text(
                orgName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow(Icons.category_outlined, l10n.category, category),
          const SizedBox(height: 8),
          _infoRow(Icons.location_on_outlined, l10n.venue, venue),
          const SizedBox(height: 8),
          _infoRow(
            Icons.calendar_today_outlined,
            l10n.eventDateTime,
            _formatDateTime(eventDateTime),
          ),
          const SizedBox(height: 8),
          _infoRow(
            Icons.how_to_reg_outlined,
            l10n.registrationSettings,
            registrationEnabled
                ? l10n.registrationEnabled
                : l10n.registrationDisabledLabel,
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.flag_outlined, l10n.eventStatus, status),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.eventDescription,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // ── Paperwork Section ─────────────────────────────────────────────────────
  Widget _buildPaperworkSection(
    BuildContext context, {
    required String eventId,
    required String orgType,
    required String orgName,
    required String title,
    required Map<String, dynamic>? doc,
    required String? documentId,
    required String? docStatus,
    required AppLocalizations l10n,
  }) {
    return Container(
      width: double.infinity,
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
          _sectionLabel(l10n.paperworkStatus),
          const SizedBox(height: 12),
          if (docStatus == null)
            _buildNoPaperwork(context,
                eventId: eventId,
                orgType: orgType,
                orgName: orgName,
                title: title,
                l10n: l10n)
          else
            _buildPaperworkCard(
              context,
              doc: doc!,
              documentId: documentId!,
              docStatus: docStatus,
              eventId: eventId,
              orgType: orgType,
              orgName: orgName,
              title: title,
              l10n: l10n,
            ),
        ],
      ),
    );
  }

  Widget _buildNoPaperwork(
    BuildContext context, {
    required String eventId,
    required String orgType,
    required String orgName,
    required String title,
    required AppLocalizations l10n,
  }) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Icon(
                Icons.upload_file_rounded,
                size: 48,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noPaperworkYet,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.uploadEventDocument,
              arguments: {
                'eventId': eventId,
                'organizationType': orgType,
                'organizationName': orgName,
                'eventTitle': title,
              },
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.createPaperwork),
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaperworkCard(
    BuildContext context, {
    required Map<String, dynamic> doc,
    required String documentId,
    required String docStatus,
    required String eventId,
    required String orgType,
    required String orgName,
    required String title,
    required AppLocalizations l10n,
  }) {
    final docType = doc['documentType'] as String? ?? '';
    final fileName = doc['fileName'] as String? ?? '';
    final submittedAt = doc['submittedAt'] as Timestamp?;
    final adminComment = doc['adminComment'] as String?;
    final isLocked = docStatus == 'Approved' || docStatus == 'Rejected';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        _statusBadge(docStatus, l10n),
        const SizedBox(height: 12),

        // File info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf_rounded,
                  color: _navy, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      docType,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    if (submittedAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDateTime(submittedAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Admin comment if revision
        if ((docStatus == 'Needs Correction' || docStatus == 'Rejected') &&
            adminComment != null &&
            adminComment.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: docStatus == 'Rejected'
                  ? Colors.red.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: docStatus == 'Rejected'
                    ? Colors.red.shade200
                    : Colors.orange.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 14,
                      color: docStatus == 'Rejected'
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      docStatus == 'Rejected'
                          ? l10n.rejectionReason
                          : l10n.correctionRequired,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: docStatus == 'Rejected'
                            ? Colors.red.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  adminComment,
                  style: TextStyle(
                    fontSize: 13,
                    color: docStatus == 'Rejected'
                        ? Colors.red.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Action buttons if not locked
        if (!isLocked) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(
                    context,
                    documentId: documentId,
                    l10n: l10n,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(l10n.delete),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _red,
                    side: const BorderSide(color: _red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.editDocument,
                    arguments: {
                      'docId': documentId,
                      'data': doc,
                    },
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(l10n.editDocument),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Delete confirmation ───────────────────────────────────────────────────
  Future<void> _confirmDelete(
    BuildContext context, {
    required String documentId,
    required AppLocalizations l10n,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteDocument),
        content: Text(l10n.deleteDocumentConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('documents')
          .doc(documentId)
          .delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.documentDeletedSuccessfully),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToDeleteDocument),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 12,
        color: _navy,
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
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

  Widget _statusBadge(String status, AppLocalizations l10n) {
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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