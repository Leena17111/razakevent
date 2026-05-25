import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/volunteer_position_model.dart';
import '../logic/volunteer_position_controller.dart';

class AddPositionScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final DateTime eventDateTime;

  const AddPositionScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventDateTime,
  });

  @override
  State<AddPositionScreen> createState() => _AddPositionScreenState();
}

class _AddPositionScreenState extends State<AddPositionScreen> {
  final _formKey = GlobalKey<FormState>();
  final VolunteerPositionController _controller =
      VolunteerPositionController();

  final _roleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _volunteersController = TextEditingController();

  DateTime? _deadline;

  @override
  void dispose() {
    _roleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _volunteersController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n, currentLocale),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildEventCard(),
                          const SizedBox(height: 16),
                          _buildFormCard(l10n),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textWhite,
                                elevation: 5,
                                shadowColor: AppColors.primary.withOpacity(0.25),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed:
                                  _controller.isSaving ? null : _savePosition,
                              child: _controller.isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: AppColors.textWhite,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : Text(l10n.savePosition),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, Locale currentLocale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textWhite,
                  size: 20,
                ),
              ),
              const Spacer(),
              LanguageToggle(
                selectedLocale: currentLocale,
                onLocaleChanged: (locale) {
                  localeController.value = locale;
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            l10n.addVolunteerPosition,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textWhite,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.eventTitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textWhite.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.eventTitle,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDate(widget.eventDateTime),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _roleController,
            label: l10n.roleName,
            hint: l10n.roleNameHint,
            prefixIcon: Icons.badge_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.fieldRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: l10n.description,
            hint: l10n.describeVolunteerDuties,
            prefixIcon: Icons.notes_rounded,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.fieldRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _requirementsController,
            label: l10n.requirements,
            hint: l10n.listSkillsAvailability,
            prefixIcon: Icons.checklist_rounded,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.fieldRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _volunteersController,
            label: l10n.numberOfVolunteersNeeded,
            hint: 'e.g. 10',
            prefixIcon: Icons.groups_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.fieldRequired;
              }

              final number = int.tryParse(value.trim());

              if (number == null || number <= 0) {
                return l10n.enterValidVolunteerNumber;
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDeadlinePicker(l10n),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: maxLines == 1
                ? Icon(
                    prefixIcon,
                    color: AppColors.primary,
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlinePicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.applicationDeadline,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final now = DateTime.now();
            final firstDate = DateTime(now.year, now.month, now.day);
            final lastDate = DateTime(now.year + 1);

            final selectedDate = await showDatePicker(
              context: context,
              initialDate: firstDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );

            if (selectedDate == null) return;

            if (!mounted) return;

            final selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (selectedTime == null) return;

            setState(() {
              _deadline = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _deadline == null
                        ? l10n.applicationDeadline
                        : _formatDate(_deadline!),
                    style: AppTextStyles.body.copyWith(
                      color: _deadline == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontWeight: _deadline == null
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _savePosition() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deadlineRequired),
        ),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final position = VolunteerPositionModel(
      positionId: '',
      eventId: widget.eventId,
      eventTitle: widget.eventTitle,
      organizerId: userId,
      roleName: _roleController.text.trim(),
      description: _descriptionController.text.trim(),
      requirements: _requirementsController.text.trim(),
      volunteersNeeded: int.parse(_volunteersController.text.trim()),
      approvedCount: 0,
      totalApplications: 0,
      applicationDeadline: _deadline!,
      eventDateTime: widget.eventDateTime,
      status: 'open',
      createdAt: DateTime.now(),
    );

    await _controller.addPosition(position);

    if (!mounted) return;

    if (_controller.hasSaveError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToSavePosition),
        ),
      );
      return;
    }

    if (_controller.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text(l10n.positionAddedSuccessfully),
        ),
      );

      Navigator.pop(context);
    }
  }

 String _formatDate(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '${date.day}/${date.month}/${date.year} • $hour:$minute';
}
}