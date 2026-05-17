import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/document_edit_controller.dart';
import '../../../core/constants/organization_lists.dart';
import '../../../core/constants/event_lists.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

class EditDocumentScreen extends StatelessWidget {
  const EditDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return ChangeNotifierProvider(
      create: (_) => DocumentEditController()..loadFromData(args['data']),
      child: _EditDocumentView(docId: args['docId']),
    );
  }
}

class _EditDocumentView extends StatefulWidget {
  final String docId;
  const _EditDocumentView({required this.docId});

  @override
  State<_EditDocumentView> createState() => _EditDocumentViewState();
}

class _EditDocumentViewState extends State<_EditDocumentView> {
  late TextEditingController _titleController;
  late TextEditingController _remarksController;
  bool _initialized = false;

  static const Color _navy = Color(0xFF1A237E);
  static const Color _inputBg = Color(0xFFF3F4F6);

  @override
  void dispose() {
    _titleController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DocumentEditController>();
    final l10n = AppLocalizations.of(context)!;

    // Initialize text controllers once with existing values
    if (!_initialized) {
      _titleController = TextEditingController(text: controller.title);
      _remarksController = TextEditingController(text: controller.remarks);
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrganizationTypeToggle(controller, l10n),
                  const SizedBox(height: 20),
                  _buildOrganizationNameDropdown(controller, l10n),
                  const SizedBox(height: 20),
                  _buildTitleField(controller, l10n),
                  const SizedBox(height: 20),
                  _buildDocumentTypeDropdown(controller, l10n),
                  const SizedBox(height: 20),
                  _buildFileSection(controller, l10n),
                  const SizedBox(height: 20),
                  _buildRemarksField(controller, l10n),
                  const SizedBox(height: 8),
                  if (controller.errorMessage != null)
                    _buildErrorMessage(controller.errorMessage!),
                  const SizedBox(height: 24),
                  _buildSaveButton(context, controller, l10n),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────
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
                onLocaleChanged: (locale) => localeController.value = locale,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.editEventDetails,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.submitDocumentationForReview,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Organization Type Toggle ──────────────────────────────────────
  Widget _buildOrganizationTypeToggle(DocumentEditController controller, AppLocalizations l10n) {
    final labels = [l10n.exco, l10n.club];
    final values = ['Exco', 'Club'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.organizationType),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(labels.length, (i) {
              final selected = controller.organizationType == values[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.setOrganizationType(values[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: selected
                          ? [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4)]
                          : [],
                    ),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        color: selected ? _navy : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Organization Name Dropdown ────────────────────────────────────
  Widget _buildOrganizationNameDropdown(DocumentEditController controller, AppLocalizations l10n) {
    final options = controller.organizationType == 'Exco'
        ? OrganizationLists.excoNames
        : OrganizationLists.clubNames;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.organization),
        const SizedBox(height: 8),
        _dropdownField(
          value: controller.organizationName,
          hint: l10n.selectEvent,
          icon: Icons.business_outlined,
          items: options,
          onChanged: controller.setOrganizationName,
        ),
      ],
    );
  }

  // ── Title Field ───────────────────────────────────────────────────
  Widget _buildTitleField(DocumentEditController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.eventDocumentTitle),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          onChanged: controller.setTitle,
          decoration: InputDecoration(
            hintText: 'e.g., Hari Sukan KTR 2026',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.description_outlined, color: Colors.grey),
            filled: true,
            fillColor: _inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  // ── Document Type Dropdown ────────────────────────────────────────
  Widget _buildDocumentTypeDropdown(DocumentEditController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.documentType),
        const SizedBox(height: 8),
        _dropdownField(
          value: controller.documentType,
          hint: l10n.selectDocumentType,
          icon: Icons.insert_drive_file_outlined,
          items: EventLists.documentTypes,
          onChanged: controller.setDocumentType,
        ),
      ],
    );
  }

  // ── File Section ──────────────────────────────────────────────────
  Widget _buildFileSection(DocumentEditController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.uploadPdfDocument),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _navy.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.picture_as_pdf_rounded, size: 36, color: _navy),
              const SizedBox(height: 8),
              Text(
                controller.displayFileName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${controller.displayFileSizeMB.toStringAsFixed(1)} MB',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              // Replace button
              OutlinedButton.icon(
                onPressed: controller.isLoading ? null : controller.pickNewFile,
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: Text(l10n.replacePdf, style: const TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _navy,
                  side: const BorderSide(color: _navy),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (controller.fileReplaced) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: controller.cancelFileReplacement,
                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                  label: Text(l10n.cancelReplacement, style: TextStyle(color: Colors.red, fontSize: 13)),
                ),
              ],
            ],
          ),
        ),
        if (controller.fileReplaced)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${l10n.newFileSelected}: ${controller.displayFileName}',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Remarks Field ─────────────────────────────────────────────────
  Widget _buildRemarksField(DocumentEditController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.remarksOptional),
        const SizedBox(height: 8),
        TextField(
          controller: _remarksController,
          onChanged: controller.setRemarks,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.additionalNotesHint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.chat_bubble_outline, color: Colors.grey),
            ),
            filled: true,
            fillColor: _inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  // ── Error Message ─────────────────────────────────────────────────
  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ── Save Button ───────────────────────────────────────────────────
  Widget _buildSaveButton(BuildContext context, DocumentEditController controller, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading
            ? null
            : () => _handleSave(context, controller, l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          disabledBackgroundColor: _navy.withValues(alpha: 0.5),
        ),
        child: controller.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                l10n.saveChanges,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, DocumentEditController controller, AppLocalizations l10n) async {
    final success = await controller.update(widget.docId);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.documentUpdatedSuccessfully),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop(true); // pop with true = refresh details
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────
  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A237E)));
  }

  Widget _dropdownField({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(children: [
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 10),
            Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ]),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          items: items
              .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}