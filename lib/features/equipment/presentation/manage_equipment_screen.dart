import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/equipment_model.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/equipment_controller.dart';

class ManageEquipmentScreen extends StatefulWidget {
  const ManageEquipmentScreen({super.key});

  @override
  State<ManageEquipmentScreen> createState() => _ManageEquipmentScreenState();
}

class _ManageEquipmentScreenState extends State<ManageEquipmentScreen> {
  final EquipmentController _controller = EquipmentController();

  late final Stream<List<EquipmentModel>> _equipmentStream;
  List<EquipmentModel>? _lastSyncedEquipment;

  final List<String> _categories = const [
    'All',
    ...EquipmentCategory.values,
  ];

  @override
  void initState() {
    super.initState();
    _equipmentStream = _controller.watchEquipment();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openAddForm() async {
    await Navigator.pushNamed(context, AppRoutes.addEquipment);
  }

  Future<void> _openEditForm(EquipmentModel equipment) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.editEquipment,
      arguments: equipment,
    );
  }

  Future<void> _confirmStatusChange(
    EquipmentModel equipment,
    AppLocalizations l10n,
  ) async {
    final isCurrentlyActive = equipment.isActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            isCurrentlyActive
                ? l10n.markUnavailableTitle
                : l10n.markAvailableTitle,
            style: AppTextStyles.title.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            isCurrentlyActive
                ? '${l10n.markUnavailableMessage}\n\n${equipment.borrowedQuantity > 0 ? l10n.borrowedItemsWarning(equipment.borrowedQuantity) : ''}'
                : l10n.markAvailableMessage,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                l10n.cancel,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCurrentlyActive ? AppColors.warning : AppColors.success,
                foregroundColor: AppColors.textWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = isCurrentlyActive
        ? await _controller.markEquipmentInactive(equipment)
        : await _controller.markEquipmentActive(equipment);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (isCurrentlyActive
                  ? l10n.equipmentMarkedUnavailable
                  : l10n.equipmentMarkedAvailable)
              : (_controller.errorMessage ?? l10n.somethingWentWrong),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  String _categoryLabel(String category, AppLocalizations l10n) {
    switch (category) {
      case 'All':
        return l10n.filterAll;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = _horizontalPadding(screenWidth);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddForm,
        backgroundColor: AppColors.primary,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: AppColors.textWhite),
        label: Text(
          l10n.addEquipment,
          style: AppTextStyles.button.copyWith(color: AppColors.textWhite),
        ),
      ),
      body: StreamBuilder<List<EquipmentModel>>(
        stream: _equipmentStream,
        builder: (context, snapshot) {
          final data = snapshot.data;

          if (data != null && !identical(data, _lastSyncedEquipment)) {
            _lastSyncedEquipment = data;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _controller.setEquipment(data);
              }
            });
          }

          final items = _controller.filteredEquipment;

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(l10n, horizontalPadding),
                _buildCategoryFilters(l10n, horizontalPadding),
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : items.isEmpty
                          ? _buildEmptyState(l10n)
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                12,
                                horizontalPadding,
                                96,
                              ),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildEquipmentCard(
                                  items[index],
                                  l10n,
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
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
        20,
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
          const SizedBox(height: 14),
          Text(
            l10n.manageEquipmentTitle,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textWhite,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            l10n.inventoryManagement,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textWhite.withOpacity(0.82),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: _controller.setSearchQuery,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: l10n.searchEquipmentHint,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textWhite.withOpacity(0.55),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textWhite.withOpacity(0.7),
              ),
              filled: true,
              fillColor: AppColors.textWhite.withOpacity(0.12),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: _searchBorder(AppColors.textWhite.withOpacity(0.15)),
              enabledBorder:
                  _searchBorder(AppColors.textWhite.withOpacity(0.15)),
              focusedBorder: _searchBorder(AppColors.textWhite),
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

  OutlineInputBorder _searchBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _buildCategoryFilters(
    AppLocalizations l10n,
    double horizontalPadding,
  ) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        10,
        horizontalPadding,
        6,
      ),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final selected = _controller.selectedCategory == category;

            return _buildFilterChip(
              label: _categoryLabel(category, l10n),
              selected: selected,
              onTap: () => _controller.setCategory(category),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? AppColors.textWhite : AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: equipment.isActive ? AppColors.surface : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: equipment.isActive ? AppColors.borderLight : AppColors.border,
        ),
        boxShadow: equipment.isActive
            ? const [
                BoxShadow(
                  color: AppColors.shadowDark,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryIcon(equipment.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (equipment.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        equipment.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      equipment.storageLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(equipment, l10n),
                  const SizedBox(height: 4),
                  _buildMoreActionsMenu(equipment, l10n),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuantityStat(
                label: l10n.quantityTotal,
                value: equipment.totalQuantity,
                color: AppColors.textPrimary,
              ),
              _buildVerticalDivider(),
              _buildQuantityStat(
                label: l10n.quantityBorrowed,
                value: equipment.borrowedQuantity,
                color: AppColors.warning,
              ),
              _buildVerticalDivider(),
              _buildQuantityStat(
                label: l10n.quantityAvailable,
                value: equipment.isActive ? equipment.availableQuantity : 0,
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoreActionsMenu(
    EquipmentModel equipment,
    AppLocalizations l10n,
  ) {
    return PopupMenuButton<String>(
      tooltip: '',
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: AppColors.textMuted,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.surface,
      elevation: 4,
      shadowColor: AppColors.shadowDark,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 142,
        maxWidth: 165,
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'edit',
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Icon(
                Icons.edit_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 9),
              Text(
                l10n.editButton,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'status',
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          enabled: !_controller.isLoading,
          child: Row(
            children: [
              Icon(
                equipment.isActive
                    ? Icons.block_rounded
                    : Icons.check_circle_outline_rounded,
                color: equipment.isActive
                    ? AppColors.warning
                    : AppColors.success,
                size: 16,
              ),
              const SizedBox(width: 9),
              Text(
                equipment.isActive
                    ? l10n.markUnavailable
                    : l10n.markAvailable,
                style: AppTextStyles.body.copyWith(
                  color: equipment.isActive
                      ? AppColors.warning
                      : AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          _openEditForm(equipment);
        } else if (value == 'status') {
          _confirmStatusChange(equipment, l10n);
        }
      },
    );
  }

  Widget _buildStatusBadge(EquipmentModel equipment, AppLocalizations l10n) {
    final isActive = equipment.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.studentBadgeBg : AppColors.adminBadgeBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? l10n.available : l10n.unavailable,
        style: AppTextStyles.label.copyWith(
          color:
              isActive ? AppColors.studentBadgeText : AppColors.adminBadgeText,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 28, color: AppColors.borderLight);
  }

  Widget _buildQuantityStat({
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: AppTextStyles.body.copyWith(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    final icon = _categoryIconData(category);
    final color = _categoryColor(category);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
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
        return AppColors.secretaryBadgeText;
      case EquipmentCategory.presentation:
        return AppColors.studentBadgeText;
      case EquipmentCategory.furniture:
        return AppColors.organizerBadgeText;
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.noEquipmentFound,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}