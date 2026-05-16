// lib/features/home/presentation/home_screen.dart
//
// Role-based home dashboard.
// Sprint 1:
//   - Loads authenticated user's Firestore profile.
//   - Keeps profile shortcut.
// Sprint 2 setup:
//   - Shows role-based dashboard entry cards.
//   - Uses prepared AppRoutes names.
//   - Does not navigate to missing Sprint 2 screens yet.
//   - Does not show dummy stats or fake recent documents.

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

  String _organizerOrganizationName(UserModel user) {
    final organizationName = user.organizationName?.trim();

    if (organizationName == null || organizationName.isEmpty) {
      return 'Organizer Head';
    }

    return organizationName;
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

  String _heroTitle(UserModel user) {
    switch (user.role) {
      case UserRole.admin:
        return 'Document Review';
      case UserRole.organizerHead:
        return _organizerOrganizationName(user);
      case UserRole.secretary:
        return 'Secretary';
      case UserRole.student:
        return 'Student';
      default:
        return 'Dashboard';
    }
  }

  String _heroSubtitle(String role) {
    switch (role) {
      case UserRole.student:
        return 'Explore KTR events and activities.';
      case UserRole.organizerHead:
        return 'Manage your events';
      case UserRole.secretary:
        return 'Manage event documentation';
      case UserRole.admin:
        return 'Review and approve event documentation';
      default:
        return 'Access your RazakEvent dashboard.';
    }
  }

  Future<void> _openProfile() async {
    await Navigator.pushNamed(context, AppRoutes.profile);

    if (!mounted) return;

    await _profileController.loadCurrentUserProfile();
  }

  void _showPreparedFeature(String featureName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$featureName screen will be connected by the assigned teammate.',
          style: AppTextStyles.body.copyWith(color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$featureName will be added in a later sprint.',
          style: AppTextStyles.body.copyWith(color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
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
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopBar(user),
                            const SizedBox(height: 16),
                            _buildHeroCard(user),
                            const SizedBox(height: 18),
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
      children: [
        Expanded(
          child: Text(
            'Home',
            style: AppTextStyles.title.copyWith(
              color: AppColors.textPrimary,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
        ),
        _buildCircleIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => _showComingSoon('Notifications'),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: _openProfile,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowNavy,
                    blurRadius: 14,
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

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(UserModel user) {
    final roleColor = _roleColor(user.role);
    final roleBadgeBg = _roleBadgeBg(user.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowNavy,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            bottom: -28,
            child: Icon(
              _heroBackgroundIcon(user.role),
              size: 128,
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
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textWhite.withOpacity(0.82),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _heroTitle(user),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                width: 300,
                child: Text(
                  _heroSubtitle(user.role),
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textWhite.withOpacity(0.86),
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
                    Icon(
                      _roleIcon(user.role),
                      color: roleColor,
                      size: 16,
                    ),
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

  IconData _heroBackgroundIcon(String role) {
    switch (role) {
      case UserRole.admin:
        return Icons.fact_check_rounded;
      case UserRole.organizerHead:
        return Icons.calendar_month_rounded;
      case UserRole.secretary:
        return Icons.description_rounded;
      case UserRole.student:
        return Icons.event_available_rounded;
      default:
        return Icons.dashboard_rounded;
    }
  }

  Widget _buildDashboardSection(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(user),
          const SizedBox(height: 16),
          _buildRoleActionCards(user),
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
          height: 20,
          decoration: BoxDecoration(
            color: roleColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 9),
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

  Widget _buildRoleActionCards(UserModel user) {
    switch (user.role) {
      case UserRole.organizerHead:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Documents',
                    subtitle: 'Track approval status',
                    icon: Icons.description_rounded,
                    color: AppColors.communityBadgeText,
                    routeName: AppRoutes.trackEventDocumentStatus,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    title: 'Event Details',
                    subtitle: 'Manage event info',
                    icon: Icons.event_note_rounded,
                    color: AppColors.clubBadgeText,
                    routeName: AppRoutes.eventDetailsList,
                    isCompact: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildActionCard(
              title: 'Feedback Form',
              subtitle: 'Set up event feedback',
              icon: Icons.feedback_rounded,
              color: AppColors.accent,
              routeName: AppRoutes.createEventFeedbackForm,
              isAccentWide: true,
            ),
          ],
        );

      case UserRole.secretary:
        return Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Upload',
                subtitle: 'Submit event documents',
                icon: Icons.upload_file_rounded,
                color: AppColors.communityBadgeText,
                routeName: AppRoutes.uploadEventDocument,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Status',
                subtitle: 'Track all documents',
                icon: Icons.fact_check_rounded,
                color: AppColors.studentBadgeText,
                routeName: AppRoutes.trackEventDocumentStatus,
                isCompact: true,
              ),
            ),
          ],
        );

      case UserRole.admin:
        return Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Review',
                subtitle: 'Review pending documents',
                icon: Icons.rule_folder_rounded,
                color: AppColors.accent,
                routeName: AppRoutes.reviewEventDocuments,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Archive',
                subtitle: 'View reviewed documents',
                icon: Icons.inventory_2_rounded,
                color: AppColors.textSecondary,
                routeName: '',
                isCompact: true,
              ),
            ),
          ],
        );

      case UserRole.student:
        return _buildActionCard(
          title: 'Discover Events',
          subtitle: 'Browse upcoming KTR events and activities.',
          icon: Icons.event_available_rounded,
          color: AppColors.studentBadgeText,
          routeName: '',
        );

      default:
        return _buildActionCard(
          title: 'View Dashboard',
          subtitle: 'Access your RazakEvent dashboard.',
          icon: Icons.dashboard_rounded,
          color: AppColors.primary,
          routeName: '',
        );
    }
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String routeName,
    bool isCompact = false,
    bool isAccentWide = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          if (routeName.isEmpty) {
            _showComingSoon(title);
            return;
          }

          Navigator.pushNamed(context, routeName);
        },
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: isCompact ? 122 : 92,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAccentWide ? AppColors.accent : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isAccentWide ? AppColors.accent : AppColors.borderLight,
            ),
            boxShadow: isAccentWide
                ? const [
                    BoxShadow(
                      color: AppColors.shadowDark,
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: isCompact
              ? _buildCompactCardContent(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  color: color,
                )
              : _buildWideCardContent(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  color: color,
                  isAccentWide: isAccentWide,
                ),
        ),
      ),
    );
  }

  Widget _buildCompactCardContent({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardIcon(icon: icon, color: color),
        const SizedBox(height: 18),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11.8,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildWideCardContent({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isAccentWide,
  }) {
    final textColor = isAccentWide ? AppColors.textWhite : AppColors.textPrimary;
    final subtitleColor = isAccentWide
        ? AppColors.textWhite.withOpacity(0.84)
        : AppColors.textSecondary;

    return Row(
      children: [
        _buildCardIcon(
          icon: icon,
          color: color,
          isAccent: isAccentWide,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: subtitleColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: isAccentWide ? AppColors.textWhite : AppColors.textMuted,
          size: 14,
        ),
      ],
    );
  }

  Widget _buildCardIcon({
    required IconData icon,
    required Color color,
    bool isAccent = false,
  }) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isAccent
            ? AppColors.textWhite.withOpacity(0.16)
            : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: isAccent ? AppColors.textWhite : color,
        size: 24,
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