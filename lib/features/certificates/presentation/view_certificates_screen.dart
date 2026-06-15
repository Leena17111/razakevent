import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/certificate_model.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/certificate_controller.dart';
import '../logic/certificate_pdf_service.dart';
import 'certificate_preview_screen.dart';

class ViewCertificatesScreen extends StatefulWidget {
  const ViewCertificatesScreen({super.key});

  @override
  State<ViewCertificatesScreen> createState() => _ViewCertificatesScreenState();
}

class _ViewCertificatesScreenState extends State<ViewCertificatesScreen> {
  final _controller = CertificateController();

  // null = show all, false = participation only, true = volunteer only
  bool? _filterVolunteer;

  List<CertificateModel> get _filtered {
    if (_filterVolunteer == null) return _controller.certificates;
    return _controller.certificates.where((c) =>
      (c.certType == CertificateType.volunteer) == _filterVolunteer
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _controller.fetchCertificates();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _controller.error != null
              ? _ErrorState(
                  message: l.somethingWentWrong,
                  onRetry: _controller.fetchCertificates,
                )
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(l),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 16),
                          _StatsRow(
                            controller: _controller,
                            l: l,
                            filterVolunteer: _filterVolunteer,
                            onFilterChanged: (val) =>
                                setState(() => _filterVolunteer = val),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.certificatesNote,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_filtered.isEmpty)
                            _EmptyState(l: l)
                          else
                            ..._filtered.map(
                              (cert) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _CertCard(
                                  cert: cert,
                                  l: l,
                                  studentName: _controller.studentName,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              l.appFooter,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
    );
  }

  SliverAppBar _buildAppBar(AppLocalizations l) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 90, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l.certificatesTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.certificatesSubtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.controller,
    required this.l,
    required this.filterVolunteer,
    required this.onFilterChanged,
  });

  final CertificateController controller;
  final AppLocalizations l;
  final bool? filterVolunteer;
  final void Function(bool?) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(
          icon: Icons.workspace_premium_rounded,
          count: controller.participationCount,
          label: l.certificatesParticipation,
          iconBg: AppColors.primarySoft,
          iconColor: AppColors.primary,
          countColor: AppColors.primary,
          isActive: filterVolunteer == false,
          // tap participation: if already filtering participation, clear; else filter
          onTap: () => onFilterChanged(
            filterVolunteer == false ? null : false,
          ),
        ),
        const SizedBox(width: 12),
        _StatBox(
          icon: Icons.star_rounded,
          count: controller.volunteerCount,
          label: l.certificatesVolunteer,
          iconBg: AppColors.secretaryBadgeBg,
          iconColor: AppColors.secretaryBadgeText,
          countColor: AppColors.secretaryBadgeText,
          isActive: filterVolunteer == true,
          // tap volunteer: if already filtering volunteer, clear; else filter
          onTap: () => onFilterChanged(
            filterVolunteer == true ? null : true,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.count,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.countColor,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final Color countColor;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(color: iconColor, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowNavy,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive ? iconColor : iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: countColor,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isActive ? 1.0 : 0.0,
                child: Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Certificate Card ──────────────────────────────────────────────────────────

class _CertCard extends StatefulWidget {
  const _CertCard({
    required this.cert,
    required this.l,
    required this.studentName,
  });
  final CertificateModel cert;
  final AppLocalizations l;
  final String studentName;

  @override
  State<_CertCard> createState() => _CertCardState();
}

class _CertCardState extends State<_CertCard> {
  bool _isGenerating = false;

  Future<void> _viewCertificate() async {
    final locale = Localizations.localeOf(context).languageCode;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CertificatePreviewScreen(
          cert: widget.cert,
          studentName: widget.studentName,
          locale: locale,
        ),
      ),
    );
  }

  Future<void> _downloadCertificate() async {
    final locale = Localizations.localeOf(context).languageCode;
    setState(() => _isGenerating = true);
    try {
      final bytes = await CertificatePdfService().generate(
        cert: widget.cert,
        studentName: widget.studentName,
        locale: locale,
      );
      final safeName =
          widget.cert.eventName.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Certificate_$safeName.pdf',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l.somethingWentWrong),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cert = widget.cert;
    final l = widget.l;
    final isVolunteer = cert.certType == CertificateType.volunteer;
    final pillColor =
        isVolunteer ? AppColors.secretaryBadgeText : AppColors.primary;
    final iconBg =
        isVolunteer ? AppColors.secretaryBadgeBg : AppColors.primarySoft;
    final typeLabel =
        isVolunteer ? l.certificatesVolunteer : l.certificatesParticipation;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowNavy,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.eventName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: pillColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: pillColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isVolunteer
                      ? Icons.star_rounded
                      : Icons.workspace_premium_rounded,
                  color: pillColor,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l.certificatesIssued}: ${cert.formattedDate}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isGenerating ? null : _viewCertificate,
                  icon: const Icon(Icons.visibility_outlined, size: 14),
                  label: Text(l.certificatesView),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isGenerating ? null : _downloadCertificate,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded, size: 14),
                  label: Text(l.certificatesDownload),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowNavy,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              size: 30,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.certificatesEmpty,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.certificatesEmptyDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l.tryAgain,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}