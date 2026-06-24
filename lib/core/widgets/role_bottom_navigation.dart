import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import '../../features/profile/logic/profile_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../routes/app_routes.dart';

const volunteerRole = 'Volunteer';

class RoleDashboardDestination {
  final String title;
  final String subtitle;
  final String navLabel;
  final IconData icon;
  final Color color;
  final String routeName;
  final List<String> routeAliases;

  bool get isProfile => routeName == AppRoutes.profile;

  const RoleDashboardDestination({
    required this.title,
    required this.subtitle,
    required this.navLabel,
    required this.icon,
    required this.color,
    required this.routeName,
    this.routeAliases = const [],
  });

  const RoleDashboardDestination.profile()
    : title = 'Profile',
      subtitle = 'View and update your account details.',
      navLabel = 'Profile',
      icon = Icons.person_rounded,
      color = AppColors.primary,
      routeName = AppRoutes.profile,
      routeAliases = const [];

  bool matchesRoute(String route) {
    return routeName == route || routeAliases.contains(route);
  }
}

class RoleDashboardConfig {
  RoleDashboardConfig._();

  static List<RoleDashboardDestination> navigationForRole(String role) {
    if (role != UserRole.admin) return destinationsForRole(role);

    return const [
      RoleDashboardDestination(
        title: 'Documents',
        subtitle: 'Review and browse document records.',
        navLabel: 'Documents',
        icon: Icons.description_rounded,
        color: AppColors.accent,
        routeName: AppRoutes.reviewEventDocuments,
        routeAliases: [
          AppRoutes.adminDocumentDashboard,
          AppRoutes.adminReviewedDocuments,
        ],
      ),
      RoleDashboardDestination(
        title: 'Equipment',
        subtitle: 'Manage equipment inventory.',
        navLabel: 'Equipment',
        icon: Icons.inventory_rounded,
        color: AppColors.organizerBadgeText,
        routeName: AppRoutes.equipmentInventory,
      ),
      RoleDashboardDestination(
        title: 'Special Requests',
        subtitle: 'Review special equipment requests.',
        navLabel: 'Requests',
        icon: Icons.assignment_rounded,
        color: AppColors.studentBadgeText,
        routeName: AppRoutes.reviewSpecialEquipmentRequests,
      ),
      RoleDashboardDestination.profile(),
    ];
  }

