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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final format = DateFormat('d MMM yyyy');
    final deadline = widget.eventDate.add(const Duration(hours: 24));
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final contentMaxWidth = viewportWidth >= 900
        ? 820.0
        : viewportWidth >= 600
        ? 700.0
        : 460.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _ReturnHeader(l10n: l10n, maxWidth: contentMaxWidth),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  children: [
                    _EquipmentDetailsCard(
                      request: widget.request,
                      borrowDate: format.format(widget.request.createdAt),
                      deadline: format.format(deadline),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      l10n.returnPhotoEvidence,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.returnPhotoEvidenceHint,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EvidencePicker(
                      bytes: _evidenceBytes,
                      fileName: _evidenceFile?.name,
                      enabled: !_isSubmitting,
                      onTap: _pickEvidence,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _BottomActions(
            maxWidth: contentMaxWidth,
            isSubmitting: _isSubmitting,
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

class _ReturnHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final double maxWidth;

  const _ReturnHeader({required this.l10n, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.returnEquipmentTitle,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          l10n.returnEquipmentSubtitle,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textWhite.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  LanguageToggle(
                    selectedLocale: localeController.value,
                    onLocaleChanged: (locale) =>
                        localeController.value = locale,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EquipmentDetailsCard extends StatelessWidget {
  final BorrowedEquipmentRequestModel request;
  final String borrowDate;
  final String deadline;

  const _EquipmentDetailsCard({
    required this.request,
    required this.borrowDate,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.returnEquipmentDetails,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.equipmentName,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${l10n.borrowQuantityShort}: ${request.quantity}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26, color: AppColors.borderLight),
          _DetailLine(label: l10n.borrowEvent, value: request.eventName),
          _DetailLine(label: l10n.borrowDate, value: borrowDate),
          _DetailLine(label: l10n.returnDeadline, value: deadline),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidencePicker extends StatelessWidget {
  final Uint8List? bytes;
  final String? fileName;
  final bool enabled;
  final VoidCallback onTap;

  const _EvidencePicker({
    required this.bytes,
    required this.fileName,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: bytes == null ? const Color(0xFF94A3B8) : AppColors.success,
          radius: 18,
        ),
        child: Container(
          height: 210,
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: bytes == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.returnUploadPhoto,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.returnUploadPhotoHint,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.memory(bytes!, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          fileName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textWhite,
                          ),
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

class _BottomActions extends StatelessWidget {
  final double maxWidth;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _BottomActions({
    required this.maxWidth,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 14,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n.returnCancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.textWhite,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(l10n.returnSubmit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 7), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
