// lib/features/home/presentation/home_screen.dart

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/role_bottom_navigation.dart';
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
      case volunteerRole:
        return AppColors.studentBadgeText;
      case UserRole.organizerHead:
        return AppColors.organizerBadgeText;
      case UserRole.secretary:
        return AppColors.secretaryBadgeText;
      case UserRole.admin:
        return AppColors.adminBadgeText;
      default:
        return AppColors.primary;
    }
  }

  Color _roleBadgeBg(String role) {
    switch (role) {
      case UserRole.student:
      case volunteerRole:
        return AppColors.studentBadgeBg;
      case UserRole.organizerHead:
        return AppColors.organizerBadgeBg;
      case UserRole.secretary:
        return AppColors.secretaryBadgeBg;
      case UserRole.admin:
        return AppColors.adminBadgeBg;
      default:
        return AppColors.primarySoft;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case UserRole.student:
        return Icons.school_rounded;
      case volunteerRole:
        return Icons.volunteer_activism_rounded;
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
      case volunteerRole:
        return 'Volunteer Dashboard';
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
        return 'Secretary Workspace';
      case UserRole.student:
        return 'Student Hub';
      case volunteerRole:
        return 'Volunteer Hub';
      default:
        return 'Dashboard';
    }
  }

  String _heroSubtitle(String role) {
    switch (role) {
      case UserRole.student:
        return 'Explore events and manage your participation.';
      case volunteerRole:
        return 'View roles and manage your applications.';
      case UserRole.organizerHead:
        return 'Manage events, feedback, volunteers, and equipment.';
      case UserRole.secretary:
        return 'Upload and track event documents.';
      case UserRole.admin:
        return 'Review and manage KTR event operations.';
      default:
        return 'Access your RazakEvent dashboard.';
    }
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
      case volunteerRole:
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.dashboard_rounded;
    }
  }

  List<RoleDashboardDestination> _dashboardItems(String role) {
    return RoleDashboardConfig.destinationsForRole(role);
  }

  Future<void> _openProfile() async {
    await Navigator.pushNamed(context, AppRoutes.profile);

    if (!mounted) return;

    await _profileController.loadCurrentUserProfile();
  }

  Future<void> _openDashboardItem(RoleDashboardDestination item) async {
    if (item.isProfile) {
      await _openProfile();
      return;
    }

    if (item.routeName == AppRoutes.home) return;

    await Navigator.pushNamed(context, item.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final user = _profileController.currentUserProfile;
    final isLoading = _profileController.isLoading;
    final items = user == null
        ? const <RoleDashboardDestination>[]
        : _dashboardItems(user.role);
    final navItems = user == null
        ? const <RoleDashboardDestination>[]
        : RoleDashboardConfig.navigationForRole(user.role);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: user == null || isLoading
          ? null
          : RoleBottomNavigation(
              destinations: navItems,
              currentRoute: AppRoutes.home,
              onDestinationSelected: _openDashboardItem,
            ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : user == null
          ? _buildErrorState()
          : SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth >= 720
                      ? 32.0
                      : 18.0;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      28,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 980),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopBar(user),
                            const SizedBox(height: 18),
                            _buildHeroCard(user),
                            const SizedBox(height: 20),
                            _buildDashboardSection(user, items),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildTopBar(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Welcome back, ${_firstName(user.fullName)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title.copyWith(
              color: AppColors.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _openProfile,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1.4),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowNavy,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _initialFromName(user.fullName),
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(UserModel user) {
    final roleColor = _roleColor(user.role);
    final roleBadgeBg = _roleBadgeBg(user.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
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
            right: -18,
            bottom: -24,
            child: Icon(
              _heroBackgroundIcon(user.role),
              size: 132,
              color: AppColors.textWhite.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _heroTitle(user),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  _heroSubtitle(user.role),
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.86),
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
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

  Widget _buildDashboardSection(
    UserModel user,
    List<RoleDashboardDestination> items,
  ) {
    final gridItems = items.where((item) => !item.isProfile).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(user),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = _gridColumnCount(constraints.maxWidth);

              return GridView.builder(
                itemCount: gridItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: count == 1 ? 132 : 164,
                ),
                itemBuilder: (context, index) {
                  final item = gridItems[index];
                  return _DashboardCard(
                    item: item,
                    onTap: () => _openDashboardItem(item),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  int _gridColumnCount(double width) {
    if (width >= 760) return 3;
    if (width >= 360) return 2;
    return 1;
  }

  Widget _buildSectionHeader(UserModel user) {
    final roleColor = _roleColor(user.role);

    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: roleColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _dashboardTitle(user.role).toUpperCase(),
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
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

class _DashboardCard extends StatelessWidget {
  final RoleDashboardDestination item;
  final VoidCallback onTap;

  const _DashboardCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DashboardIcon(icon: item.icon, color: item.color),
              const Spacer(),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _DashboardIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
