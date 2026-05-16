import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/widgets/language_toggle.dart';
import '../../../core/localization/locale_controller.dart';

class DocumentDetailsScreen extends StatelessWidget {
  const DocumentDetailsScreen({super.key});

  static const Color _navy = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    final docId = ModalRoute.of(context)!.settings.arguments as String;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('documents').doc(docId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Document not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          return _buildContent(context, data, l10n);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data, AppLocalizations l10n) {
    final status = data['status'] as String? ?? 'Pending Review';
    final title = data['title'] as String? ?? '';
    final orgName = data['organizationName'] as String? ?? '';
    final docType = data['documentType'] as String? ?? '';
    final fileName = data['fileName'] as String? ?? '';
    final fileSize = data['fileSize'] as int? ?? 0;
    final fileUrl = data['fileUrl'] as String? ?? '';
    final submittedAt = data['submittedAt'] as Timestamp?;
    final reviewedAt = data['reviewedAt'] as Timestamp?;
    final reviewedBy = data['reviewedBy'] as String?;
    final adminComment = data['adminComment'] as String?;
    final remarks = data['remarks'] as String?;

    return Column(
      children: [
        _buildHeader(context, l10n),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusBadge(status, l10n),
                const SizedBox(height: 12),
                Text(title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$orgName • $docType',
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 20),

                // PDF section
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.documentPdf.toUpperCase(),
                            style: const TextStyle(
                              color: _navy,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: fileUrl.isNotEmpty ? () => _downloadFile(fileUrl) : null,
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: Text(l10n.download, style: const TextStyle(fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.insert_drive_file_rounded,
                                size: 48, color: _navy.withValues(alpha: 0.7)),
                            const SizedBox(height: 10),
                            Text(fileName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 4),
                            Text('${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB',
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Submission Details
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.submissionDetails.toUpperCase(),
                        style: const TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _detailRow(l10n.submittedDate, _formatDateTime(submittedAt)),
                      const SizedBox(height: 10),
                      _detailRow(l10n.reviewedDate,
                          reviewedAt != null ? _formatDateTime(reviewedAt) : '—'),
                      const SizedBox(height: 10),
                      _detailRow(l10n.reviewedBy, reviewedBy ?? '—'),
                      if (remarks != null && remarks.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _detailRow(l10n.remarksOptional, remarks),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (adminComment != null && adminComment.isNotEmpty)
                  _buildAdminCommentCard(status, adminComment, l10n),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      color: _navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8,
        right: 16,
        bottom: 16,
      ),
      child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                l10n.documentDetails,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            LanguageToggle(
              selectedLocale: Localizations.localeOf(context),
              onLocaleChanged: (locale) => localeController.value = locale,
            ),
          ],
        ),
    );
  }

  // ── Admin Comment Card ────────────────────────────────────────────
  Widget _buildAdminCommentCard(String status, String comment, AppLocalizations l10n) {
    final isCorrection = status == 'Needs Correction';
    final color = isCorrection ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: color.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                isCorrection
                    ? l10n.correctionRequired.toUpperCase()
                    : l10n.rejectionReason.toUpperCase(),
                style: TextStyle(
                  color: color.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(comment,
              style: TextStyle(color: color.shade900, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
  Widget _buildCard({required Widget child}) {
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
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _downloadFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDateTime(Timestamp? ts) {
    if (ts == null) return '—';
    final dt = ts.toDate();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute';
  }
}