  static List<RoleDashboardDestination> destinationsForRole(String role) {
    switch (role) {
      case UserRole.student:
        return const [
          RoleDashboardDestination(
            title: 'Events',
            subtitle: 'Browse and register for upcoming activities.',
            navLabel: 'Events',
            icon: Icons.event_available_rounded,
            color: AppColors.studentBadgeText,
            routeName: AppRoutes.browseEvents,
          ),
          RoleDashboardDestination(
            title: 'Feedback',
            subtitle: 'Submit feedback for events you joined.',
            navLabel: 'Feedback',
            icon: Icons.rate_review_rounded,
            color: AppColors.accent,
            routeName: AppRoutes.submitFeedback,
          ),
          RoleDashboardDestination(
            title: 'Volunteer Positions',
            subtitle: 'Apply for available volunteer roles.',
            navLabel: 'Volunteer',
            icon: Icons.groups_rounded,
            color: AppColors.secretaryBadgeText,
            routeName: AppRoutes.studentVolunteerPositions,
            routeAliases: [AppRoutes.volunteerPositions],
          ),
          RoleDashboardDestination(
            title: 'Certificates',
            subtitle: 'View participation and volunteer certificates.',
            navLabel: 'Certs',
            icon: Icons.workspace_premium_rounded,
            color: AppColors.organizerBadgeText,
            routeName: AppRoutes.certificates,
          ),
          RoleDashboardDestination.profile(),
        ];

      case UserRole.organizerHead:
        return const [
          RoleDashboardDestination(
            title: 'Documents',
            subtitle: 'Track event document approval status.',
            navLabel: 'Docs',
            icon: Icons.description_rounded,
            color: AppColors.secretaryBadgeText,
            routeName: AppRoutes.trackEventDocumentStatus,
          ),
          RoleDashboardDestination(
            title: 'Event Details',
            subtitle: 'Create and manage event information.',
            navLabel: 'Events',
            icon: Icons.event_note_rounded,
            color: AppColors.organizerBadgeText,
            routeName: AppRoutes.eventDetailsList,
          ),
          RoleDashboardDestination(
            title: 'Responses',
            subtitle: 'View feedback and registration records.',
            navLabel: 'Responses',
            icon: Icons.analytics_rounded,
            color: AppColors.studentBadgeText,
            routeName: AppRoutes.eventResponsesSelect,
          ),
          RoleDashboardDestination(
            title: 'Volunteer Positions',
            subtitle: 'Add positions and review applications.',
            navLabel: 'Volunteer',
            icon: Icons.groups_rounded,
            color: AppColors.accent,
            routeName: AppRoutes.volunteerManagement,
            routeAliases: [AppRoutes.addVolunteerPosition],
          ),
          RoleDashboardDestination(
            title: 'Feedback Form',
            subtitle: 'Set up feedback questions for events.',
            navLabel: 'Forms',
            icon: Icons.feedback_rounded,
            color: AppColors.accentDark,
            routeName: AppRoutes.createEventFeedbackForm,
          ),
          RoleDashboardDestination(
            title: 'Borrow Equipment',
            subtitle: 'Request and manage borrowed items.',
            navLabel: 'Equipment',
            icon: Icons.inventory_2_rounded,
            color: AppColors.primaryLight,
            routeName: AppRoutes.selectEquipmentEvent,
          ),
          RoleDashboardDestination.profile(),
        ];

      case UserRole.secretary:
        return const [
          RoleDashboardDestination(
            title: 'Proposed Events',
            subtitle: 'Review event paperwork and proposal details.',
            navLabel: 'Events',
            icon: Icons.event_note_rounded,
            color: AppColors.secretaryBadgeText,
            routeName: AppRoutes.secretaryProposedEvents,
          ),
          RoleDashboardDestination(
            title: 'Document Status',
            subtitle: 'Track submitted event documents.',
            navLabel: 'Status',
            icon: Icons.fact_check_rounded,
            color: AppColors.studentBadgeText,
            routeName: AppRoutes.trackEventDocumentStatus,
          ),
          RoleDashboardDestination.profile(),
        ];

      case UserRole.admin:
        return const [
          RoleDashboardDestination(
            title: 'Document Review',
            subtitle: 'Review pending event documents.',
            navLabel: 'Review',
            icon: Icons.rule_folder_rounded,
            color: AppColors.accent,
            routeName: AppRoutes.reviewEventDocuments,
            routeAliases: [AppRoutes.adminDocumentDashboard],
          ),
          RoleDashboardDestination(
            title: 'Archive',
            subtitle: 'Browse reviewed document records.',
            navLabel: 'Archive',
            icon: Icons.inventory_2_rounded,
            color: AppColors.textSecondary,
            routeName: AppRoutes.adminReviewedDocuments,
          ),
          RoleDashboardDestination(
            title: 'Equipment',
            subtitle: 'Manage equipment inventory.',
            navLabel: 'Equipment',
            icon: Icons.inventory_rounded,
            color: AppColors.organizerBadgeText,
            routeName: AppRoutes.equipmentInventory,
          ),
          RoleDashboardDestination(
            title: 'Special Requests',
            subtitle: 'Review special equipment requests.',
            navLabel: 'Requests',
            icon: Icons.assignment_rounded,
            color: AppColors.studentBadgeText,
            routeName: AppRoutes.reviewSpecialEquipmentRequests,
          ),
          RoleDashboardDestination.profile(),
        ];

      case volunteerRole:
        return const [
          RoleDashboardDestination(
            title: 'Volunteer Positions',
            subtitle: 'Apply for available volunteer roles.',
            navLabel: 'Volunteer',
            icon: Icons.groups_rounded,
            color: AppColors.secretaryBadgeText,
            routeName: AppRoutes.studentVolunteerPositions,
            routeAliases: [AppRoutes.volunteerPositions],
          ),
          RoleDashboardDestination(
            title: 'Certificates',
            subtitle: 'View volunteer certificates.',
            navLabel: 'Certs',
            icon: Icons.workspace_premium_rounded,
            color: AppColors.organizerBadgeText,
            routeName: AppRoutes.certificates,
          ),
          RoleDashboardDestination.profile(),
        ];

      default:
        return const [RoleDashboardDestination.profile()];
    }
  }
}

class RoleNavigationScaffold extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const RoleNavigationScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<RoleNavigationScaffold> createState() => _RoleNavigationScaffoldState();
}

class _RoleNavigationScaffoldState extends State<RoleNavigationScaffold> {
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

  @override
  Widget build(BuildContext context) {
    final user = _profileController.currentUserProfile;
    final destinations = user == null
        ? const <RoleDashboardDestination>[]
        : RoleDashboardConfig.navigationForRole(user.role);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: user == null || _profileController.isLoading
          ? null
          : RoleBottomNavigation(
              destinations: destinations,
              currentRoute: widget.currentRoute,
            ),
    );
  }
}

class RoleBottomNavigation extends StatelessWidget {
  final List<RoleDashboardDestination> destinations;
  final String currentRoute;
  final ValueChanged<RoleDashboardDestination>? onDestinationSelected;

  const RoleBottomNavigation({
    super.key,
    required this.destinations,
    required this.currentRoute,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      const RoleDashboardDestination(
        title: 'Dashboard',
        subtitle: 'Current role dashboard.',
        navLabel: 'Home',
        icon: Icons.dashboard_rounded,
        color: AppColors.primary,
        routeName: AppRoutes.home,
      ),
      ...destinations,
    ];

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
          child: Row(
            children: [
              for (final item in navItems) ...[
                _RoleBottomNavItem(
                  item: item,
                  isSelected: item.matchesRoute(currentRoute),
                  onTap: () => _handleTap(context, item),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, RoleDashboardDestination item) {
    if (item.matchesRoute(currentRoute)) return;

    final callback = onDestinationSelected;
    if (callback != null) {
      callback(item);
      return;
    }

    if (item.routeName == AppRoutes.home) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
      return;
    }

    Navigator.pushReplacementNamed(context, item.routeName);
  }
}

class _RoleBottomNavItem extends StatelessWidget {
  final RoleDashboardDestination item;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleBottomNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? AppColors.textWhite
        : AppColors.textSecondary;
    final background = isSelected ? AppColors.primary : AppColors.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 78,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: foreground, size: 21),
              const SizedBox(height: 4),
              Text(
                item.navLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: foreground,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
