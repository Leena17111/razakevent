import 'package:flutter/material.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/localization/locale_controller.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/repository/equipment_borrow_repository.dart';
import '../../../data/models/special_equipment_request_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'equipment_request_tabs.dart';

IconData _categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'audio':
      return Icons.mic_none_outlined;
    case 'presentation':
      return Icons.present_to_all_outlined;
    case 'furniture':
      return Icons.chair_outlined;
    case 'decoration':
      return Icons.celebration_outlined;
    case 'sports':
      return Icons.sports_soccer_outlined;
    case 'electrical':
      return Icons.electrical_services_outlined;
    default:
      return Icons.category_outlined;
  }
}

Color _categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'audio':
      return AppColors.primary;
    case 'presentation':
      return AppColors.primaryLight;
    case 'furniture':
      return AppColors.warning;
    case 'decoration':
      return AppColors.success;
    case 'sports':
      return Colors.orange;
    case 'electrical':
      return Colors.purple;
    default:
      return AppColors.textSecondary;
  }
}

// BorrowEquipmentScreen
class BorrowEquipmentScreen extends StatefulWidget {
  final EligibleEvent event;
  final bool isCompleted;

  const BorrowEquipmentScreen({super.key, required this.event, this.isCompleted = false});

  @override
  State<BorrowEquipmentScreen> createState() => _BorrowEquipmentScreenState();
}

