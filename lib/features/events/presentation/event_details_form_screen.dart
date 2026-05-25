import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/event_lists.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/file_upload_service.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/event_details_controller.dart';
import '../widgets/event_date_box.dart';
import '../widgets/event_form_header.dart';
import '../widgets/event_text_input.dart';

class EventDetailsFormScreen extends StatefulWidget {
  final OrganizerProfileInfo organizerProfile;
  final EventModel? event;

  const EventDetailsFormScreen({
    super.key,
    required this.organizerProfile,
    this.event,
  });

  bool get isEditMode => event != null;

  @override
  State<EventDetailsFormScreen> createState() => _EventDetailsFormScreenState();
}

class _EventDetailsFormScreenState extends State<EventDetailsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventDetailsController _controller = EventDetailsController();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _venueController;
  late final TextEditingController _capacityController;
  late final TextEditingController _feeController;
  late final TextEditingController _contactPersonController;

  late String _selectedCategory;
  late String _selectedStatus;
  late DateTime _selectedDateTime;
  DateTime? _registrationDeadline;
  late bool _registrationEnabled;

  String? _posterFileName;
  String? _posterUrl;
  String? _posterStoragePath;
  PickedUploadFile? _pickedPosterFile;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final event = widget.event;

    _titleController = TextEditingController(text: event?.title ?? '');
    _descriptionController = TextEditingController(
      text: event?.description ?? '',
    );
    _venueController = TextEditingController(text: event?.venue ?? '');

    _capacityController = TextEditingController(
      text: event?.participantCapacity?.toString() ?? '',
    );

    _feeController = TextEditingController(
      text: event == null || event.registrationFee == 0
          ? ''
          : event.registrationFee.toStringAsFixed(2),
    );

    _contactPersonController = TextEditingController(
      text: event?.contactPerson ?? '',
    );

    _selectedCategory = event?.category ?? EventLists.eventCategories.first;
    _selectedStatus = event?.status ?? EventLists.eventStatuses.first;
    _selectedDateTime = event?.eventDateTime ?? DateTime.now();
    _registrationEnabled = event?.registrationEnabled ?? false;
    _registrationDeadline = event?.registrationDeadline;

    _posterFileName = event?.posterFileName;
    _posterUrl = event?.posterUrl;
    _posterStoragePath = event?.posterStoragePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    _feeController.dispose();
    _contactPersonController.dispose();
    super.dispose();
  }

  Future<void> _pickPoster() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final pickedFile = await _controller.pickEventPoster();

      if (pickedFile == null) return;

      setState(() {
        _pickedPosterFile = pickedFile;
        _posterFileName = pickedFile.name;
      });
    } catch (_) {
      _showError(l10n.invalidPosterFile);
    }
  }

  void _removePoster() {
    setState(() {
      _pickedPosterFile = null;
      _posterFileName = null;
      _posterUrl = null;
      _posterStoragePath = null;
    });
  }

  Future<void> _pickEventDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(
        const Duration(days: 1),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 3),
      ),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedDateTime,
      ),
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      if (_registrationDeadline != null &&
          !_registrationDeadline!.isBefore(
            _selectedDateTime,
          )) {
        _registrationDeadline = null;
      }
    });
  }

  Future<void> _pickRegistrationDeadline() async {
  final l10n = AppLocalizations.of(context)!;

  final now = DateTime.now();

  final firstDate = DateTime(
    now.year,
    now.month,
    now.day,
  );

  final lastDate = DateTime(
  _selectedDateTime.year,
  _selectedDateTime.month,
  _selectedDateTime.day,
).subtract(const Duration(days: 1));

  final selectedDate = await showDatePicker(
    context: context,
    initialDate:
        _registrationDeadline ?? firstDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null || !mounted) {
    return;
  }

  final selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(
      _registrationDeadline ??
          DateTime.now(),
    ),
  );

  if (selectedTime == null) {
    return;
  }

  final selectedDeadline = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  if (!selectedDeadline.isBefore(
    _selectedDateTime,
  )) {
    _showError(
      l10n.deadlineMustBeBeforeEvent,
    );
    return;
  }

  setState(() {
    _registrationDeadline =
        selectedDeadline;
  });
}

  Future<void> _saveEvent() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_posterFileName == null || _posterFileName!.trim().isEmpty) {
      _showError(l10n.eventPosterRequired);
      return;
    }

    if (_registrationEnabled && _registrationDeadline == null) {
      _showError(l10n.registrationDeadlineRequired);
      return;
    }

    if (_registrationEnabled &&
        _registrationDeadline != null &&
        !_registrationDeadline!.isBefore(
          _selectedDateTime,
        )) {
      _showError(
        l10n.deadlineMustBeBeforeEvent,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final existingEvent = widget.event;

      final participantCapacity = _registrationEnabled
          ? int.tryParse(_capacityController.text.trim())
          : null;

      final registrationFee = _registrationEnabled
          ? double.tryParse(_feeController.text.trim()) ?? 0.0
          : 0.0;

      final event = EventModel(
        eventId: existingEvent?.eventId ?? '',
        title: _titleController.text.trim(),
        organizationName: widget.organizerProfile.organizationName,
        organizationType: widget.organizerProfile.organizationType,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        posterFileName: _posterFileName ?? '',
        posterUrl: _posterUrl ?? '',
        posterStoragePath: _posterStoragePath ?? '',
        venue: _venueController.text.trim(),
        eventDateTime: _selectedDateTime,
        registrationEnabled: _registrationEnabled,
        registrationDeadline:
            _registrationEnabled ? _registrationDeadline : null,
        participantCapacity: participantCapacity,
        registrationFee: registrationFee,
        contactPerson:
            _registrationEnabled ? _contactPersonController.text.trim() : '',
        registeredCount: existingEvent?.registeredCount ?? 0,
        status: _selectedStatus,
        createdBy: existingEvent?.createdBy ?? widget.organizerProfile.uid,
        proposalDocumentId: existingEvent?.proposalDocumentId,
        proposalTitle: existingEvent?.proposalTitle,
        createdAt: existingEvent?.createdAt,
        updatedAt: existingEvent?.updatedAt,
      );

      final saveData = EventDetailsSaveData(
        event: event,
        pickedPosterFile: _pickedPosterFile,
        posterFileName: _posterFileName ?? '',
        posterUrl: _posterUrl ?? '',
        posterStoragePath: _posterStoragePath ?? '',
      );

      await _controller.saveEventDetails(
        data: saveData,
        isEditMode: widget.isEditMode,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? l10n.eventDetailsUpdatedSuccessfully
                : l10n.eventDetailsSavedSuccessfully,
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } catch (_) {
      _showError(l10n.unableToSaveEventDetails);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  String? _requiredValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;

    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }

    return null;
  }

  String? _positiveIntValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;

    if (!_registrationEnabled) return null;

    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }

    final number = int.tryParse(value.trim());

    if (number == null || number <= 0) {
      return l10n.enterValidNumber;
    }

    return null;
  }

  String? _feeValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;

    if (!_registrationEnabled) return null;

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final number = double.tryParse(value.trim());

    if (number == null || number < 0) {
      return l10n.enterValidFee;
    }

    return null;
  }

  String get _eventDateText {
    return DateFormat('dd MMM yyyy, h:mm a').format(_selectedDateTime);
  }

  String get _registrationDeadlineText {
    if (_registrationDeadline == null) return 'dd/mm/yyyy';
    return DateFormat('dd MMM yyyy, h:mm a').format(_registrationDeadline!);
  }

  Widget _responsiveTwoColumns({
    required BuildContext context,
    required Widget first,
    required Widget second,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 390;

    if (isSmallScreen) {
      return Column(
        children: [
          first,
          const SizedBox(height: 18),
          second,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditMode = widget.isEditMode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            EventFormHeader(
              title: isEditMode ? l10n.editEventDetails : l10n.addEventDetails,
              subtitle: l10n.completeYourEventInformation,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Transform.translate(
                  offset: const Offset(0, -22),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowDark,
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EventTextInput(
                            label: l10n.eventTitle,
                            controller: _titleController,
                            hintText: 'Hari Sukan KTR 2026',
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 18),
                          _buildOrganizationField(l10n),
                          const SizedBox(height: 18),
                          _buildCategoryDropdown(l10n),
                          const SizedBox(height: 18),
                          EventTextInput(
                            label: l10n.eventDescription,
                            controller: _descriptionController,
                            hintText: l10n.describeYourEvent,
                            maxLines: 4,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 18),
                          _buildPosterUpload(l10n),
                          const SizedBox(height: 18),
                          _responsiveTwoColumns(
                            context: context,
                            first: EventDateBox(
                              label: l10n.eventDateTime,
                              text: _eventDateText,
                              onTap: _pickEventDateTime,
                            ),
                            second: EventTextInput(
                              label: l10n.venue,
                              controller: _venueController,
                              hintText: 'Dewan KTR',
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildRegistrationSettings(l10n),
                          const SizedBox(height: 20),
                          _buildStatusSelector(l10n),
                          const SizedBox(height: 26),
                          _buildActionButtons(l10n, isEditMode),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationField(AppLocalizations l10n) {
    final type = widget.organizerProfile.organizationType;
    final name = widget.organizerProfile.organizationName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventFieldLabel(l10n.organization),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0EAFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  type.isEmpty ? 'Org' : type,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name.isEmpty ? l10n.organizationDetailsMissing : name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventFieldLabel(l10n.category),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: eventInputDecoration(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.fieldRequired;
            }

            return null;
          },
          items: EventLists.eventCategories
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedCategory = value);
          },
        ),
      ],
    );
  }

  Widget _buildPosterUpload(AppLocalizations l10n) {
    final hasPoster = _posterFileName != null && _posterFileName!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventFieldLabel(l10n.eventPoster),
        const SizedBox(height: 8),
        Stack(
          children: [
            InkWell(
              onTap: _isSaving ? null : _pickPoster,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 26,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.45),
                    width: 1.3,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.file_upload_outlined,
                      color: AppColors.primary,
                      size: 30,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(
                        left: hasPoster ? 26 : 0,
                        right: hasPoster ? 26 : 0,
                      ),
                      child: Text(
                        _posterFileName ?? l10n.uploadPosterImage,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.pngJpgUpTo5mb,
                      style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            if (hasPoster)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: AppColors.error,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _isSaving ? null : _removePoster,
                    child: const SizedBox(
                      width: 26,
                      height: 26,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.textWhite,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegistrationSettings(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.registrationSettings,
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.enableRegistration,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Switch(
                value: _registrationEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() => _registrationEnabled = value);
                },
              ),
            ],
          ),
          if (_registrationEnabled) ...[
            const SizedBox(height: 14),
            _responsiveTwoColumns(
              context: context,
              first: EventDateBox(
                label: l10n.registrationDeadline,
                text: _registrationDeadlineText,
                onTap: _pickRegistrationDeadline,
              ),
              second: EventTextInput(
                label: l10n.participantCapacity,
                controller: _capacityController,
                hintText: '100',
                keyboardType: TextInputType.number,
                validator: _positiveIntValidator,
              ),
            ),
            const SizedBox(height: 14),
            _responsiveTwoColumns(
              context: context,
              first: EventTextInput(
                label: l10n.registrationFeeRm,
                controller: _feeController,
                hintText: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _feeValidator,
              ),
              second: EventTextInput(
                label: l10n.contactPerson,
                controller: _contactPersonController,
                hintText: l10n.enterName,
                validator: _registrationEnabled ? _requiredValidator : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventFieldLabel(l10n.eventStatus),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EventLists.eventStatuses.map((status) {
            final selected = status == _selectedStatus;

            return ChoiceChip(
              label: Text(status),
              selected: selected,
              showCheckmark: false,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceSoft,
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
              labelStyle: AppTextStyles.label.copyWith(
                color: selected ? AppColors.textWhite : AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
              onSelected: (_) {
                setState(() => _selectedStatus = status);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n, bool isEditMode) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              l10n.cancel,
              style: AppTextStyles.button.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveEvent,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textWhite,
              textStyle: AppTextStyles.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textWhite,
                    ),
                  )
                : Text(isEditMode ? l10n.saveChanges : l10n.saveEvent),
          ),
        ),
      ],
    );
  }
}