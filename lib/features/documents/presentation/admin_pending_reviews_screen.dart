import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/event_lists.dart';
import '../../../core/constants/organization_lists.dart';
import '../../../core/routes/app_routes.dart';

class AdminPendingReviewsScreen extends StatefulWidget {
  const AdminPendingReviewsScreen({super.key});

  @override
  State<AdminPendingReviewsScreen> createState() =>
      _AdminPendingReviewsScreenState();
}

class _AdminPendingReviewsScreenState extends State<AdminPendingReviewsScreen> {
  static const Color _navy = Color(0xFF1A237E);

  String _orgType = 'All';
  String? _selectedOrgName;
  String? _selectedDocType;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  bool _showOrgDropdown = false;
  bool _showDocTypeDropdown = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _orgDropdownItems {
    if (_orgType == 'Exco') {
      return ['All Excos', ...OrganizationLists.excoNames];
    }
    return ['All Clubs', ...OrganizationLists.clubNames];
  }

  List<String> get _documentTypeDropdownItems {
    return ['All Document Types', ...EventLists.documentTypes];
  }

  String get _selectedOrgLabel {
    if (_selectedOrgName != null) return _selectedOrgName!;
    return _orgType == 'Exco' ? 'All Excos' : 'All Clubs';
  }

  String get _selectedDocTypeLabel {
    return _selectedDocType ?? 'All Document Types';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .where('status', isEqualTo: 'Pending Review')
            .snapshots(),
        builder: (context, snapshot) {
          final allPending = snapshot.data?.docs ?? [];
          final filtered = _applyFilters(allPending);

          return Column(
            children: [
              _buildHeader(context, filtered.length),
              _buildFilterCard(),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? _buildEmptyState()
                        : GestureDetector(
                            onTap: _closeDropdowns,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _buildDocumentCard(
                                  context,
                                  filtered[index],
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Container(
      decoration: const BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pending Reviews',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Documents awaiting review',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return GestureDetector(
      onTap: _closeDropdowns,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(16),
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
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search documents...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
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
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _orgTypeButton('All'),
                          const SizedBox(width: 8),
                          _orgTypeButton('Exco'),
                          const SizedBox(width: 8),
                          _orgTypeButton('Club'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildOrgDropdown(),
                      const SizedBox(height: 8),
                      _buildDocumentTypeDropdown(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _orgTypeButton(String type) {
    final selected = _orgType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _orgType = type;
            _selectedOrgName = null;
            _showOrgDropdown = false;
            _showDocTypeDropdown = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _navy : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade700,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrgDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showOrgDropdown = !_showOrgDropdown;
              _showDocTypeDropdown = false;
            });
          },
          child: _dropdownTrigger(_selectedOrgLabel),
        ),
        if (_showOrgDropdown)
          _dropdownList(
            items: _orgDropdownItems,
            selectedItem: _selectedOrgLabel,
            onSelect: (value) {
              setState(() {
                if (value == 'All Excos' || value == 'All Clubs') {
                  _selectedOrgName = null;
                } else {
                  _selectedOrgName = value;
                }
                _showOrgDropdown = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildDocumentTypeDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showDocTypeDropdown = !_showDocTypeDropdown;
              _showOrgDropdown = false;
            });
          },
          child: _dropdownTrigger(_selectedDocTypeLabel),
        ),
        if (_showDocTypeDropdown)
          _dropdownList(
            items: _documentTypeDropdownItems,
            selectedItem: _selectedDocTypeLabel,
            onSelect: (value) {
              setState(() {
                if (value == 'All Document Types') {
                  _selectedDocType = null;
                } else {
                  _selectedDocType = value;
                }
                _showDocTypeDropdown = false;
              });
            },
          ),
      ],
    );
  }

  Widget _dropdownTrigger(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _dropdownList({
    required List<String> items,
    required String selectedItem,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      constraints: const BoxConstraints(maxHeight: 230),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = item == selectedItem;

            return InkWell(
              onTap: () => onSelect(item),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                color: isSelected ? Colors.blue.shade400 : Colors.white,
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check : null,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final title = data['title'] as String? ?? '';
    final orgType = data['organizationType'] as String? ?? '';
    final orgName = data['organizationName'] as String? ?? '';
    final docType = data['documentType'] as String? ?? '';
    final submittedAt = data['submittedAt'] as Timestamp?;
    final submittedBy = data['submittedByName'] as String? ?? '';

    final isClub = orgType.toLowerCase() == 'club';
    final chipColor = isClub ? Colors.purple : _navy;
    final chipBg =
        isClub ? Colors.purple.withValues(alpha: 0.1) : const Color(0xFFE8EAF6);
    final iconBg = isClub ? Colors.purple : Colors.blue.shade600;

    return GestureDetector(
      onTap: () {
        _closeDropdowns();
        Navigator.of(context).pushNamed(
          AppRoutes.adminReviewDocument,
          arguments: doc.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.insert_drive_file_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isNotEmpty ? title : 'Untitled Document',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          orgType.isNotEmpty ? orgType : '-',
                          style: TextStyle(
                            color: chipColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          orgName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$docType • ${_formatDate(submittedAt)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (submittedBy.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'By $submittedBy',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: Colors.orange.shade700,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: _closeDropdowns,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, color: Colors.grey, size: 48),
            SizedBox(height: 12),
            Text(
              'No pending documents',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  List<QueryDocumentSnapshot> _applyFilters(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final title = (data['title'] as String? ?? '').toLowerCase();
      final orgType = data['organizationType'] as String? ?? '';
      final orgName = data['organizationName'] as String? ?? '';
      final docType = data['documentType'] as String? ?? '';
      final submittedBy = (data['submittedByName'] as String? ?? '')
          .toLowerCase();

      final matchesOrgType = _orgType == 'All' ||
          orgType.toLowerCase() == _orgType.toLowerCase();

      final matchesOrgName =
          _selectedOrgName == null || orgName == _selectedOrgName;

      final matchesDocType =
          _selectedDocType == null || docType == _selectedDocType;

      final matchesSearch = _searchQuery.isEmpty ||
          title.contains(_searchQuery) ||
          orgName.toLowerCase().contains(_searchQuery) ||
          docType.toLowerCase().contains(_searchQuery) ||
          submittedBy.contains(_searchQuery);

      return matchesOrgType &&
          matchesOrgName &&
          matchesDocType &&
          matchesSearch;
    }).toList();
  }

  void _closeDropdowns() {
    if (!_showOrgDropdown && !_showDocTypeDropdown) return;

    setState(() {
      _showOrgDropdown = false;
      _showDocTypeDropdown = false;
    });
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '-';

    final date = timestamp.toDate();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}