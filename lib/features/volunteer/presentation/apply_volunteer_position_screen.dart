import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/volunteer_position_model.dart';
import '../../../data/repository/volunteer_repository.dart';
import '../../../l10n/app_localizations.dart';

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

  Future<void> _submitApplication() async {
    if (!_canSubmit) return;

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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const _ApplicationSuccessScreen(),
        ),
      );
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
    final eventDate =
        DateFormat('d MMM yyyy, h:mm a').format(widget.position.eventDateTime);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.applyForPosition),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          _buildLanguageToggle(),
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
                _positionCard(l10n, eventDate),
                const SizedBox(height: 20),

                _formCard(
                  children: [
                    _label(l10n.fullName),
                    _readonlyField(widget.user.fullName),
                    const SizedBox(height: 16),

                    _label(l10n.phone),
                    _readonlyField(widget.user.phoneNumber ?? '-'),
                    const SizedBox(height: 16),

                    _requiredLabel(l10n.faculty),
                    _facultyDropdown(l10n),
                    const SizedBox(height: 16),

                    _label(l10n.previousExperience),
                    _experienceField(),
                    const SizedBox(height: 18),

                    _availabilityBox(eventDate, l10n),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _canSubmit ? _submitApplication : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.submitApplication),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _positionCard(AppLocalizations l10n, String eventDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.applyForPosition,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            widget.position.roleName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.position.eventTitle,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  eventDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _readonlyField(String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(value),
    );
  }

  Widget _facultyDropdown(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedFaculty,
        isExpanded: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
      ),
    );
  }

  Widget _experienceField() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: _experienceController,
        minLines: 4,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Describe any relevant experience...',
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _availabilityBox(String eventDate, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _confirmAvailability ? AppColors.primary : AppColors.borderLight,
          width: _confirmAvailability ? 1.5 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: _confirmAvailability,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Text(
          l10n.confirmAvailability,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              const Icon(Icons.event_available_rounded,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Event date: $eventDate',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        onChanged: (value) {
          setState(() => _confirmAvailability = value ?? false);
        },
      ),
    );
  }

  Widget _buildLanguageToggle() {
    final isBM = localeController.value.languageCode == 'ms';

    return Container(
      margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langButton(isBM, 'EN'),
          _langButton(isBM, 'BM'),
        ],
      ),
    );
  }

  Widget _langButton(bool isBM, String label) {
    final isActive = (label == 'BM' && isBM) || (label == 'EN' && !isBM);

    return GestureDetector(
      onTap: () {
        localeController.value = Locale(label == 'EN' ? 'en' : 'ms');
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ApplicationSuccessScreen extends StatelessWidget {
  const _ApplicationSuccessScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.teal.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 54,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Application Submitted!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your application has been submitted. The Organizer Head will review your application soon. You may track your application status from the My Applications tab.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
  Navigator.pop(context);
  Navigator.pop(context, true);
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Back to Positions'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}