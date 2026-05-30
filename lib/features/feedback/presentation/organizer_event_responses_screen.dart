import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razakevent/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_controller.dart';
import '../data/feedback_model.dart';
import '../data/feedback_repository.dart';
import '../logic/groq_feedback_service.dart';

class OrganizerEventResponsesScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const OrganizerEventResponsesScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<OrganizerEventResponsesScreen> createState() =>
      _OrganizerEventResponsesScreenState();
}

class _OrganizerEventResponsesScreenState
    extends State<OrganizerEventResponsesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FeedbackRepository _repo = FeedbackRepository();
  final GroqFeedbackService _groq = GroqFeedbackService();

  List<FeedbackModel> _feedbackList = [];
  List<Map<String, dynamic>> _registrants = [];
  bool _isLoadingFeedback = true;
  bool _isLoadingRegistrants = true;
  bool _isLoadingGroq = false;
  String? _groqSummary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFeedback();
    _loadRegistrants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedback() async {
    final feedback = await _repo.getEventFeedback(widget.eventId);
    if (mounted) {
      setState(() {
        _feedbackList = feedback;
        _isLoadingFeedback = false;
      });
    }
  }

  Future<void> _loadRegistrants() async {
    final registrants = await _repo.getEventRegistrants(widget.eventId);
    if (mounted) {
      setState(() {
        _registrants = registrants;
        _isLoadingRegistrants = false;
      });
    }
  }

  Future<void> _loadGroqSummary() async {
    if (_feedbackList.isEmpty) return;
    setState(() => _isLoadingGroq = true);

    try {
      final feedbackMaps = _feedbackList
          .map((f) => {
                'builtInRatings': f.builtInRatings,
                'additionalRatings': f.additionalRatings,
                'comments': f.comments,
                'studentName': f.studentName,
              })
          .toList();

      final summary = await _groq.summarizeFeedback(feedbackMaps);
      if (mounted) {
        setState(() {
          _groqSummary = summary;
          _isLoadingGroq = false;
        });
      }
    } catch (e) {
      print('GROQ ERROR: $e');
      if (mounted) {
        setState(() {
          _groqSummary = 'AI summary unavailable. Please try again later.';
          _isLoadingGroq = false;
        });
      }
    }
  }

  double get _avgRating {
    if (_feedbackList.isEmpty) return 0;
    double total = 0;
    for (final f in _feedbackList) {
      final ratings = f.builtInRatings.values;
      if (ratings.isNotEmpty) {
        total += ratings.reduce((a, b) => a + b) / ratings.length;
      }
    }
    return total / _feedbackList.length;
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 520 ? 460.0 : screenWidth;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Column(
            children: [
              Container(
                color: AppColors.primary,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      l10n.organizerHead,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.registrationsAndFeedback,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    widget.eventTitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildLanguageToggle(context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor:
                            Colors.white.withValues(alpha: 0.5),
                        labelStyle: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w600),
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.people_outline, size: 18),
                            text: 'Registrants',
                          ),
                          Tab(
                            icon: Icon(Icons.chat_bubble_outline, size: 18),
                            text: 'Feedback',
                          ),
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
                    _buildRegistrantsTab(l10n),
                    _buildFeedbackTab(l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrantsTab(AppLocalizations l10n) {
    if (_isLoadingRegistrants) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_registrants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              l10n.noRegistrantsYet,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _registrants.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '${_registrants.length} ${l10n.totalRegistrants}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final reg = _registrants[index - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  _initial(reg['fullName'] ?? ''),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reg['fullName'] ?? '',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      reg['matricNumber'] ?? reg['faculty'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.studentBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reg['paymentStatus'] ?? 'free',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.studentBadgeText,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackTab(AppLocalizations l10n) {
    if (_isLoadingFeedback) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_feedbackList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              l10n.noFeedbackYet,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    final responseRate = _registrants.isEmpty
        ? 0
        : (_feedbackList.length / _registrants.length * 100).round();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _buildStatCard(
              label: l10n.totalResponses,
              value: '${_feedbackList.length}',
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              label: l10n.avgRating,
              value: _avgRating.toStringAsFixed(1),
              icon: Icons.star_rounded,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              label: l10n.responseRate,
              value: '$responseRate%',
              color: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildGroqCard(l10n),
        const SizedBox(height: 16),
        ..._feedbackList.map((f) => _buildFeedbackCard(f, l10n)),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    IconData? icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 2),
                  Icon(icon, color: color, size: 16),
                ],
              ],
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroqCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.groqAiSummary,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isLoadingGroq ? null : _loadGroqSummary,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        l10n.groqRefresh,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingGroq)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else if (_groqSummary == null)
            GestureDetector(
              onTap: _loadGroqSummary,
              child: Text(
                l10n.groqTapToGenerate,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            )
          else
            Text(
              _groqSummary!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel feedback, AppLocalizations l10n) {
    final allRatings = {
      ...feedback.builtInRatings,
      ...feedback.additionalRatings,
    };

    final avgRating = allRatings.isEmpty
        ? 0.0
        : allRatings.values.reduce((a, b) => a + b) / allRatings.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  _initial(feedback.studentName),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.studentName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatDate(feedback.submittedAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFBBF24), size: 16),
                  const SizedBox(width: 2),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (allRatings.isNotEmpty) ...[
            _buildRatingsGrid(allRatings),
            const SizedBox(height: 12),
          ],
          if (feedback.comments.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.comment,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feedback.comments,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingsGrid(Map<String, int> ratings) {
    final entries = ratings.entries.toList();
    final rows = <Widget>[];

    for (int i = 0; i < entries.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: _buildRatingItem(entries[i])),
            if (i + 1 < entries.length) ...[
              const SizedBox(width: 12),
              Expanded(child: _buildRatingItem(entries[i + 1])),
            ] else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < entries.length) rows.add(const SizedBox(height: 8));
    }

    return Column(children: rows);
  }

  Widget _buildRatingItem(MapEntry<String, int> entry) {
    String label = entry.key;
    if (label.length > 25) {
      if (label.toLowerCase().contains('satisf')) {
        label = 'Satisfaction';
      } else if (label.toLowerCase().contains('organ')) {
        label = 'Organization';
      } else if (label.toLowerCase().contains('recomm')) {
        label = 'Recommendation';
      } else if (label.toLowerCase().contains('overall') ||
          label.toLowerCase().contains('experience')) {
        label = 'Overall';
      } else {
        label = '${label.substring(0, 22)}...';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 11, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // FIXED: Changed from Row to Wrap to prevent overflow
        Wrap(
          children: List.generate(5, (i) {
            return Icon(
              i < entry.value
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: i < entry.value
                  ? const Color(0xFFFBBF24)
                  : AppColors.border,
              size: 16,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
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
        localeController.value =
            label == 'EN' ? const Locale('en') : const Locale('ms');
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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