class _BorrowEquipmentScreenState extends State<BorrowEquipmentScreen>
    with SingleTickerProviderStateMixin {
  final EquipmentBorrowRepository _repo = EquipmentBorrowRepository();

  late TabController _tabController;
  late Future<List<EquipmentItem>> _equipmentFuture;

  final Map<String, BorrowCartItem> _cart = {};
  bool _isSubmitting = false;

  String _selectedCategory = 'All';
  String _searchQuery = '';

  static const List<String> _categories = [
    'All', 'Audio', 'Presentation', 'Furniture',
    'Decoration', 'Sports', 'Electrical', 'Others',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.isCompleted ? 1 : 0,
    );
    _tabController.addListener(() => setState(() {}));
    _equipmentFuture = _repo.fetchAvailableEquipment();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<EquipmentItem> _filterItems(List<EquipmentItem> all) {
    return all.where((item) {
      final matchCat = _selectedCategory == 'All' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final q = _searchQuery.toLowerCase().trim();
      final matchSearch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.storageLocation.toLowerCase().contains(q) ||
          item.availableQuantity.toString().contains(q);
      return matchCat && matchSearch;
    }).toList();
  }

  int get _cartCount => _cart.values.fold(0, (sum, ci) => sum + ci.quantity);

  void _addToCart(EquipmentItem item) {
    setState(() {
      if (_cart.containsKey(item.id)) {
        if (_cart[item.id]!.quantity < item.availableQuantity) {
          _cart[item.id]!.quantity++;
        }
      } else {
        if (item.availableQuantity > 0) {
          _cart[item.id] = BorrowCartItem(equipment: item, quantity: 1);
        }
      }
    });
  }

  void _decrementCart(EquipmentItem item) {
    setState(() {
      if (_cart.containsKey(item.id)) {
        if (_cart[item.id]!.quantity > 1) {
          _cart[item.id]!.quantity--;
        } else {
          _cart.remove(item.id);
        }
      }
    });
  }

  void _refreshAvailableEquipment() {
    if (!mounted) return;
    setState(() {
      _equipmentFuture = _repo.fetchAvailableEquipment();
    });
  }

  // Confirm Borrow Dialog
  Future<void> _showConfirmDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.borrowConfirmTitle, style: AppTextStyles.h3)),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(false),
                      child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(l10n.borrowConfirmSubtitle,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                const Divider(height: 20),
                ..._cart.values.map((ci) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _categoryColor(ci.equipment.category).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_categoryIcon(ci.equipment.category),
                                size: 16, color: _categoryColor(ci.equipment.category)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(ci.equipment.name, style: AppTextStyles.body)),
                          Text('Ã—${ci.quantity}',
                              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Text(l10n.borrowConfirmCancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(l10n.borrowConfirmSubmit,
                            style: const TextStyle(color: AppColors.textWhite)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed == true) await _submitBorrow(context);
  }

  Future<void> _submitBorrow(BuildContext context) async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);
    try {
      await _repo.submitBorrowRequest(
        eventId: widget.event.id,
        eventName: widget.event.name,
        eventDate: widget.event.eventDate,
        cartItems: _cart.values.toList(),
      );
      if (!mounted) return;
      setState(() {
        _cart.clear();
        _isSubmitting = false;
        _equipmentFuture = _repo.fetchAvailableEquipment();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 10),
          Text(l10n.borrowSubmitSuccess),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.borrowSubmitError),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _showSpecialRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SpecialRequestSheet(event: widget.event, repo: _repo),
    );
  }

  // Locked Available Tab â€” shown when event is completed
  Widget _buildLockedAvailableTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              l10n.borrowEventAvailableTabLocked,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Available Tab
  Widget _buildAvailableTab(BuildContext context, List<EquipmentItem> allItems) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filterItems(allItems);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: l10n.borrowSearchHint,
              hintStyle: AppTextStyles.caption,
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final active = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(
                      _localizeCategory(context, cat),
                      style: AppTextStyles.caption.copyWith(
                        color: active ? AppColors.textWhite : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.border),
                      const SizedBox(height: 10),
                      Text(l10n.borrowNoEquipmentFound,
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildEquipmentCard(context, filtered[index]),
                ),
        ),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildEquipmentCard(BuildContext context, EquipmentItem item) {
    final l10n = AppLocalizations.of(context)!;
    final inCart = _cart.containsKey(item.id);
    final cartQty = inCart ? _cart[item.id]!.quantity : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.shadowDark, blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _categoryColor(item.category).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_categoryIcon(item.category), size: 18, color: _categoryColor(item.category)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.body),
                const SizedBox(height: 2),
                Text(item.description, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                if (item.storageLocation.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                          child: Text(item.storageLocation,
                              style: AppTextStyles.caption, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(
                  l10n.borrowAvailableCount(item.availableQuantity),
                  style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (inCart)
            Row(
              children: [
                GestureDetector(
                  onTap: () => _decrementCart(item),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), shape: BoxShape.circle),
                    child: const Icon(Icons.remove, size: 14, color: AppColors.textPrimary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('$cartQty', style: AppTextStyles.body),
                ),
                GestureDetector(
                  onTap: () => _addToCart(item),
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.add, size: 14, color: AppColors.textWhite),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
                  child: Text(l10n.borrowAdded(cartQty),
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () => _addToCart(item),
              child: Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.add, size: 18, color: AppColors.textWhite),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadowDark, blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_cartCount > 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : () => _showConfirmDialog(context),
                icon: const Icon(Icons.shopping_basket_outlined, size: 18, color: AppColors.textWhite),
                label: Text(l10n.borrowItemsButton(_cartCount),
                    style: const TextStyle(color: AppColors.textWhite)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showSpecialRequestSheet(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border, width: 1.5),
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(l10n.borrowRequestSpecial,
                  style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  String _localizeCategory(BuildContext context, String cat) {
    final l10n = AppLocalizations.of(context)!;
    switch (cat) {
      case 'All': return l10n.borrowCategoryAll;
      case 'Audio': return l10n.borrowCategoryAudio;
      case 'Presentation': return l10n.borrowCategoryPresentation;
      case 'Furniture': return l10n.borrowCategoryFurniture;
      case 'Decoration': return l10n.borrowCategoryDecoration;
      case 'Sports': return l10n.borrowCategorySports;
      case 'Electrical': return l10n.borrowCategoryElectrical;
      case 'Others': return l10n.borrowCategoryOthers;
      default: return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.borrowEquipTitle,
                                  style: AppTextStyles.h2.copyWith(color: AppColors.textWhite)),
                              Text(widget.event.name,
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.textWhite.withValues(alpha: 0.7))),
                            ],
                          ),
                        ),
                        LanguageToggle(
                          selectedLocale: localeController.value,
                          onLocaleChanged: (locale) => localeController.value = locale,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    indicator: BoxDecoration(
                        color: AppColors.textWhite, borderRadius: BorderRadius.circular(30)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textWhite,
                    labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    tabs: [
                      Tab(text: l10n.borrowTabAvailable),
                      Tab(text: l10n.borrowTabBorrowed),
                      Tab(text: l10n.borrowTabSpecialRequests),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                widget.isCompleted
                    ? _buildLockedAvailableTab(context)
                    : FutureBuilder<List<EquipmentItem>>(
                        future: _equipmentFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text(l10n.borrowLoadError, style: AppTextStyles.body));
                          }
                          return _buildAvailableTab(context, snapshot.data ?? []);
                        },
                      ),
                BorrowedEquipmentTab(
                  event: widget.event,
                  repository: _repo,
                  onInventoryChanged: _refreshAvailableEquipment,
                  isCompleted: widget.isCompleted,
                ),
                SpecialRequestsTab(event: widget.event, repository: _repo, isCompleted: widget.isCompleted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Special Equipment Request bottom sheet
class _SpecialRequestSheet extends StatefulWidget {
  final EligibleEvent event;
  final EquipmentBorrowRepository repo;

  const _SpecialRequestSheet({required this.event, required this.repo});

  @override
  State<_SpecialRequestSheet> createState() => _SpecialRequestSheetState();
}

class _SpecialRequestSheetState extends State<_SpecialRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final request = SpecialEquipmentRequest(
        eventId: widget.event.id,
        eventName: widget.event.name,
        organizerHeadId: FirebaseAuth.instance.currentUser?.uid ?? '',
        itemName: _itemNameController.text.trim(),
        quantityRequired: int.parse(_quantityController.text.trim()),
        reason: _reasonController.text.trim(),
        createdAt: DateTime.now(),
      );
      await widget.repo.submitSpecialEquipmentRequest(request);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 10),
          Text(l10n.specialRequestSubmitSuccess),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.specialRequestSubmitError),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.specialRequestTitle, style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text(l10n.specialRequestSubtitle,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Text(l10n.specialRequestEventLabel,
                  style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(widget.event.name, style: AppTextStyles.body),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l10n.specialRequestPendingNote,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.warning, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.specialRequestItemNameLabel, style: AppTextStyles.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _itemNameController,
                style: AppTextStyles.body,
                decoration: _inputDecoration(l10n.specialRequestItemNameHint),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.specialRequestItemNameRequired : null,
              ),
              const SizedBox(height: 12),
              Text(l10n.specialRequestQuantityLabel, style: AppTextStyles.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _quantityController,
                style: AppTextStyles.body,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('1'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.specialRequestQuantityRequired;
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1) return l10n.specialRequestQuantityInvalid;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Text(l10n.specialRequestReasonLabel, style: AppTextStyles.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _reasonController,
                style: AppTextStyles.body,
                maxLines: 4,
                decoration: _inputDecoration(l10n.specialRequestReasonHint),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.specialRequestReasonRequired;
                  if (v.trim().length < 10) return l10n.specialRequestReasonTooShort;
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.specialRequestCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(l10n.specialRequestSubmit,
                              style: const TextStyle(color: AppColors.textWhite)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.error)),
  );
}

