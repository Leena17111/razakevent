// lib/features/home/presentation/home_screen.dart
//
// Home screen with role-based dashboard.
// Shows:
//   - Home title with initial-letter profile button
//   - Welcome card based on user role
//   - One main action card based on user role

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../profile/logic/profile_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProfileController _profileController = ProfileController();

  @override
  void initState() {
    super.initState();
    _profileController.addListener(_onControllerChanged);
    _profileController.loadCurrentUserProfile();
  }

  @override
  void dispose() {
    _profileController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  String _firstName(String fullName) {
    final trimmed = fullName.trim();

    if (trimmed.isEmpty) return 'there';

    return trimmed.split(' ').first;
  }

  String _initialFromName(String fullName) {
    final trimmed = fullName.trim();

    if (trimmed.isEmpty) return '?';

    return trimmed[0].toUpperCase();
  }

  Color _roleColor(String role) {
    switch (role) {
      case UserRole.student:
        return AppColors.studentBadgeText;
      case UserRole.organizerHead:
        return AppColors.clubBadgeText;
      case UserRole.secretary:
        return AppColors.communityBadgeText;
      case UserRole.admin:
        return AppColors.adminBadgeText;
      default:
        return AppColors.studentBadgeText;
    }
  }

  Color _roleBadgeBg(String role) {
    switch (role) {
      case UserRole.student:
        return AppColors.studentBadgeBg;
      case UserRole.organizerHead:
        return AppColors.clubBadgeBg;
      case UserRole.secretary:
        return AppColors.communityBadgeBg;
      case UserRole.admin:
        return AppColors.adminBadgeBg;
      default:
        return AppColors.studentBadgeBg;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case UserRole.student:
        return Icons.school_rounded;
      case UserRole.organizerHead:
        return Icons.groups_rounded;
      case UserRole.secretary:
        return Icons.description_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _dashboardTitle(String role) {
    switch (role) {
      case UserRole.student:
        return 'Student Dashboard';
      case UserRole.organizerHead:
        return 'Organizer Head Dashboard';
      case UserRole.secretary:
        return 'Secretary Dashboard';
      case UserRole.admin:
        return 'Admin Dashboard';
      default:
        return 'Dashboard';
    }
  }

  String _welcomeSubtitle(String role) {
    switch (role) {
      case UserRole.student:
        return 'Explore KTR events and activities made for students.';
      case UserRole.organizerHead:
        return 'Manage your organization events and keep activities on track.';
      case UserRole.secretary:
        return 'Manage event documents, proposals, and reports in one place.';
      case UserRole.admin:
        return 'Review submitted documents and monitor event administration.';
      default:
        return 'Access your RazakEvent dashboard.';
    }
  }

  String _mainActionTitle(String role) {
    switch (role) {
      case UserRole.student:
        return 'Discover Events';
      case UserRole.organizerHead:
        return 'Manage My Events';
      case UserRole.secretary:
        return 'Manage Documents';
      case UserRole.admin:
        return 'Review Documents';
      default:
        return 'View Dashboard';
    }
  }

  String _mainActionSubtitle(String role) {
    switch (role) {
      case UserRole.student:
        return 'Browse upcoming KTR events and activities.';
      case UserRole.organizerHead:
        return 'Create, update, and track events under your organization.';
      case UserRole.secretary:
        return 'Upload and manage proposals, reports, and financial documents.';
      case UserRole.admin:
        return 'Review submitted proposals, reports, and official documents.';
      default:
        return 'Access your RazakEvent dashboard.';
    }
  }

  IconData _mainActionIcon(String role) {
    switch (role) {
      case UserRole.student:
        return Icons.event_available_rounded;
      case UserRole.organizerHead:
        return Icons.edit_calendar_rounded;
      case UserRole.secretary:
        return Icons.folder_copy_rounded;
      case UserRole.admin:
        return Icons.fact_check_rounded;
      default:
        return Icons.dashboard_rounded;
    }
  }

  void _showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$featureName will be added in the next sprint.',
          style: AppTextStyles.body.copyWith(color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Future<void> _openProfile() async {
  await Navigator.pushNamed(context, AppRoutes.profile);

  if (!mounted) return;

  await _profileController.loadCurrentUserProfile();
}

  @override
  Widget build(BuildContext context) {
    final user = _profileController.currentUserProfile;
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 520 ? 460.0 : screenWidth;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: contentWidth,
          child: _profileController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : user == null
                  ? _buildErrorState()
                  : SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopBar(user),
                            const SizedBox(height: 14),
                            _buildWelcomeCard(user),
                            const SizedBox(height: 14),
                            _buildDashboardSection(user),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildTopBar(UserModel user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Home',
            style: AppTextStyles.title.copyWith(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: _openProfile,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primary,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowNavy,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _initialFromName(user.fullName),
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(UserModel user) {
    final roleColor = _roleColor(user.role);
    final roleBadgeBg = _roleBadgeBg(user.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowNavy,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -24,
            child: Icon(
              Icons.calendar_month_rounded,
              size: 125,
              color: AppColors.textWhite.withOpacity(0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${_firstName(user.fullName)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                width: 300,
                child: Text(
                  _welcomeSubtitle(user.role),
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textWhite.withOpacity(0.84),
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: roleBadgeBg,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_roleIcon(user.role), color: roleColor, size: 16),
                    const SizedBox(width: 7),
                    Text(
                      user.role,
                      style: AppTextStyles.label.copyWith(
                        color: roleColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSection(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(user),
          const SizedBox(height: 16),
          _buildMainActionCard(user),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(UserModel user) {
    final roleColor = _roleColor(user.role);

    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: roleColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _dashboardTitle(user.role).toUpperCase(),
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionCard(UserModel user) {
    final roleColor = _roleColor(user.role);
    final roleBadgeBg = _roleBadgeBg(user.role);
    final title = _mainActionTitle(user.role);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _showComingSoon(title),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: roleBadgeBg,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  _mainActionIcon(user.role),
                  color: roleColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _mainActionSubtitle(user.role),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textMuted,
                  size: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              _profileController.errorMessage ?? 'Could not load dashboard.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _profileController.loadCurrentUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
              ),
              child: Text(
                'Try Again',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}