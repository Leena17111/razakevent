import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../l10n/app_localizations.dart';

class AdminDocumentDashboardScreen extends StatelessWidget {
  const AdminDocumentDashboardScreen({super.key});

  static const Color _navy = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          final pending = docs
              .where((d) => _statusOf(d) == 'Pending Review')
              .length;
          final reviewed = docs
              .where((d) => _statusOf(d) != 'Pending Review')
              .length;
          final thisWeek = _countThisWeek(docs);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: _buildStatCards(context, pending, reviewed, thisWeek),
              ),
              SliverToBoxAdapter(child: _buildActionCards(context, pending)),
              SliverToBoxAdapter(child: _buildRecentActivity(context, docs)),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),

              const Spacer(),

              LanguageToggle(
                selectedLocale: Localizations.localeOf(context),
                onLocaleChanged: (locale) => localeController.value = locale,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.documentReviewDashboardTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.documentReviewDashboardSubtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Stat Cards ─────────────────────────────────────────────────────
  Widget _buildStatCards(
    BuildContext context,
    int pending,
    int reviewed,
    int thisWeek,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          _statCard(
            icon: Icons.access_time_rounded,
            iconColor: Colors.orange.shade600,
            iconBg: Colors.orange.shade50,
            count: pending,
            label: l10n.pending,
          ),
          const SizedBox(width: 12),
          _statCard(
            icon: Icons.check_circle_rounded,
            iconColor: Colors.green.shade600,
            iconBg: Colors.green.shade50,
            count: reviewed,
            label: l10n.reviewed,
          ),
          const SizedBox(width: 12),
          _statCard(
            icon: Icons.insert_drive_file_rounded,
            iconColor: _navy,
            iconBg: const Color(0xFFE8EAF6),
            count: thisWeek,
            label: l10n.thisWeek,
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required int count,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action Cards ──────────────────────────────────────────────────
  Widget _buildActionCards(BuildContext context, int pendingCount) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.adminPendingReviews);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.fact_check_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.review,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.reviewPendingDocuments,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.pendingCount(pendingCount),
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.adminReviewedDocuments);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.archive_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.archive,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.viewReviewedDocuments,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Activity ───────────────────────────────────────────────
  Widget _buildRecentActivity(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final reviewed = docs
        .where((d) => _statusOf(d) != 'Pending Review')
        .take(5)
        .toList();

    if (reviewed.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentActivity.toUpperCase(),
            style: const TextStyle(
              color: _navy,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ...reviewed.map((doc) => _activityTile(context, doc)),
        ],
      ),
    );
  }

  Widget _activityTile(BuildContext context, QueryDocumentSnapshot doc) {
    final l10n = AppLocalizations.of(context)!;
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] as String? ?? '';
    final title = data['title'] as String? ?? '';
    final orgName = data['organizationName'] as String? ?? '';
    final reviewedAt = data['reviewedAt'] as Timestamp?;

    Color iconColor;
    IconData icon;

    switch (status) {
      case 'Approved':
        iconColor = _navy;
        icon = Icons.check_circle_rounded;
        break;
      case 'Needs Correction':
        iconColor = _navy;
        icon = Icons.error_rounded;
        break;
      case 'Rejected':
        iconColor = _navy;
        icon = Icons.cancel_rounded;
        break;
      default:
        iconColor = _navy;
        icon = Icons.access_time_rounded;
    }

    final timeAgo = _timeAgo(context, reviewedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isNotEmpty ? title : l10n.untitledDocument,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  orgName,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  '${_statusLabel(l10n, status)} • $timeAgo',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
  String _statusOf(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return data['status'] as String? ?? '';
  }

  int _countThisWeek(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final ts = data['submittedAt'] as Timestamp?;

      if (ts == null) return false;

      return ts.toDate().isAfter(weekStartDate);
    }).length;
  }

  String _timeAgo(BuildContext context, Timestamp? ts) {
    final l10n = AppLocalizations.of(context)!;
    if (ts == null) return '';

    final now = DateTime.now();
    final diff = now.difference(ts.toDate());

    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);

    return l10n.daysAgo(diff.inDays);
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'Approved':
        return l10n.approved;
      case 'Needs Correction':
        return l10n.needsCorrection;
      case 'Rejected':
        return l10n.rejected;
      case 'Pending Review':
        return l10n.pendingReview;
      default:
        return status;
    }
  }
}
