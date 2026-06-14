import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:razakevent/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../certificates/logic/certificate_trigger_service.dart';
import '../data/feedback_model.dart';
import '../data/feedback_repository.dart';
import 'feedback_success_screen.dart';

class FeedbackFormScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String formId;

  const FeedbackFormScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.formId,
  });

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final FeedbackRepository _repo = FeedbackRepository();
  final TextEditingController _commentsCtrl = TextEditingController();

  Map<String, dynamic>? _form;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final Map<String, int> _builtInRatings = {};
  // Custom questions use text responses not ratings
  final Map<String, TextEditingController> _customControllers = {};
  final TextEditingController _builtInTextCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  @override
  void dispose() {
    _commentsCtrl.dispose();
    _builtInTextCtrl.dispose();
    for (final c in _customControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadForm() async {
    final form = await _repo.getFeedbackForm(widget.eventId);
    if (mounted) {
      setState(() {
        _form = form;
        // Initialize controllers for custom questions
        for (final q in _customQuestions) {
          _customControllers[q] = TextEditingController();
        }
        _isLoading = false;
      });
    }
  }

  List<String> get _builtInQuestions {
    if (_form == null) return [];
    final all = List<String>.from(_form!['builtInQuestions'] ?? []);
    // Last built-in question is text-based, not a rating
    return all.length > 1 ? all.sublist(0, all.length - 1) : all;
  }

  String? get _builtInTextQuestion {
    if (_form == null) return null;
    final all = List<String>.from(_form!['builtInQuestions'] ?? []);
    return all.isNotEmpty ? all.last : null;
  }

  List<String> get _customQuestions {
    if (_form == null) return [];
    return List<String>.from(_form!['customQuestions'] ?? []);
  }

  String? get _meritQrUrl => _form?['qrCodeUrl'] as String?;
  String? get _meritLink => _form?['meritLink'] as String?;
  String? get _meritType => _form?['meritType'] as String?;

  bool _allRated() {
    for (final q in _builtInQuestions) {
      if (!_builtInRatings.containsKey(q) || _builtInRatings[q] == 0) {
        return false;
      }
    }
    return true;
  }

  Future<void> _submitFeedback() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_allRated()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ratingRequired),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Collect custom question responses as text
      final Map<String, String> customResponses = {};
      if (_builtInTextQuestion != null) {
        customResponses[_builtInTextQuestion!] = _builtInTextCtrl.text.trim();
      }
      for (final q in _customQuestions) {
        customResponses[q] = _customControllers[q]?.text.trim() ?? '';
      }

      final feedback = FeedbackModel(
        eventId: widget.eventId,
        eventTitle: widget.eventTitle,
        studentId: user.uid,
        studentName: user.displayName ?? 'Student',
        builtInRatings: _builtInRatings,
        additionalRatings: const {},
        customResponses: customResponses,
        comments: '',
        submittedAt: DateTime.now(),
      );
      await _repo.submitFeedback(feedback);

      // AD-190 — auto-issue participation certificate if event has ended
      await CertificateTriggerService().onFeedbackSubmitted(
        userId: feedback.studentId,
        eventId: feedback.eventId,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => FeedbackSuccessScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.feedbackSubmitError),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 20),
                child: Row(
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
                            l10n.feedbackFormTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.eventTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Built-in questions (star ratings)
                        if (_builtInQuestions.isNotEmpty) ...[
                          _buildRatingsCard(l10n),
                          const SizedBox(height: 16),
                        ],

                        // Built-in text question
                        if (_builtInTextQuestion != null) ...[
                          _buildBuiltInTextCard(l10n),
                          const SizedBox(height: 16),
                        ],

                        // Custom questions (text fields)
                        if (_customQuestions.isNotEmpty) ...[
                          _buildCustomQuestionsCard(l10n),
                          const SizedBox(height: 16),
                        ],

                        // UTM Merit section
                        if (_meritType != null) ...[
                          _buildMeritCard(l10n),
                          const SizedBox(height: 16),
                        ],

                        // Comments
                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isSubmitting ? null : _submitFeedback,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    l10n.submitFeedback,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Text(
            l10n.builtInQuestionsSection,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ..._builtInQuestions
              .map((q) => _buildStarQuestion(q, _builtInRatings)),
        ],
      ),
    );
  }

  Widget _buildCustomQuestionsCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Text(
            l10n.additionalQuestionsSection,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ..._customQuestions.map((q) => _buildTextQuestion(q)),
        ],
      ),
    );
  }

  Widget _buildStarQuestion(String question, Map<String, int> ratings) {
    final rating = ratings[question] ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => ratings[question] = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    i < rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i < rating
                        ? const Color(0xFFFBBF24)
                        : AppColors.border,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextQuestion(String question) {
    _customControllers.putIfAbsent(
        question, () => TextEditingController());
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customControllers[question],
            maxLines: 2,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Your answer...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeritCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded,
                  color: Color(0xFF1E40AF), size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.utmSmartMerit,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.utmSmartMeritNote,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF1D4ED8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Show QR image if available
          if (_meritType == 'qr' && _meritQrUrl != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _meritQrUrl!,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(
                    width: 180,
                    height: 180,
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: AppColors.textMuted),
                ),
              ),
            ),
          // Show merit link if available
          if (_meritType == 'link' && _meritLink != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      color: Color(0xFF2563EB), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _meritLink!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF2563EB),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBuiltInTextCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Text(
            _builtInTextQuestion!,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _builtInTextCtrl,
            maxLines: 3,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Your answer...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}