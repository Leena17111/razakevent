import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/equipment_model.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/equipment_controller.dart';

class EquipmentFormScreen extends StatefulWidget {
  final EquipmentModel? equipment;

  const EquipmentFormScreen({
    super.key,
    this.equipment,
  });

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  final EquipmentController _controller = EquipmentController();

  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _storageLocationController = TextEditingController();

  String _selectedCategory = EquipmentCategory.audio;
  EquipmentModel? _equipmentFromArgs;

  EquipmentModel? get _editingEquipment =>
      widget.equipment ?? _equipmentFromArgs;

  bool get _isEdit => _editingEquipment != null;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);

    if (widget.equipment != null) {
      _fillForm(widget.equipment!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_equipmentFromArgs != null || widget.equipment != null) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is EquipmentModel) {
      _equipmentFromArgs = args;
      _fillForm(args);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _itemNameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _storageLocationController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _fillForm(EquipmentModel equipment) {
    _selectedCategory = equipment.category;
    _itemNameController.text = equipment.itemName;
    _quantityController.text = equipment.totalQuantity.toString();
    _descriptionController.text = equipment.description;
    _storageLocationController.text = equipment.storageLocation;
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final totalQuantity = int.parse(_quantityController.text.trim());

    final success = _isEdit
        ? await _controller.updateEquipment(
            existingEquipment: _editingEquipment!,
            category: _selectedCategory,
            itemName: _itemNameController.text,
            description: _descriptionController.text,
            storageLocation: _storageLocationController.text,
            totalQuantity: totalQuantity,
          )
        : await _controller.addEquipment(
            category: _selectedCategory,
            itemName: _itemNameController.text,
            description: _descriptionController.text,
            storageLocation: _storageLocationController.text,
            totalQuantity: totalQuantity,
          );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (_isEdit ? l10n.equipmentUpdated : l10n.equipmentAdded)
              : _friendlyError(_controller.errorMessage, l10n),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );

    if (success) Navigator.pop(context);
  }

  String _friendlyError(String? error, AppLocalizations l10n) {
    switch (error) {
      case 'quantityCannotBeLessThanBorrowed':
        return l10n.quantityCannotBeLessThanBorrowed;
      case 'equipmentNotFound':
        return l10n.equipmentNotFound;
      case 'equipmentIdMissing':
        return l10n.equipmentIdMissing;
      default:
        return error ?? l10n.somethingWentWrong;
    }
  }

  String _categoryLabel(String category, AppLocalizations l10n) {
    switch (category) {
      case EquipmentCategory.audio:
        return l10n.categoryAudio;
      case EquipmentCategory.presentation:
        return l10n.categoryPresentation;
      case EquipmentCategory.furniture:
        return l10n.categoryFurniture;
      case EquipmentCategory.decoration:
        return l10n.categoryDecoration;
      case EquipmentCategory.sports:
        return l10n.categorySports;
      case EquipmentCategory.electrical:
        return l10n.categoryElectrical;
      default:
        return l10n.categoryOthers;
    }
  }

  double _horizontalPadding(double width) {
    if (width >= 900) return 28;
    return 18;
  }

  double _formMaxWidth(double width) {
    return width;
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = _horizontalPadding(screenWidth);
    final formMaxWidth = _formMaxWidth(screenWidth);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(l10n, horizontalPadding),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  22,
                  horizontalPadding,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: formMaxWidth),
                    child: _buildFormCard(l10n),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, double horizontalPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        14,
        horizontalPadding,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textWhite,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              _buildLanguageToggle(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _isEdit ? l10n.editEquipment : l10n.addEquipment,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textWhite,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.inventoryManagement,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textWhite.withOpacity(0.82),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return LanguageToggle(
          selectedLocale: locale,
          onLocaleChanged: localeController.setLocale,
        );
      },
    );
  }

  Widget _buildFormCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
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
            _buildLabel(l10n.category),
            const SizedBox(height: 8),
            _buildCategoryDropdown(l10n),
            const SizedBox(height: 18),
            _buildLabel('${l10n.itemName} *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _itemNameController,
              hint: l10n.itemNameHint,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildLabel('${l10n.totalQuantity} *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _quantityController,
              hint: l10n.totalQuantityHint,
              keyboardType: TextInputType.text,
              validator: (value) => _validateQuantity(value, l10n),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.quantityBorrowed}: ${_editingEquipment!.borrowedQuantity}  •  ${l10n.quantityAvailable}: ${_editingEquipment!.availableQuantity}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
            const SizedBox(height: 18),
            _buildLabel(l10n.descriptionOptional),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hint: l10n.descriptionHint,
              maxLines: 2,
            ),
            const SizedBox(height: 18),
            _buildLabel('${l10n.storageLocation} *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _storageLocationController,
              hint: l10n.storageLocationHint,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            _buildButtons(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildCategoryDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
      ),
      decoration: _inputDecoration(),
      selectedItemBuilder: (context) {
        return EquipmentCategory.values.map((category) {
          return Row(
            children: [
              _categoryIcon(category),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _categoryLabel(category, l10n),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        }).toList();
      },
      items: EquipmentCategory.values.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Row(
            children: [
              _categoryIcon(category),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _categoryLabel(category, l10n),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedCategory = value);
      },
    );
  }

  Widget _categoryIcon(String category) {
    final color = _categoryColor(category);
    final icon = _categoryIconData(category);

    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }

  IconData _categoryIconData(String category) {
    switch (category) {
      case EquipmentCategory.audio:
        return Icons.mic_rounded;
      case EquipmentCategory.presentation:
        return Icons.slideshow_rounded;
      case EquipmentCategory.furniture:
        return Icons.chair_rounded;
      case EquipmentCategory.decoration:
        return Icons.celebration_rounded;
      case EquipmentCategory.sports:
        return Icons.sports_soccer_rounded;
      case EquipmentCategory.electrical:
        return Icons.electrical_services_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case EquipmentCategory.audio:
        return AppColors.communityBadgeText;
      case EquipmentCategory.presentation:
        return AppColors.studentBadgeText;
      case EquipmentCategory.furniture:
        return AppColors.clubBadgeText;
      case EquipmentCategory.decoration:
        return AppColors.accent;
      case EquipmentCategory.sports:
        return AppColors.success;
      case EquipmentCategory.electrical:
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _inputDecoration(hint: hint, maxLines: maxLines),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    int maxLines = 1,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body.copyWith(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
      filled: true,
      fillColor: AppColors.surfaceSoft,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: maxLines > 1 ? 18 : 16,
      ),
      border: _fieldBorder(AppColors.borderLight),
      enabledBorder: _fieldBorder(AppColors.borderLight),
      focusedBorder: _fieldBorder(AppColors.primary),
      errorBorder: _fieldBorder(AppColors.error),
      focusedErrorBorder: _fieldBorder(AppColors.error),
    );
  }

  OutlineInputBorder _fieldBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }

  String? _validateQuantity(String? value, AppLocalizations l10n) {
  final trimmedValue = value?.trim() ?? '';

  if (trimmedValue.isEmpty) return l10n.fieldRequired;

  final quantity = int.tryParse(trimmedValue);

  if (quantity == null) return l10n.enterValidNumber;

  if (quantity <= 0) return l10n.quantityCannotBeNegative;

  final editing = _editingEquipment;
  if (editing != null && quantity < editing.borrowedQuantity) {
    return l10n.quantityCannotBeLessThanBorrowed;
  }

  return null;
}

  Widget _buildButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
                _controller.isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(l10n.cancel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _controller.isLoading ? null : () => _submit(l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
              elevation: 4,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _controller.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textWhite,
                    ),
                  )
                : Text(
                    l10n.save,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}