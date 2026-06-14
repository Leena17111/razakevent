import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/borrowed_equipment_request_model.dart';
import '../../../data/repository/equipment_borrow_repository.dart';
import '../../../l10n/app_localizations.dart';

class ReturnBorrowedEquipmentArguments {
  final BorrowedEquipmentRequestModel request;
  final DateTime eventDate;

  const ReturnBorrowedEquipmentArguments({
    required this.request,
    required this.eventDate,
  });
}

class ReturnBorrowedEquipmentScreen extends StatefulWidget {
  final BorrowedEquipmentRequestModel request;
  final DateTime eventDate;

  const ReturnBorrowedEquipmentScreen({
    super.key,
    required this.request,
    required this.eventDate,
  });

  @override
  State<ReturnBorrowedEquipmentScreen> createState() =>
      _ReturnBorrowedEquipmentScreenState();
}

class _ReturnBorrowedEquipmentScreenState
    extends State<ReturnBorrowedEquipmentScreen> {
  final EquipmentBorrowRepository _repository = EquipmentBorrowRepository();
  XFile? _evidenceFile;
  Uint8List? _evidenceBytes;
  bool _isSubmitting = false;

  Future<void> _pickEvidence() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _evidenceFile = file;
      _evidenceBytes = bytes;
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_evidenceFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.returnPhotoRequired)));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _repository.returnBorrowedEquipment(
        widget.request.id,
        widget.request.equipmentId,
        widget.request.quantity,
        _evidenceFile!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.returnSubmitSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.returnSubmitError),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final format = DateFormat('d MMM yyyy, h:mm a');
    final deadline = widget.eventDate.add(const Duration(hours: 24));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        title: Text(l10n.returnEquipmentTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: LanguageToggle(
              selectedLocale: localeController.value,
              onLocaleChanged: (locale) => localeController.value = locale,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.request.equipmentName, style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _detailRow(
                  Icons.numbers,
                  l10n.borrowQuantity,
                  widget.request.quantity.toString(),
                ),
                _detailRow(
                  Icons.event_outlined,
                  l10n.borrowEvent,
                  widget.request.eventName,
                ),
                _detailRow(
                  Icons.calendar_today_outlined,
                  l10n.borrowDate,
                  format.format(widget.request.createdAt),
                ),
                _detailRow(
                  Icons.schedule,
                  l10n.returnDeadline,
                  format.format(deadline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.returnPhotoEvidence, style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text(l10n.returnPhotoEvidenceHint, style: AppTextStyles.caption),
          const SizedBox(height: 12),
          InkWell(
            onTap: _isSubmitting ? null : _pickEvidence,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: _evidenceBytes == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_a_photo_outlined,
                          size: 42,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 10),
                        Text(l10n.returnUploadPhoto, style: AppTextStyles.body),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.memory(
                        _evidenceBytes!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.assignment_turned_in_outlined),
            label: Text(l10n.returnSubmit),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
