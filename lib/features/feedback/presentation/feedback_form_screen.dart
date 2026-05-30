import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razakevent/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
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

  // Ratings: question text -> star rating (1-5)
  final Map<String, int> _builtInRatings = {};
  final Map<String, int> _additionalRatings = {};

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  @override
  void dispose() {
    _commentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadForm() async {
    final form = await _repo.getFeedbackForm(widget.eventId);
    if (mounted) {
      setState(() {
        _form = form;
        _isLoading = false;
      });
    }
  }

  List<String> get _builtInQuestions {
    if (_form == null) return [];
    return List<String>.from(_form!['builtInQuestions'] ?? []);
  }

  List<String> get _customQuestions {
    if (_form == null) return [];
    return List<String>.from(_form!['customQuestions'] ?? []);
  }

  bool _allRated() {
    for (final q in _builtInQuestions) {
      if (!_builtInRatings.containsKey(q) || _builtInRatings[q] == 0) {
        return false;
      }
    }
    for (final q in _customQuestions) {
      if (!_additionalRatings.containsKey(q) || _additionalRatings[q] == 0) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final feedback = FeedbackModel(
        eventId: widget.eventId,
        eventTitle: widget.eventTitle,
        studentId: user.uid,
        studentName: user.displayName ?? 'Student',
        builtInRatings: _builtInRatings,
        additionalRatings: _additionalRatings,
        comments: _commentsCtrl.text.trim(),
        submittedAt: DateTime.now(),
      );
      await _repo.submitFeedback(feedback);

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          // Header
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

          // Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Built-in questions
                        if (_builtInQuestions.isNotEmpty) ...[
                          _buildSectionCard(
                            label: l10n.builtInQuestionsSection,
                            questions: _builtInQuestions,
                            ratings: _builtInRatings,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Additional questions
                        if (_customQuestions.isNotEmpty) ...[
                          _buildSectionCard(
                            label: l10n.additionalQuestionsSection,
                            questions: _customQuestions,
                            ratings: _additionalRatings,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Comments
                        _buildCommentsCard(l10n),
                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitFeedback,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
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

  Widget _buildSectionCard({
    required String label,
    required List<String> questions,
    required Map<String, int> ratings,
  }) {
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
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...questions.map((q) => _buildStarQuestion(q, ratings)),
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
                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: i < rating ? const Color(0xFFFBBF24) : AppColors.border,
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

  Widget _buildCommentsCard(AppLocalizations l10n) {
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
            l10n.commentsAndSuggestions,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentsCtrl,
            maxLines: 4,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: l10n.commentsHint,
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
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}