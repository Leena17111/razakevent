import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logic/admin_document_review_controller.dart';
// TODO: Add localization keys for admin review screen
// import '../../../l10n/app_localizations.dart';

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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _docId = ModalRoute.of(context)!.settings.arguments as String?;

    return ChangeNotifierProvider(
      create: (_) => AdminDocumentReviewController(),
      child: Builder(builder: (context) {
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
                return const Center(child: Text('Document not found.'));
              }

              final data =
                  snapshot.data!.data() as Map<String, dynamic>;
              return _buildContent(context, data);
            },
          ),
        );
      }),
    );
  }

  Widget _buildContent(
      BuildContext context, Map<String, dynamic> data) {
    final title = data['title'] as String? ?? '';
    final orgType = data['organizationType'] as String? ?? '';
    final orgName = data['organizationName'] as String? ?? '';
    final docType = data['documentType'] as String? ?? '';
    final fileName = data['fileName'] as String? ?? '';
    final fileSize = data['fileSize'] as int? ?? 0;
    final fileUrl = data['fileUrl'] as String? ?? '';
    final submittedAt = data['submittedAt'] as Timestamp?;
    final submittedByName = data['submittedByName'] as String? ?? '';
    final remarks = data['remarks'] as String?;

    return Column(
      children: [
        _buildHeader(context, title),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PDF Preview Card
                _buildPdfPreviewCard(fileName, fileSize, fileUrl),
                const SizedBox(height: 16),

                // Document Information Card
                _buildDocumentInfoCard(
                    title, orgType, orgName, docType,
                    submittedByName, submittedAt, remarks),
                const SizedBox(height: 16),

                // Review Actions Card
                _buildReviewActionsCard(context),
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
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Review Document',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              // Language toggle placeholder
              // TODO: Add LanguageToggle widget here if needed
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── PDF Preview Card ──────────────────────────────────────────────
  Widget _buildPdfPreviewCard(
      String fileName, int fileSize, String fileUrl) {
    final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PDF PREVIEW',
                style: TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5),
              ),
              GestureDetector(
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
                    color: fileUrl.isNotEmpty
                        ? _navy
                        : Colors.grey,
                    size: 20,
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
                            color:
                                Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Icon(Icons.insert_drive_file_rounded,
                        color: _navy.withValues(alpha: 0.8), size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fileName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sizeMB MB',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Document Information Card ─────────────────────────────────────
  Widget _buildDocumentInfoCard(
    String title,
    String orgType,
    String orgName,
    String docType,
    String submittedBy,
    Timestamp? submittedAt,
    String? remarks,
  ) {
    final isClub = orgType == 'Club';
    final chipColor = isClub ? Colors.purple : _navy;
    final chipBg = isClub
        ? Colors.purple.withValues(alpha: 0.1)
        : const Color(0xFFE8EAF6);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DOCUMENT INFORMATION',
            style: TextStyle(
                color: _navy,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 14),
          _infoRow('Event Title', title, bold: true),
          const SizedBox(height: 10),
          // Organization row with chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 120,
                child: Text('Organization',
                    style:
                        TextStyle(color: Colors.grey, fontSize: 13)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  orgType,
                  style: TextStyle(
                      color: chipColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(orgName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow('Document Type', docType, bold: true),
          const SizedBox(height: 10),
          _infoRow('Submitted By', submittedBy.isNotEmpty ? submittedBy : '—',
              bold: true),
          const SizedBox(height: 10),
          _infoRow('Submitted Date', _formatDateTime(submittedAt), bold: true),
          if (remarks != null && remarks.isNotEmpty) ...[
            const SizedBox(height: 10),
            _infoRow('Remarks', remarks, bold: true),
          ],
        ],
      ),
    );
  }

  // ── Review Actions Card ───────────────────────────────────────────
  Widget _buildReviewActionsCard(BuildContext context) {
    return Consumer<AdminDocumentReviewController>(
      builder: (context, controller, _) {
        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REVIEW ACTIONS',
                style: TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 16),

              // Action selector row
              Row(
                children: [
                  _actionButton(
                    context,
                    controller,
                    action: 'Approve',
                    icon: Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    bgColor: Colors.green.shade50,
                    selectedBorderColor: Colors.green.shade700,
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    context,
                    controller,
                    action: 'Request Correction',
                    icon: Icons.error_rounded,
                    color: Colors.orange.shade600,
                    bgColor: Colors.orange.shade50,
                    selectedBorderColor: Colors.orange.shade700,
                    label: 'Request\nCorrection',
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    context,
                    controller,
                    action: 'Reject',
                    icon: Icons.cancel_rounded,
                    color: Colors.red.shade600,
                    bgColor: Colors.red.shade50,
                    selectedBorderColor: Colors.red.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Admin Comment
              const Text(
                'Admin Comment',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                onChanged: controller.setAdminComment,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add your review comments here...',
                  hintStyle:
                      const TextStyle(color: Colors.grey, fontSize: 13),
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

              // Signed document upload (only for Approve)
              if (controller.isApprove) ...[
                _buildSignedDocumentUpload(context, controller),
                const SizedBox(height: 16),
              ],

              // Error message
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
                      Icon(Icons.error_outline,
                          color: Colors.red.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage!,
                          style: TextStyle(
                              color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
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
                        borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(
    BuildContext context,
    AdminDocumentReviewController controller, {
    required String action,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color selectedBorderColor,
    String? label,
  }) {
    final isSelected = controller.selectedAction == action;
    final displayLabel = label ?? action;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setSelectedAction(action),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
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
                displayLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color:
                      isSelected ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignedDocumentUpload(
      BuildContext context, AdminDocumentReviewController controller) {
    if (controller.hasSignedFile) {
      // Show picked file
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file_rounded,
                color: Colors.green.shade700, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.signedFileName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${controller.signedFileSizeMB.toStringAsFixed(1)} MB',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: controller.removeSignedFile,
              child: Icon(Icons.close,
                  color: Colors.grey.shade600, size: 20),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: controller.pickSignedFile,
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
            Icon(Icons.upload_rounded,
                color: Colors.green.shade600, size: 32),
            const SizedBox(height: 8),
            Text(
              'Upload Signed Document',
              style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF with digital signature',
              style: TextStyle(
                  color: Colors.green.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────
  Future<void> _submitReview(
      BuildContext context, AdminDocumentReviewController controller) async {
    if (_docId == null) return;

    final success = await controller.submitReview(_docId!);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review submitted successfully.'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────
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
              offset: const Offset(0, 2)),
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
          child: Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
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