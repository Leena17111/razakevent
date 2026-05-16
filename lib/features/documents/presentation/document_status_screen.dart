import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/widgets/language_toggle.dart';
import '../../../core/localization/locale_controller.dart';

class DocumentStatusScreen extends StatefulWidget {
  const DocumentStatusScreen({super.key});

  @override
  State<DocumentStatusScreen> createState() => _DocumentStatusScreenState();
}

class _DocumentStatusScreenState extends State<DocumentStatusScreen> {
  static const Color _navy = Color(0xFF1A237E);

  String _selectedFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _filterValues = ['All', 'Pending', 'Approved', 'Revision', 'Rejected'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .where('submittedBy', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          final filtered = _applyFilters(docs);

          final total = docs.length;
          final pending = docs.where((d) => _statusOf(d) == 'Pending Review').length;
          final approved = docs.where((d) => _statusOf(d) == 'Approved').length;
          final revision = docs.where((d) => _statusOf(d) == 'Needs Correction').length;

          return Column(
            children: [
              _buildHeader(context, total, pending, approved, revision, l10n),
              _buildSearchBar(l10n),
              _buildFilterTabs(l10n),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? _buildEmptyState(l10n)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) =>
                                _buildDocumentCard(context, filtered[index], l10n),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, int total, int pending, int approved, int revision, AppLocalizations l10n) {
    return Container(
      color: _navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Column(
        children: [
         Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.documentStatus,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            LanguageToggle(
              selectedLocale: Localizations.localeOf(context),
              onLocaleChanged: (locale) => localeController.value = locale,
            ),
          ],
        ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statChip(total.toString(), l10n.totalDocuments),
              _statChip(pending.toString(), l10n.filterPending),
              _statChip(approved.toString(), l10n.filterApproved),
              _statChip(revision.toString(), l10n.filterRevision),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String count, String label) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────
  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
        decoration: InputDecoration(
          hintText: l10n.searchDocuments,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ── Filter Tabs ───────────────────────────────────────────────────
  Widget _buildFilterTabs(AppLocalizations l10n) {
    final filterLabels = [
      l10n.filterAll,
      l10n.filterPending,
      l10n.filterApproved,
      l10n.filterRevision,
      l10n.filterRejected,
    ];

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: List.generate(_filterValues.length, (i) {
            final value = _filterValues[i];
            final label = filterLabels[i];
            final selected = _selectedFilter == value;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _navy : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Document Card ─────────────────────────────────────────────────
  Widget _buildDocumentCard(BuildContext context, QueryDocumentSnapshot doc, AppLocalizations l10n) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'Pending Review';
    final title = data['title'] as String? ?? '';
    final orgType = data['organizationType'] as String? ?? '';
    final orgName = data['organizationName'] as String? ?? '';
    final docType = data['documentType'] as String? ?? '';
    final submittedAt = data['submittedAt'] as Timestamp?;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.documentDetails,
        arguments: doc.id,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                _statusBadge(status, l10n),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _orgTypeBadge(orgType, l10n),
                const SizedBox(width: 8),
                Text(orgName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Text('$docType • ${_formatDate(submittedAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────
  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? l10n.noResultsFound : l10n.noDocumentsYet,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.uploadFirstDocument,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
  String _statusOf(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return data['status'] as String? ?? '';
  }

  List<QueryDocumentSnapshot> _applyFilters(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? '';
      final title = (data['title'] as String? ?? '').toLowerCase();
      final org = (data['organizationName'] as String? ?? '').toLowerCase();

      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Pending' && status == 'Pending Review') ||
          (_selectedFilter == 'Approved' && status == 'Approved') ||
          (_selectedFilter == 'Revision' && status == 'Needs Correction') ||
          (_selectedFilter == 'Rejected' && status == 'Rejected');

      final matchesSearch = _searchQuery.isEmpty ||
          title.contains(_searchQuery) ||
          org.contains(_searchQuery);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  Widget _statusBadge(String status, AppLocalizations l10n) {
    Color color;
    Color bg;
    IconData icon;
    String label;

    switch (status) {
      case 'Approved':
        color = Colors.green.shade700;
        bg = Colors.green.shade50;
        icon = Icons.check_circle_outline;
        label = l10n.statusApproved;
        break;
      case 'Needs Correction':
        color = Colors.orange.shade700;
        bg = Colors.orange.shade50;
        icon = Icons.error_outline;
        label = l10n.statusNeedsCorrection;
        break;
      case 'Rejected':
        color = Colors.red.shade700;
        bg = Colors.red.shade50;
        icon = Icons.cancel_outlined;
        label = l10n.statusRejected;
        break;
      default:
        color = Colors.blue.shade700;
        bg = Colors.blue.shade50;
        icon = Icons.access_time_rounded;
        label = l10n.statusPendingReview;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _orgTypeBadge(String type, AppLocalizations l10n) {
    final label = type == 'Exco' ? l10n.exco : l10n.club;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(color: _navy, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    return '${dt.day} ${_month(dt.month)} ${dt.year}';
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }
}