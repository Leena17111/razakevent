import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/logic/profile_controller.dart';
import '../../../data/models/volunteer_position_model.dart';
import '../../../data/repository/volunteer_repository.dart';
import '../../../data/models/volunteer_application_model.dart';
import '../widgets/volunteer_application_status_card.dart';
import '../widgets/volunteer_position_card.dart';
import 'apply_volunteer_position_screen.dart';

class StudentVolunteerPositionsScreen extends StatefulWidget {
  const StudentVolunteerPositionsScreen({super.key});

  @override
  State<StudentVolunteerPositionsScreen> createState() =>
      _StudentVolunteerPositionsScreenState();
}

class _StudentVolunteerPositionsScreenState
    extends State<StudentVolunteerPositionsScreen> {
  final VolunteerRepository _repository = VolunteerRepository();
  final ProfileController _profileController = ProfileController();

  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTab = 0;

  List<VolunteerPositionModel> _positions = [];
  List<VolunteerApplicationModel> _applications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final positions = await _repository.fetchOpenPositions();

      await _profileController.loadCurrentUserProfile();
      final user = _profileController.currentUserProfile;

      List<VolunteerApplicationModel> applications = [];
      if (user != null) {
        applications = await _repository.fetchMyApplications(user.uid);
      }

      if (!mounted) return;

      final appliedPositionIds = applications
          .map((application) => application.positionId)
          .toSet();

      final availablePositions = positions
          .where(
            (position) => !appliedPositionIds.contains(position.positionId),
          )
          .toList();

      setState(() {
        _positions = availablePositions;
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _openApplyScreen(VolunteerPositionModel position) async {
    final l10n = AppLocalizations.of(context)!;
    final user = _profileController.currentUserProfile;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.userNotAuthenticated)),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplyVolunteerPositionScreen(
          position: position,
          user: user,
        ),
      ),
    );

    if (result == true) {
      await _loadData();
      if (mounted) setState(() => _selectedTab = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.volunteerPositions),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          _buildLanguageToggle(),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          _tabButton(l10n.openPositions, 0),
                          _tabButton(l10n.myApplications, 1),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: _selectedTab == 0
                            ? _buildOpenPositions(l10n)
                            : _buildMyApplications(l10n),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
          if (index == 2) Navigator.pushNamed(context, '/profile');
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_rounded),
            label: l10n.navEvents,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.groups_rounded),
            label: l10n.navVolunteer,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final selected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpenPositions(AppLocalizations l10n) {
    if (_positions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 220),
          Center(child: Text(l10n.noOpenPositions)),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _positions.length,
      itemBuilder: (context, index) {
        final position = _positions[index];

        return VolunteerPositionCard(
          position: position,
          onApply: () => _openApplyScreen(position),
        );
      },
    );
  }

  Widget _buildMyApplications(AppLocalizations l10n) {
    if (_applications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 220),
          Center(child: Text(l10n.noApplicationsYet)),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        return VolunteerApplicationStatusCard(
          application: _applications[index],
        );
      },
    );
  }

  Widget _buildLanguageToggle() {
    final isBM = localeController.value.languageCode == 'ms';

    return Container(
      margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langButton(isBM, 'EN'),
          _langButton(isBM, 'BM'),
        ],
      ),
    );
  }

  Widget _langButton(bool isBM, String label) {
    final isActive = (label == 'BM' && isBM) || (label == 'EN' && !isBM);

    return GestureDetector(
      onTap: () {
        localeController.value = Locale(label == 'EN' ? 'en' : 'ms');
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}