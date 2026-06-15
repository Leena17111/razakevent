import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/repository/equipment_borrow_repository.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/localization/locale_controller.dart';
import 'borrow_equipment_screen.dart';

class BorrowEventSelectScreen extends StatefulWidget {
  const BorrowEventSelectScreen({super.key});

  @override
  State<BorrowEventSelectScreen> createState() =>
      _BorrowEventSelectScreenState();
}

class _BorrowEventSelectScreenState extends State<BorrowEventSelectScreen>
    with SingleTickerProviderStateMixin {
  final EquipmentBorrowRepository _repo = EquipmentBorrowRepository();

  late TabController _tabController;
  late Future<List<EligibleEvent>> _upcomingFuture;
  late Future<List<EligibleEvent>> _pastFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _upcomingFuture = _repo.fetchEligibleEvents();
    _pastFuture = _repo.fetchCompletedEventsWithBorrowedItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _upcomingFuture = _repo.fetchEligibleEvents();
      _pastFuture = _repo.fetchCompletedEventsWithBorrowedItems();
    });
  }

  int _daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    return eventDay.difference(today).inDays;
  }

  Widget _buildDayBadge(BuildContext context, int days) {
    final l10n = AppLocalizations.of(context)!;
    String label;
    Color bg;
    Color fg;
    if (days == 0) {
      label = l10n.borrowEventBadgeToday;
      bg = AppColors.error.withOpacity(0.15);
      fg = AppColors.error;
    } else if (days == 1) {
      label = l10n.borrowEventBadgeTomorrow;
      bg = AppColors.warning.withOpacity(0.15);
      fg = AppColors.warning;
    } else {
      label = l10n.borrowEventBadgeInDays(days);
      bg = AppColors.primarySoft;
      fg = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: fg, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildPastBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.borrowEventPastBadge,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EligibleEvent event, {required bool isCompleted}) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat('d MMM yyyy').format(event.eventDate);
    final days = _daysUntil(event.eventDate);

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BorrowEquipmentScreen(event: event, isCompleted: isCompleted),
          ),
        );
        _reload();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: AppColors.shadowDark, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(event.name, style: AppTextStyles.h3.copyWith(fontSize: 15))),
                  const SizedBox(width: 8),
                  isCompleted ? _buildPastBadge(context) : _buildDayBadge(context, days),
                ],
              ),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Text(dateStr, style: AppTextStyles.caption),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Expanded(child: Text(event.venue, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis)),
              ]),
              if (event.borrowedItemsCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.borrowEventItemsBorrowed(event.borrowedItemsCount),
                  style: AppTextStyles.caption.copyWith(
                    color: isCompleted ? AppColors.textSecondary : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventList(
    BuildContext context,
    Future<List<EligibleEvent>> future, {
    required bool isCompleted,
    required String emptyMessage,
  }) {
    return FutureBuilder<List<EligibleEvent>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(AppLocalizations.of(context)!.borrowEventLoadError, style: AppTextStyles.body));
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(emptyMessage, style: AppTextStyles.body, textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: events.length,
          itemBuilder: (context, index) => _buildEventCard(context, events[index], isCompleted: isCompleted),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                        ),
                        const Spacer(),
                        LanguageToggle(
                          selectedLocale: localeController.value,
                          onLocaleChanged: (locale) => localeController.value = locale,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.borrowEventTitle, style: AppTextStyles.heading.copyWith(color: AppColors.textWhite)),
                    const SizedBox(height: 4),
                    Text(l10n.borrowEventSubtitle, style: AppTextStyles.subtitle.copyWith(color: AppColors.textWhite.withValues(alpha: 0.7))),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: AppColors.textWhite),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.borrowEventEligibilityNote,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(color: AppColors.textWhite, borderRadius: BorderRadius.circular(30)),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textWhite,
                      labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: l10n.borrowTabUpcoming),
                        Tab(text: l10n.borrowTabPastEvents),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventList(context, _upcomingFuture, isCompleted: false, emptyMessage: l10n.borrowEventNoEvents),
                _buildEventList(context, _pastFuture, isCompleted: true, emptyMessage: l10n.borrowEventNoPastEvents),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(l10n.appFooter, style: AppTextStyles.caption, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
