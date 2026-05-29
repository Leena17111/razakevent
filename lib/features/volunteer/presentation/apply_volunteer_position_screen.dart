import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../l10n/app_localizations.dart';
import '../data/volunteer_position_model.dart';
import '../data/volunteer_repository.dart';

class ApplyVolunteerPositionScreen extends StatefulWidget {
  final VolunteerPositionModel position;
  final UserModel user;

  const ApplyVolunteerPositionScreen({
    super.key,
    required this.position,
    required this.user,
  });

  @override
  State<ApplyVolunteerPositionScreen> createState() =>
      _ApplyVolunteerPositionScreenState();
}

class _ApplyVolunteerPositionScreenState
    extends State<ApplyVolunteerPositionScreen> {
  final VolunteerRepository _repository = VolunteerRepository();
  final TextEditingController _experienceController = TextEditingController();

  String? _selectedFaculty;
  bool _confirmAvailability = false;
  bool _isSubmitting = false;

  final List<String> _faculties = const [
    'Azman Hashim International Business School (AHIBS)',
    'Faculty of Built Environment and Surveying',
    'Faculty of Chemical and Energy Engineering',
    'Faculty of Computing',
    'Faculty of Educational Sciences and Technology (FEST)',
    'Faculty of Electrical Engineering',
    'Faculty of Mechanical Engineering',
    'Faculty of Civil Engineering',
  ];

  bool get _canSubmit =>
      _selectedFaculty != null && _confirmAvailability && !_isSubmitting;

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    localeController.toggleLocale();
    setState(() {});
  }

  Future<void> _submitApplication() async {
    if (!_canSubmit) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() => _isSubmitting = true);

    try {
      await _repository.submitApplicationFromForm(
        position: widget.position,
        studentUid: widget.user.uid,
        fullName: widget.user.fullName,
        phoneNumber: widget.user.phoneNumber ?? '',
        faculty: _selectedFaculty!,
        previousExperience: _experienceController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.applicationSubmittedSuccessfully),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.accent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.applyForPosition),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _toggleLanguage,
            child: Text(
              localeController.value.languageCode == 'en' ? 'BM' : 'EN',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _positionCard(l10n),
                const SizedBox(height: 20),
                _label(l10n.fullName),
                _readonlyField(widget.user.fullName),
                const SizedBox(height: 16),
                _label(l10n.phone),
                _readonlyField(widget.user.phoneNumber ?? '-'),
                const SizedBox(height: 16),
                _label('${l10n.faculty} *'),
                _facultyDropdown(l10n),
                const SizedBox(height: 16),
                _label(l10n.previousExperience),
                _experienceField(),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _confirmAvailability,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.confirmAvailability),
                  onChanged: (value) {
                    setState(() => _confirmAvailability = value ?? false);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submitApplication : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.submitApplication),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _positionCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.applyForPosition,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            widget.position.roleName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.position.eventTitle} • ${widget.position.organizationName}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _readonlyField(String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(value),
    );
  }

  Widget _facultyDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _selectedFaculty,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      hint: Text(l10n.selectFaculty),
      items: _faculties
          .map(
            (faculty) => DropdownMenuItem(
              value: faculty,
              child: Text(
                faculty,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedFaculty = value),
    );
  }

  Widget _experienceField() {
    return TextField(
      controller: _experienceController,
      minLines: 4,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: '...',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}