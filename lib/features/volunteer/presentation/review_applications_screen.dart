import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../data/models/volunteer_application_model.dart';
import '../../../data/models/volunteer_position_model.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/review_applications_controller.dart';

class ReviewApplicationsScreen extends StatefulWidget {
  final String eventTitle;
  final List<VolunteerPositionModel> positions;

  const ReviewApplicationsScreen({
    super.key,
    required this.eventTitle,
    required this.positions,
  });

  @override
  State<ReviewApplicationsScreen> createState() =>
      _ReviewApplicationsScreenState();
}

class _ReviewApplicationsScreenState extends State<ReviewApplicationsScreen> {
  final ReviewApplicationsController _controller =
      ReviewApplicationsController();

  String _selectedFilter = 'All';

  String get _reviewerUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<VolunteerApplicationModel> _filterApplications(
    List<VolunteerApplicationModel> applications,
  ) {
    if (_selectedFilter == 'All') return applications;

    return applications
        .where((application) => application.status == _selectedFilter)
        .toList();
  }

  String _errorMessage(AppLocalizations l10n, String? key, String fallback) {
    switch (key) {
      case 'rejectionReasonRequired':
        return l10n.rejectionReasonRequired;
      case 'volunteerSlotsFull':
        return l10n.volunteerSlotsFull;
      case 'applicationAlreadyReviewed':
        return l10n.applicationAlreadyReviewed;
      case 'applicationOrPositionNotFound':
        return l10n.applicationOrPositionNotFound;
      default:
        return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(currentLocale, l10n),
            Expanded(
              child: widget.positions.isEmpty
                  ? _buildEmptyState(l10n.noVolunteerPositionsForReview)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: widget.positions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final position = widget.positions[index];
                        return _buildPositionApplicationsSection(
                          position,
                          l10n,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Locale currentLocale, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textWhite,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              LanguageToggle(
                selectedLocale: currentLocale,
                onLocaleChanged: (locale) {
                  localeController.value = locale;
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE89A24).withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.organizerHead,
              style: AppTextStyles.label.copyWith(
                color: const Color(0xFFE89A24),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.reviewEventApplications,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textWhite,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.eventTitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textWhite.withOpacity(0.86),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildPositionApplicationsSection(
  VolunteerPositionModel position,
  AppLocalizations l10n,
) {
  return StreamBuilder<VolunteerPositionModel?>(
    stream: _controller.streamPositionById(position.positionId),
    builder: (context, positionSnapshot) {
      final latestPosition = positionSnapshot.data ?? position;

      return StreamBuilder<List<VolunteerApplicationModel>>(
        stream: _controller.streamApplicationsForPosition(
          latestPosition.positionId,
        ),
        builder: (context, snapshot) {
          final applications = snapshot.data ?? [];
          final filteredApplications = _filterApplications(applications);

          final pendingCount = applications
              .where((app) => app.status == VolunteerApplicationStatus.pending)
              .length;

          return Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPositionHeader(
                  position: latestPosition,
                  applicationCount: applications.length,
                  pendingCount: pendingCount,
                  l10n: l10n,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: latestPosition.volunteersNeeded == 0
                        ? 0
                        : (latestPosition.approvedCount /
                                latestPosition.volunteersNeeded)
                            .clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.primarySoft,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildFilterChips(l10n),
                const SizedBox(height: 12),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (filteredApplications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      l10n.noApplicationsYet,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  Column(
                    children: filteredApplications
                        .map(
                          (application) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildApplicationCard(
                              application,
                              l10n,
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

  Widget _buildFilterChips(AppLocalizations l10n) {
    final filters = [
      {'key': 'All', 'label': l10n.all},
      {'key': VolunteerApplicationStatus.pending, 'label': l10n.pending},
      {'key': VolunteerApplicationStatus.approved, 'label': l10n.approved},
      {'key': VolunteerApplicationStatus.rejected, 'label': l10n.rejected},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final key = filter['key']!;
          final label = filter['label']!;
          final isSelected = _selectedFilter == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                setState(() {
                  _selectedFilter = key;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected
                        ? AppColors.textWhite
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPositionHeader({
    required VolunteerPositionModel position,
    required int applicationCount,
    required int pendingCount,
    required AppLocalizations l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                position.roleName,
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            _buildPositionStatusBadge(position, l10n),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _statusChip(
              icon: Icons.hourglass_top_rounded,
              value: '$pendingCount',
              label: l10n.pending,
              bg: const Color(0xFFFFF4D8),
              color: const Color(0xFFE89A24),
            ),
            _statusChip(
              icon: Icons.people_rounded,
              value: '${position.approvedCount}/${position.volunteersNeeded}',
              label: l10n.approvedLower,
              bg: const Color(0xFFE6F6EA),
              color: const Color(0xFF2E7D32),
            ),
            _statusChip(
              icon: Icons.assignment_rounded,
              value: '$applicationCount',
              label: l10n.applications,
              bg: const Color(0xFFE6FAFA),
              color: const Color(0xFF19A7A8),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 12,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              _formatDate(position.eventDateTime),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplicationCard(
    VolunteerApplicationModel application,
    AppLocalizations l10n,
  ) {
    final isPending = application.status == VolunteerApplicationStatus.pending;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border.withOpacity(0.85),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      application.fullName.isNotEmpty
                          ? application.fullName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      application.fullName,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  _buildApplicationStatusBadge(application.status, l10n),
                ],
              ),
              const SizedBox(height: 13),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _detailTile(
                      label: l10n.faculty,
                      value: application.faculty,
                    ),
                    _detailDivider(),
                    _detailTile(
                      label: l10n.phone,
                      value: application.phoneNumber,
                    ),
                    _detailDivider(),
                    _detailTile(
                      label: l10n.experience,
                      value: application.previousExperience.isEmpty
                          ? l10n.noExperienceProvided
                          : application.previousExperience,
                    ),
                    _detailDivider(),
                    _availabilityTile(l10n),
                    _detailDivider(),
                    _detailTile(
                      label: l10n.applied,
                      value: application.appliedAt == null
                          ? '-'
                          : _formatDate(application.appliedAt!),
                    ),
                    if (application.rejectionReason != null &&
                        application.rejectionReason!.isNotEmpty) ...[
                      _detailDivider(),
                      _detailTile(
                        label: l10n.rejectionReason,
                        value: application.rejectionReason!,
                      ),
                    ],
                  ],
                ),
              ),
              if (isPending) ...[
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _controller.isUpdating
                            ? null
                            : () => _showApproveDialog(application, l10n),
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 17,
                        ),
                        label: Text(l10n.approve),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF49B95F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _controller.isUpdating
                            ? null
                            : () => _showRejectDialog(application, l10n),
                        icon: const Icon(
                          Icons.cancel_outlined,
                          size: 17,
                        ),
                        label: Text(l10n.reject),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB3261E),
                          side: const BorderSide(
                            color: Color(0xFFB3261E),
                            width: 1.1,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _detailTile({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityTile(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              l10n.availability,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F6EA),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 13,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.available,
                  style: AppTextStyles.label.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border.withOpacity(0.55),
    );
  }

  Widget _buildPositionStatusBadge(
    VolunteerPositionModel position,
    AppLocalizations l10n,
  ) {
    final isFull = position.isFull;
    final status = isFull ? l10n.full : l10n.open;

    final bg = isFull
        ? const Color(0xFFFFEAEA)
        : const Color(0xFFE6F6EA);

    final text = isFull
        ? const Color(0xFFB3261E)
        : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: AppTextStyles.label.copyWith(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildApplicationStatusBadge(
    String status,
    AppLocalizations l10n,
  ) {
    Color bg;
    Color text;
    String label;

    if (status == VolunteerApplicationStatus.approved) {
      bg = const Color(0xFFE6F6EA);
      text = const Color(0xFF2E7D32);
      label = l10n.approved;
    } else if (status == VolunteerApplicationStatus.rejected) {
      bg = const Color(0xFFFFEAEA);
      text = const Color(0xFFB3261E);
      label = l10n.rejected;
    } else {
      bg = const Color(0xFFFFF4D8);
      text = const Color(0xFFE89A24);
      label = l10n.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _statusChip({
    required IconData icon,
    required String value,
    required String label,
    required Color bg,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showApproveDialog(
  VolunteerApplicationModel application,
  AppLocalizations l10n,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          l10n.confirmApprove,
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          l10n.approveApplicationQuestion,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF49B95F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: Text(l10n.approve),
          ),
        ],
      );
    },
  );

  if (confirm != true) return;

  final success = await _controller.approveApplication(
    applicationId: application.id,
    positionId: application.positionId,
    reviewerUid: _reviewerUid,
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: success ? const Color(0xFF2E7D32) : null,
      content: Text(
        success
            ? l10n.applicationApprovedSuccessfully
            : _errorMessage(
                l10n,
                _controller.errorKey,
                l10n.failedToApproveApplication,
              ),
      ),
    ),
  );
}

Future<void> _showRejectDialog(
  VolunteerApplicationModel application,
  AppLocalizations l10n,
) async {
  final reasonController = TextEditingController();
  String? errorText;

  final reason = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            titlePadding: const EdgeInsets.fromLTRB(22, 20, 16, 0),
            contentPadding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            actionsPadding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAEA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.cancel_outlined,
                    color: Color(0xFFB3261E),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.rejectApplication,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => Navigator.pop(dialogContext),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.fullName,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: l10n.rejectionReasonHint,
                    errorText: errorText,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final reason = reasonController.text.trim();

                        if (reason.isEmpty) {
                          setDialogState(() {
                            errorText = l10n.rejectionReasonRequired;
                          });
                          return;
                        }

                        Navigator.pop(dialogContext, reason);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB3261E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(l10n.confirmReject),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    reasonController.dispose();
  });

  if (reason == null || reason.isEmpty) return;

  final success = await _controller.rejectApplication(
    applicationId: application.id,
    reviewerUid: _reviewerUid,
    rejectionReason: reason,
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: success ? const Color(0xFF2E7D32) : null,
      content: Text(
        success
            ? l10n.applicationRejectedSuccessfully
            : _errorMessage(
                l10n,
                _controller.errorKey,
                l10n.failedToRejectApplication,
              ),
      ),
    ),
  );
}

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}