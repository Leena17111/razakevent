import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/document_upload_controller.dart';
import '../../../core/constants/organization_lists.dart';
import '../../../core/constants/event_lists.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

class UploadDocumentScreen extends StatelessWidget {
  const UploadDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DocumentUploadController(),
      child: const _UploadDocumentView(),
    );
  }
}

class _UploadDocumentView extends StatefulWidget {
  const _UploadDocumentView();

  @override
  State<_UploadDocumentView> createState() => _UploadDocumentViewState();
}

class _UploadDocumentViewState extends State<_UploadDocumentView> {
  final _titleController = TextEditingController();
  final _remarksController = TextEditingController();

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
    final controller = context.watch<DocumentUploadController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context, controller, l10n),
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
                  _buildFileUploadArea(controller, l10n),
                  const SizedBox(height: 20),
                  _buildRemarksField(controller, l10n),
                  const SizedBox(height: 8),
                  if (controller.errorMessage != null)
                    _buildErrorMessage(controller.errorMessage!),
                  const SizedBox(height: 24),
                  _buildSubmitButton(context, controller, l10n),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DocumentUploadController controller, AppLocalizations l10n) {
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
            l10n.uploadEventDocument,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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

  Widget _buildOrganizationTypeToggle(DocumentUploadController controller, AppLocalizations l10n) {
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
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
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

  Widget _buildOrganizationNameDropdown(DocumentUploadController controller, AppLocalizations l10n) {
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

  Widget _buildTitleField(DocumentUploadController controller, AppLocalizations l10n) {
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

  Widget _buildDocumentTypeDropdown(DocumentUploadController controller, AppLocalizations l10n) {
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

  Widget _buildFileUploadArea(DocumentUploadController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.uploadPdfDocument),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: controller.isLoading ? null : controller.pickFile,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: controller.hasFile ? _navy : Colors.grey.shade300,
                width: controller.hasFile ? 1.5 : 1,
              ),
            ),
            child: controller.hasFile
                ? _buildFilePreview(controller)
                : _buildFilePickerPrompt(l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerPrompt(AppLocalizations l10n) {
    return Column(
      children: [
        Icon(Icons.upload_rounded, size: 36, color: _navy),
        const SizedBox(height: 8),
        Text(l10n.choosePdfFile,
            style: TextStyle(fontWeight: FontWeight.w600, color: _navy, fontSize: 14)),
        const SizedBox(height: 4),
        Text(l10n.pdfOnlyMax10mb, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildFilePreview(DocumentUploadController controller) {
    return Column(
      children: [
        Icon(Icons.picture_as_pdf_rounded, size: 36, color: _navy),
        const SizedBox(height: 8),
        Text(controller.fileName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text('${controller.fileSizeMB.toStringAsFixed(1)} MB',
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: controller.removeFile,
          icon: const Icon(Icons.close, size: 16, color: Colors.red),
          label: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildRemarksField(DocumentUploadController controller, AppLocalizations l10n) {
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

  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, DocumentUploadController controller, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading ? null : () => _handleSubmit(context, controller, l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          disabledBackgroundColor: _navy.withValues(alpha: 0.5),
        ),
        child: controller.isLoading
            ? const SizedBox(height: 20, width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(l10n.submitDocument,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _handleSubmit(
      BuildContext context, DocumentUploadController controller, AppLocalizations l10n) async {
    final success = await controller.submit();
    if (!context.mounted) return;
    if (success) _showSuccessDialog(context, controller);
  }

  void _showSuccessDialog(BuildContext context, DocumentUploadController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Document Submitted!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text(
              'Your document has been submitted for review. You can track its status in the Document Status screen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.reset();
              _titleController.clear();
              _remarksController.clear();
            },
            child: const Text('Upload Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

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