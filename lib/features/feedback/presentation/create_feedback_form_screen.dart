// lib/features/feedback/presentation/create_feedback_form_screen.dart
// AD-63: Build feedback form setup UI
// AD-64: Built-in questions + UTM merit QR upload
// AD-65: Test feedback form setup flow

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/event_model.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/feedback_controller.dart';

class CreateFeedbackFormScreen extends StatefulWidget {
  const CreateFeedbackFormScreen({super.key});

  @override
  State<CreateFeedbackFormScreen> createState() =>
      _CreateFeedbackFormScreenState();
}

class _CreateFeedbackFormScreenState
    extends State<CreateFeedbackFormScreen> {
  // Brand colors
  static const Color _navy = Color(0xFF1A237E);
  static const Color _navyMid = Color(0xFF283593);
  static const Color _navyLight = Color(0xFF3949AB);
  static const Color _red = Color(0xFFC8102E);
  static const Color _redDark = Color(0xFFA00D25);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF5F6FA);

  static const String _placeholderId = '__placeholder__';

  final FeedbackController _controller = FeedbackController();
  final TextEditingController _customQuestionCtrl =
      TextEditingController();
  final TextEditingController _meritLinkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _controller.loadEvents();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _customQuestionCtrl.dispose();
    _meritLinkCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 520 ? 460.0 : screenWidth;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: _controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _navy))
                : Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: contentWidth,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(16, 20, 16, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Banners
                            if (_controller.errorMessage != null)
                              _buildBanner(_controller.errorMessage!,
                                  isError: true),
                            if (_controller.successMessage != null)
                              _buildBanner(
                                  _controller.successMessage!,
                                  isError: false),

                            // 1. Select Event
                            _buildCard(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildCardLabel(l10n.selectEvent),
                                  const SizedBox(height: 10),
                                  _buildEventDropdown(l10n),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 2. Built-in Questions
                            _buildCard(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildCardLabel(
                                      l10n.builtInQuestions),
                                  const SizedBox(height: 14),
                                  _buildBuiltInQuestions(l10n),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 3. Custom Questions
                            _buildCard(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildCardLabel(
                                      l10n.customQuestionsOptional),
                                  const SizedBox(height: 14),
                                  _buildCustomQuestions(l10n),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 4. UTM Smart Merit
                            _buildMeritCard(l10n),
                            const SizedBox(height: 24),

                            // Preview + Save buttons
                            _buildActionButtons(l10n),
                            const SizedBox(height: 16),

                            // Footer
                            Center(
                              child: Text(
                                'Kolej Tun Razak · UTM',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _navyMid, _navyLight],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8,
        right: 16,
        bottom: 20,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.addFeedbackForm,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  LanguageToggle(
                    selectedLocale: Localizations.localeOf(context),
                    onLocaleChanged: (locale) =>
                        localeController.value = locale,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  l10n.setUpEventFeedbackCollection,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card Label ────────────────────────────────────────────────────
  Widget _buildCardLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: _navy,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
      ),
    );
  }

  // ── Event Dropdown ────────────────────────────────────────────────
  Widget _buildEventDropdown(AppLocalizations l10n) {
    if (_controller.events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.event_busy_rounded,
                color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.noEventsFound ?? '',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _controller.selectedEvent != null
              ? _navy
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded,
              color: _navy, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _controller.selectedEvent?.eventId ??
                    _placeholderId,
                isExpanded: true,
                icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _navy),
                items: [
                  // Placeholder (disabled)
                  DropdownMenuItem<String>(
                    value: _placeholderId,
                    enabled: false,
                    child: Text(
                      l10n.chooseEvent,
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 14),
                    ),
                  ),
                  // Real events
                  ..._controller.events.map((event) {
                    return DropdownMenuItem<String>(
                      value: event.eventId,
                      child: Text(
                        event.title,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (id) {
                  if (id == null || id == _placeholderId) return;
                  final event = _controller.events
                      .firstWhere((e) => e.eventId == id);
                  _controller.selectEvent(event);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Built-in Questions ────────────────────────────────────────────
  Widget _buildBuiltInQuestions(AppLocalizations l10n) {
    final questions = [
      l10n.satisfactionQuestion,
      l10n.organizedQuestion,
      l10n.recommendQuestion,
      l10n.additionalFeedbackQuestion,
    ];

    return Column(
      children: questions.asMap().entries.map((entry) {
        final i = entry.key;
        final q = entry.value;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF10B981),
                          Color(0xFF059669)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      q,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Icon(Icons.lock_outline_rounded,
                      size: 14, color: Colors.grey),
                ],
              ),
            ),
            if (i < questions.length - 1)
              const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  // ── Custom Questions ──────────────────────────────────────────────
  Widget _buildCustomQuestions(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_controller.customQuestions.isNotEmpty) ...[
          ..._controller.customQuestions.asMap().entries.map(
            (entry) {
              final i = entry.key;
              final q = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFDDD6FE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(q,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1C1C1E))),
                    ),
                    GestureDetector(
                      onTap: () =>
                          _controller.removeCustomQuestion(i),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 13,
                            color: Color(0xFFDC2626)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customQuestionCtrl,
                style: const TextStyle(fontSize: 13),
                onSubmitted: (_) => _addCustomQuestion(),
                decoration: InputDecoration(
                  hintText: l10n.enterCustomQuestion,
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: _navy, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _addCustomQuestion,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF7C3AED)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addCustomQuestion() {
    _controller.addCustomQuestion(_customQuestionCtrl.text);
    _customQuestionCtrl.clear();
  }

  // ── Merit Card ────────────────────────────────────────────────────
  Widget _buildMeritCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                l10n.utmSmartMerit.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.utmSmartMeritNote,
            style: const TextStyle(
                color: Color(0xFF1D4ED8), fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),

          // Toggle QR / Link
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                _buildMeritToggleBtn(
                  label: l10n.uploadQrCode,
                  icon: Icons.qr_code_2_rounded,
                  selected: _controller.useQrCode,
                  onTap: () => _controller.setUseQrCode(true),
                ),
                const SizedBox(width: 4),
                _buildMeritToggleBtn(
                  label: l10n.pasteMeritLink,
                  icon: Icons.link_rounded,
                  selected: !_controller.useQrCode,
                  onTap: () => _controller.setUseQrCode(false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_controller.useQrCode) ...[
            if (_controller.qrCodeFile != null)
              _buildQrPreview()
            else
              _buildQrUploadArea(l10n),
          ],

          if (!_controller.useQrCode)
            TextField(
              controller: _meritLinkCtrl,
              onChanged: _controller.setMeritLink,
              keyboardType: TextInputType.url,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'https://utmsmart.utm.my/merit/...',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.link_rounded,
                    color: _blue, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFFBFDBFE), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFFBFDBFE), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeritToggleBtn({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _blue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF1E40AF),
                  size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xFF1E40AF),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrUploadArea(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _controller.pickQrCode,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF93C5FD),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.qr_code_scanner_rounded,
                size: 40, color: Color(0xFF3B82F6)),
            const SizedBox(height: 10),
            Text(
              l10n.uploadUtmSmartQrCode,
              style: const TextStyle(
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.pngJpgUpTo2mb,
              style: const TextStyle(
                  color: Color(0xFF93C5FD), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrPreview() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF93C5FD)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_2_rounded, color: _blue, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _controller.qrCodeFileName ?? 'QR Code',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text('Tap × to remove',
                    style:
                        TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _controller.removeQrCode,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 15, color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────
  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        // Preview button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showPreviewDialog,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: const BorderSide(color: _navy, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.visibility_outlined,
                color: _navy, size: 18),
            label: Text(
              l10n.previewForm,
              style: const TextStyle(
                color: _navy,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Save button
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_red, _redDark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _red.withOpacity(0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed:
                  _controller.isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              icon: _controller.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(
                _controller.isSaving ? '' : l10n.saveFeedbackForm,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Preview Dialog ────────────────────────────────────────────────
  void _showPreviewDialog() {
    final l10n = AppLocalizations.of(context)!;
    final builtIn = [
      l10n.satisfactionQuestion,
      l10n.organizedQuestion,
      l10n.recommendQuestion,
      l10n.additionalFeedbackQuestion,
    ];
    final preview = _controller.buildPreviewData(builtIn);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.preview_rounded,
                      color: _navy, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.previewForm,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event
                    _previewRow(
                      label: l10n.selectEvent,
                      value: preview['eventTitle'] as String,
                      icon: Icons.event_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Built-in questions
                    Text(
                      l10n.builtInQuestions.toUpperCase(),
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(preview['builtInQuestions'] as List<String>)
                        .asMap()
                        .entries
                        .map(
                          (e) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${e.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(e.value,
                                      style: const TextStyle(
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ),

                    // Custom questions
                    if ((preview['customQuestions'] as List)
                        .isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.customQuestionsOptional.toUpperCase(),
                        style: const TextStyle(
                          color: _purple,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(preview['customQuestions'] as List<String>)
                          .asMap()
                          .entries
                          .map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: _purple,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${e.key + 5}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(e.value,
                                        style: const TextStyle(
                                            fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],

                    // Merit
                    const SizedBox(height: 16),
                    Text(
                      l10n.utmSmartMerit.toUpperCase(),
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _previewRow(
                      label: 'Type',
                      value: preview['meritType'] as String,
                      icon: Icons.qr_code_2_rounded,
                    ),
                    if (preview['meritLink'] != null) ...[
                      const SizedBox(height: 6),
                      _previewRow(
                        label: 'Link',
                        value: preview['meritLink'] as String,
                        icon: Icons.link_rounded,
                      ),
                    ],
                    if (preview['hasQr'] == true) ...[
                      const SizedBox(height: 6),
                      _previewRow(
                        label: 'QR Code',
                        value: 'Uploaded ✓',
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: _navy, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 11)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Handle Save ───────────────────────────────────────────────────
  Future<void> _handleSave() async {
    final success = await _controller.saveFeedbackForm();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Feedback form saved!',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ── Banner ────────────────────────────────────────────────────────
  Widget _buildBanner(String message, {required bool isError}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? const Color(0xFFFECACA)
              : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: isError
                ? const Color(0xFFDC2626)
                : const Color(0xFF16A34A),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError
                    ? const Color(0xFF991B1B)
                    : const Color(0xFF166534),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────────────
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}