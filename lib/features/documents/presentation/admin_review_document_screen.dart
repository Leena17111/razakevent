import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/admin_document_review_controller.dart';

class AdminReviewDocumentScreen extends StatefulWidget {
  const AdminReviewDocumentScreen({super.key});

  @override
  State<AdminReviewDocumentScreen> createState() =>
      _AdminReviewDocumentScreenState();
}

class _AdminReviewDocumentScreenState
    extends State<AdminReviewDocumentScreen> {
  static const Color _navy = Color(0xFF1A237E);

  String? _docId;
  final _commentController = TextEditingController();

  // Fix 1: Cache the resolved submitter display name to avoid repeated lookups.
  String? _resolvedSubmitterName;
  bool _submitterLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Fix 1: Fetch user fullName from users/{uid}, fallback to email, then UID.
  Future<String> _resolveSubmitterName(String uid) async {
    if (uid.isEmpty) return '—';
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final fullName = data['fullName'] as String?;
        if (fullName != null && fullName.trim().isNotEmpty) return fullName;
        final email = data['email'] as String?;
        if (email != null && email.trim().isNotEmpty) return email;
      }
    } catch (_) {
      // Ignore — fall through to UID fallback.
    }
    return uid;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _docId = ModalRoute.of(context)!.settings.arguments as String?;

    return ChangeNotifierProvider(
      create: (_) => AdminDocumentReviewController(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('documents')
                  .doc(_docId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text(l10n.documentNotFound));
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>;

                return _buildContent(context, data);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final title = data['title'] as String? ?? '';
    final orgType = data['organizationType'] as String? ?? '';
    final orgName = data['organizationName'] as String? ?? '';
    final docType = data['documentType'] as String? ?? '';
    final fileName = data['fileName'] as String? ?? '';
    final fileSize = data['fileSize'] as int? ?? 0;
    final fileUrl = data['fileUrl'] as String? ?? '';
    final submittedAt = data['submittedAt'] as Timestamp?;
    final submittedByUid = data['submittedBy'] as String? ?? '';
    // Also check stored name field as a quick path (set by secretary upload if available).
    final submittedByNameStored = data['submittedByName'] as String? ?? '';
    final remarks = data['remarks'] as String?;
    final status = data['status'] as String? ?? 'Pending Review';

    // Fix 2 & 3: Determine read-only mode based on status.
    final isPendingReview = status == 'Pending Review';

    return Column(
      children: [
        _buildHeader(context, title),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPdfPreviewCard(context, fileName, fileSize, fileUrl),
                const SizedBox(height: 16),
                _buildDocumentInfoCard(
                  context,
                  title,
                  orgType,
                  orgName,
                  docType,
                  submittedByUid,
                  submittedByNameStored,
                  submittedAt,
                  remarks,
                ),
                const SizedBox(height: 16),
                // Fix 2 & 3: Show review actions only when Pending Review.
                // Show read-only status card for reviewed documents.
                if (isPendingReview)
                  _buildReviewActionsCard(context)
                else
                  _buildReadOnlyStatusCard(context, data),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.reviewDocument,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              LanguageToggle(
                selectedLocale: Localizations.localeOf(context),
                onLocaleChanged: (locale) =>
                    localeController.value = locale,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PDF Preview Card ──────────────────────────────────────────────
  Widget _buildPdfPreviewCard(
    BuildContext context,
    String fileName,
    int fileSize,
    String fileUrl,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.pdfPreview.toUpperCase(),
                style: const TextStyle(
                  color: _navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              Tooltip(
                message: l10n.download,
                child: GestureDetector(
                  onTap: fileUrl.isNotEmpty
                      ? () => _downloadFile(fileUrl)
                      : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: fileUrl.isNotEmpty ? _navy : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: fileUrl.isNotEmpty ? () => _downloadFile(fileUrl) : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.insert_drive_file_rounded,
                      color: _navy.withValues(alpha: 0.8),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sizeMB MB',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Document Info Card ────────────────────────────────────────────
  // Fix 1: Resolves submittedBy UID → fullName via Firestore users collection.
  Widget _buildDocumentInfoCard(
    BuildContext context,
    String title,
    String orgType,
    String orgName,
    String docType,
    String submittedByUid,
    String submittedByNameStored,
    Timestamp? submittedAt,
    String? remarks,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final isClub = orgType == 'Club';
    final chipColor = isClub ? Colors.purple : _navy;
    final chipBg = isClub
        ? Colors.purple.withValues(alpha: 0.1)
        : const Color(0xFFE8EAF6);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentInformation.toUpperCase(),
            style: const TextStyle(
              color: _navy,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(l10n.eventTitle, title, bold: true),
          const SizedBox(height: 10),
          // Organization row with chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  l10n.organization,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  orgType,
                  style: TextStyle(
                    color: chipColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  orgName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow(l10n.documentType, docType, bold: true),
          const SizedBox(height: 10),
          // Fix 1: Resolve submitter name asynchronously.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  l10n.submittedBy,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              Expanded(
                child: _SubmitterNameWidget(
                  storedName: submittedByNameStored,
                  uid: submittedByUid,
                  resolveSubmitterName: _resolveSubmitterName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow(
            l10n.submittedDate,
            _formatDateTime(context, submittedAt),
            bold: true,
          ),
          if (remarks != null && remarks.isNotEmpty) ...[
            const SizedBox(height: 10),
            _infoRow(l10n.remarksOptional, remarks, bold: true),
          ],
        ],
      ),
    );
  }

  // ── Review Actions Card (editable — only when Pending Review) ─────
  Widget _buildReviewActionsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AdminDocumentReviewController>(
      builder: (context, controller, _) {
        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reviewActions.toUpperCase(),
                style: const TextStyle(
                  color: _navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _actionButton(
                    controller,
                    action: AdminDocumentReviewController.actionApprove,
                    label: l10n.approve,
                    icon: Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    bgColor: Colors.green.shade50,
                    selectedBorderColor: Colors.green.shade700,
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    controller,
                    action: AdminDocumentReviewController.actionRequestCorrection,
                    label: l10n.requestCorrection,
                    icon: Icons.error_rounded,
                    color: Colors.orange.shade600,
                    bgColor: Colors.orange.shade50,
                    selectedBorderColor: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    controller,
                    action: AdminDocumentReviewController.actionReject,
                    label: l10n.reject,
                    icon: Icons.cancel_rounded,
                    color: Colors.red.shade600,
                    bgColor: Colors.red.shade50,
                    selectedBorderColor: Colors.red.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.adminComment,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                onChanged: controller.setAdminComment,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.adminCommentHint,
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),
              if (controller.isApprove) ...[
                _buildSignedDocumentUpload(context, controller),
                const SizedBox(height: 16),
              ],
              if (controller.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () => _submitReview(context, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.submitReview,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Read-only Status Card (for Approved / Needs Correction / Rejected) ──
  // Fix 2: Show current status, admin comment, reviewed date/by. Hide all actions.
  Widget _buildReadOnlyStatusCard(
      BuildContext context, Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    final status = data['status'] as String? ?? '';
    final adminComment = data['adminComment'] as String?;
    final reviewedAt = data['reviewedAt'] as Timestamp?;
    final reviewedByUid = data['reviewedBy'] as String? ?? '';
    final signedDocumentUrl = data['signedDocumentUrl'] as String?;
    final signedDocumentFileName = data['signedDocumentFileName'] as String?;

    Color statusColor;
    Color statusBg;
    IconData statusIcon;
    String statusLabel;

    switch (status) {
      case 'Approved':
        statusColor = Colors.green.shade700;
        statusBg = Colors.green.shade50;
        statusIcon = Icons.check_circle_rounded;
        statusLabel = l10n.statusApproved;
        break;
      case 'Needs Correction':
        statusColor = Colors.orange.shade700;
        statusBg = Colors.orange.shade50;
        statusIcon = Icons.error_rounded;
        statusLabel = l10n.statusNeedsCorrection;
        break;
      case 'Rejected':
        statusColor = Colors.red.shade700;
        statusBg = Colors.red.shade50;
        statusIcon = Icons.cancel_rounded;
        statusLabel = l10n.statusRejected;
        break;
      default:
        statusColor = Colors.grey.shade700;
        statusBg = Colors.grey.shade50;
        statusIcon = Icons.info_rounded;
        statusLabel = status;
    }

    return Column(
      children: [
        // Status badge card
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REVIEW RESULT',
                style: TextStyle(
                  color: _navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 14),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Reviewed date
              _infoRow(
                l10n.reviewedDate,
                _formatDateTime(context, reviewedAt),
                bold: true,
              ),
              if (reviewedByUid.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        l10n.reviewedBy,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: _SubmitterNameWidget(
                        storedName: '',
                        uid: reviewedByUid,
                        resolveSubmitterName: _resolveSubmitterName,
                      ),
                    ),
                  ],
                ),
              ],
              // Admin comment
              if (adminComment != null && adminComment.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.comment_rounded,
                              color: statusColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            l10n.adminComment.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        adminComment,
                        style: TextStyle(
                          color: statusColor.withValues(alpha: 0.85),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Signed document download (if approved and available)
              if (status == 'Approved' &&
                  signedDocumentUrl != null &&
                  signedDocumentUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _downloadFile(signedDocumentUrl),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            color: Colors.green.shade700, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.uploadSignedDocument,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              if (signedDocumentFileName != null &&
                                  signedDocumentFileName.isNotEmpty)
                                Text(
                                  signedDocumentFileName,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Icon(Icons.download_rounded,
                            color: Colors.green.shade700, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    AdminDocumentReviewController controller, {
    required String action,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color selectedBorderColor,
  }) {
    final isSelected = controller.selectedAction == action;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setSelectedAction(action),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected ? bgColor : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: selectedBorderColor, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.black87
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignedDocumentUpload(
    BuildContext context,
    AdminDocumentReviewController controller,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (controller.hasSignedFile) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.insert_drive_file_rounded,
              color: Colors.green.shade700,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.signedFileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${controller.signedFileSizeMB.toStringAsFixed(1)} MB',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: controller.removeSignedFile,
              child: Icon(
                Icons.close,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => controller.pickSignedFile(l10n),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.shade400,
            style: BorderStyle.solid,
            width: 1.5,
          ),
          color: Colors.green.shade50.withValues(alpha: 0.4),
        ),
        child: Column(
          children: [
            Icon(
              Icons.upload_rounded,
              color: Colors.green.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.uploadSignedDocument,
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.signedPdfWithDigitalSignature,
              style: TextStyle(
                color: Colors.green.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(
    BuildContext context,
    AdminDocumentReviewController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    if (_docId == null) return;

    final success = await controller.submitReview(_docId!, l10n);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reviewSubmittedSuccessfully),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadFile(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDateTime(BuildContext context, Timestamp? ts) {
    if (ts == null) return '—';

    final dt = ts.toDate();
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(dt);
    final time = TimeOfDay.fromDateTime(dt).format(context);

    return '$date, $time';
  }
}

// ── Fix 1: Separate widget to async-resolve submitter name ────────────
class _SubmitterNameWidget extends StatefulWidget {
  const _SubmitterNameWidget({
    required this.storedName,
    required this.uid,
    required this.resolveSubmitterName,
  });

  final String storedName;
  final String uid;
  final Future<String> Function(String uid) resolveSubmitterName;

  @override
  State<_SubmitterNameWidget> createState() => _SubmitterNameWidgetState();
}

class _SubmitterNameWidgetState extends State<_SubmitterNameWidget> {
  String? _resolvedName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // If a stored name is already available, use it immediately.
    if (widget.storedName.trim().isNotEmpty) {
      if (mounted) {
        setState(() {
          _resolvedName = widget.storedName;
          _loading = false;
        });
      }
      return;
    }

    if (widget.uid.isEmpty) {
      if (mounted) {
        setState(() {
          _resolvedName = '—';
          _loading = false;
        });
      }
      return;
    }

    final name = await widget.resolveSubmitterName(widget.uid);
    if (mounted) {
      setState(() {
        _resolvedName = name;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 14,
        width: 14,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      );
    }
    return Text(
      _resolvedName ?? '—',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}