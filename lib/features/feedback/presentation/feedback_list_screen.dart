import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razakevent/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_controller.dart';
import '../data/feedback_repository.dart';
import 'feedback_form_screen.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  final FeedbackRepository _repo = FeedbackRepository();
  List<Map<String, dynamic>> _allEvents = []; 
  bool _isLoading = true;
  String _selectedFilter = 'all';  // ADD THIS

  @override
  void initState() {
    super.initState();
    _loadPendingFeedback();
  }

  Future<void> _loadPendingFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final events = await _repo.getPendingFeedbackEvents(user.uid);
    if (mounted) {
      setState(() {
        _allEvents = events;
        _isLoading = false;
      });
    }
  }

  // ADD THIS METHOD
  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  // ADD THIS GETTER
  List<Map<String, dynamic>> get _filteredEvents {
    if (_selectedFilter == 'all') return _allEvents;
    
    final now = DateTime.now();
    return _allEvents.where((event) {
      final deadline = event['feedbackDeadline'] as DateTime;
      final remaining = deadline.difference(now);
      final days = remaining.inDays;
      
      switch (_selectedFilter) {
        case '3days':
          return days == 3;
        case '2days':
          return days == 2;
        case 'lessThanDay':
          return days == 0 || days == 1;
        default:
          return true;
      }
    }).toList();
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  String _getTimeRemainingText(DateTime deadline, AppLocalizations l10n) {
    final now = DateTime.now();
    final remaining = deadline.difference(now);
    
    if (remaining.inDays > 0) {
      final days = remaining.inDays;
      return '${l10n.openFor} $days ${days > 1 ? l10n.days : l10n.day}';
    } else if (remaining.inHours > 0) {
      final hours = remaining.inHours;
      return '${l10n.openFor} $hours ${hours > 1 ? l10n.hours : l10n.hour}';
    } else {
      return '${l10n.openFor} ${remaining.inMinutes} minutes';
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
            width: double.infinity,
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 16, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.eventFeedback,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            ),
                          ),
                          Text(
                            l10n.shareYourExperience,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textWhite.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _LanguageToggle(),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _loadPendingFeedback,
                    color: AppColors.primary,
                    child: _allEvents.isEmpty  
                        ? _buildEmpty(l10n)
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Text(
                                l10n.pendingFeedback,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              
                              // ADD FILTER CHIPS HERE - CENTERED
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Center(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FilterChip(
                                          label: Text(l10n.filterAll),
                                          selected: _selectedFilter == 'all',
                                          onSelected: (_) => _setFilter('all'),
                                          backgroundColor: AppColors.surfaceSoft,
                                          selectedColor: AppColors.primary,  // CHANGED: to match header
                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: _selectedFilter == 'all' ? Colors.white : AppColors.textPrimary,
                                          ),
                                          checkmarkColor: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        FilterChip(
                                          label: Text(l10n.filter3DaysLeft),
                                          selected: _selectedFilter == '3days',
                                          onSelected: (_) => _setFilter('3days'),
                                          backgroundColor: AppColors.surfaceSoft,
                                          selectedColor: AppColors.primary,  // CHANGED: to match header
                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: _selectedFilter == '3days' ? Colors.white : AppColors.textPrimary,
                                          ),
                                          checkmarkColor: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        FilterChip(
                                          label: Text(l10n.filter2DaysLeft),
                                          selected: _selectedFilter == '2days',
                                          onSelected: (_) => _setFilter('2days'),
                                          backgroundColor: AppColors.surfaceSoft,
                                          selectedColor: AppColors.primary,  // CHANGED: to match header
                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: _selectedFilter == '2days' ? Colors.white : AppColors.textPrimary,
                                          ),
                                          checkmarkColor: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        FilterChip(
                                          label: Text(l10n.filterLessThanDay),
                                          selected: _selectedFilter == 'lessThanDay',
                                          onSelected: (_) => _setFilter('lessThanDay'),
                                          backgroundColor: AppColors.surfaceSoft,
                                          selectedColor: AppColors.primary,  // CHANGED: to match header
                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: _selectedFilter == 'lessThanDay' ? Colors.white : AppColors.textPrimary,
                                          ),
                                          checkmarkColor: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              ..._filteredEvents.map((event) => _buildEventCard(event)),
                            ],
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          event['eventTitle'] ?? '',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              event['organizationName'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              _formatDate(event['eventDate']),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getTimeRemainingText(event['feedbackDeadline'], AppLocalizations.of(context)!),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FeedbackFormScreen(
                eventId: event['eventId'],
                eventTitle: event['eventTitle'],
                formId: event['formId'],
              ),
            ),
          ).then((_) => _loadPendingFeedback());
        },
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                l10n.noFeedbackPending,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.noFeedbackPendingDesc,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(context, 'EN', locale == 'en'),
          _toggleBtn(context, 'BM', locale == 'ms'),
        ],
      ),
    );
  }

  Widget _toggleBtn(BuildContext context, String label, bool active) {
    return GestureDetector(
      onTap: () {
        localeController.value = label == 'EN' ? const Locale('en') : const Locale('ms');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}