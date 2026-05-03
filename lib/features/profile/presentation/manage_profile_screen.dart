// lib/features/profile/presentation/manage_profile_screen.dart
//
// Manage Profile screen.
// Shows current user's profile from Firestore and allows editing basic details.
// Avatar uses the initial letter of the user's full name instead of profile photo.
//
// Role-based fields:
//   - Student: Full Name, Email, Matric Number, Phone Number
//   - Organizer Head: Full Name, Email, Matric Number, Phone Number, Organization Type, Organization Name
//   - Secretary: Full Name, Email, Matric Number, Phone Number
//   - Admin: Full Name, Email only

import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';
import '../../auth/presentation/login_screen.dart';
import '../logic/profile_controller.dart';

const _navy = Color(0xFF1A237E);
const _navyLight = Color(0xFF303F9F);
const _red = Color(0xFFC8102E);
const _bg = Color(0xFFF5F6FA);
const _mint = Color(0xFF4DB6AC);

class ManageProfileScreen extends StatefulWidget {
  const ManageProfileScreen({super.key});

  @override
  State<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  final ProfileController _profileController = ProfileController();

  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _matricCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isEditing = false;
  bool _hasFilledControllers = false;

  @override
  void initState() {
    super.initState();
    _profileController.addListener(_onControllerChanged);
    _profileController.loadCurrentUserProfile();
  }

  @override
  void dispose() {
    _profileController.removeListener(_onControllerChanged);
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _matricCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final user = _profileController.currentUserProfile;

    if (user != null && !_hasFilledControllers) {
      _fullNameCtrl.text = user.fullName;
      _emailCtrl.text = user.email;
      _matricCtrl.text = user.matricNumber;
      _phoneCtrl.text = user.phoneNumber;
      _hasFilledControllers = true;
    }

    if (mounted) setState(() {});
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Gets the first letter from the user's full name.
  /// Example:
  /// Ahmad bin Abdullah -> A
  /// KTR Admin -> K
  String _initialFromName(String fullName) {
    final trimmed = fullName.trim();

    if (trimmed.isEmpty) return '?';

    return trimmed[0].toUpperCase();
  }

  bool _isAdmin(UserModel user) {
    return user.role == UserRole.admin;
  }

  Color _roleColor(String role) {
    switch (role) {
      case UserRole.student:
        return _mint;
      case UserRole.organizerHead:
        return const Color(0xFFF5A623);
      case UserRole.secretary:
        return const Color(0xFF7C4DFF);
      case UserRole.admin:
        return _red;
      default:
        return _mint;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case UserRole.student:
        return Icons.school_rounded;
      case UserRole.organizerHead:
        return Icons.groups_rounded;
      case UserRole.secretary:
        return Icons.business_center_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _profileController.currentUserProfile;
    if (user == null) return;

    final success = await _profileController.updateProfile(
      fullName: _fullNameCtrl.text,
      phoneNumber: _isAdmin(user) ? null : _phoneCtrl.text,
      matricNumber: null,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _isEditing = false);
      _showSnackBar('Profile updated successfully.');
    } else {
      _showSnackBar(
        _profileController.errorMessage ?? 'Profile update failed.',
      );
    }
  }

  Future<void> _logout() async {
    await _profileController.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _cancelEditing(UserModel user) {
    setState(() {
      _isEditing = false;
      _fullNameCtrl.text = user.fullName;
      _emailCtrl.text = user.email;
      _matricCtrl.text = user.matricNumber;
      _phoneCtrl.text = user.phoneNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _profileController.currentUserProfile;
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 520 ? 460.0 : screenWidth;

    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: _profileController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: _navy),
                )
              : user == null
                  ? _buildErrorState()
                  : SafeArea(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildHeader(user),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 16, 18, 18),
                              child: Column(
                                children: [
                                  _buildProfileCard(user),
                                  const SizedBox(height: 14),
                                  _buildLogoutButton(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    final roleColor = _roleColor(user.role);

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navyLight, _navy],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTopBar(user),
          const SizedBox(height: 18),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initialFromName(user.fullName),
              style: const TextStyle(
                color: _navy,
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_roleIcon(user.role), color: roleColor, size: 15),
                const SizedBox(width: 6),
                Text(
                  user.role,
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(UserModel user) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'My Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        _circleIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            _showSnackBar('Notifications will be added later.');
          },
        ),
        const SizedBox(width: 10),
        _circleIconButton(
          icon: _isEditing ? Icons.close_rounded : Icons.edit_rounded,
          onTap: () {
            if (_isEditing) {
              _cancelEditing(user);
            } else {
              setState(() => _isEditing = true);
            }
          },
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 39,
        height: 39,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildProfileCard(UserModel user) {
    final isAdmin = _isAdmin(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 16),

            _buildProfileField(
              label: 'Full Name',
              controller: _fullNameCtrl,
              icon: Icons.person_rounded,
              iconColor: _navy,
              enabled: _isEditing,
              validator: _required,
            ),
            const SizedBox(height: 12),

            _buildProfileField(
              label: 'Email Address',
              controller: _emailCtrl,
              icon: Icons.email_rounded,
              iconColor: _red,
              enabled: false,
            ),

            if (!isAdmin) ...[
              const SizedBox(height: 12),
              _buildProfileField(
                label: 'Matric Number',
                controller: _matricCtrl,
                icon: Icons.tag_rounded,
                iconColor: _mint,
                enabled: false,
              ),
              const SizedBox(height: 12),
              _buildProfileField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                icon: Icons.phone_rounded,
                iconColor: const Color(0xFFF5A623),
                enabled: _isEditing,
                validator: _required,
                keyboardType: TextInputType.phone,
              ),
            ],

            if (user.organizationType != null &&
                user.organizationType!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildReadOnlyInfoTile(
                label: 'Organization Type',
                value: user.organizationType!,
                icon: Icons.apartment_rounded,
                iconColor: const Color(0xFF7C4DFF),
              ),
            ],

            if (user.organizationName != null &&
                user.organizationName!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildReadOnlyInfoTile(
                label: 'Organization Name',
                value: user.organizationName!,
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFFF5A623),
              ),
            ],

            if (_isEditing) ...[
              const SizedBox(height: 18),
              _buildEditingButtons(user),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'PERSONAL INFORMATION',
            style: TextStyle(
              color: _navy,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            _isEditing ? 'Editing' : 'Read only',
            key: ValueKey(_isEditing),
            style: TextStyle(
              color: _isEditing ? _red : Colors.grey.shade500,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required bool enabled,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF8F9FC),
        prefixIcon: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        disabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(color: _navy, width: 1.4),
        errorBorder: _inputBorder(color: _red, width: 1.4),
        focusedErrorBorder: _inputBorder(color: _red, width: 1.4),
      ),
    );
  }

  Widget _buildReadOnlyInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder({Color? color, double width = 0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: color == null
          ? BorderSide(color: Colors.grey.shade100, width: 1)
          : BorderSide(color: color, width: width),
    );
  }

  Widget _buildEditingButtons(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed:
                  _profileController.isSaving ? null : () => _cancelEditing(user),
              style: OutlinedButton.styleFrom(
                foregroundColor: _navy,
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade200),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _profileController.isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _red.withOpacity(0.7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _profileController.isSaving
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _red,
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade100),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
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
              color: _red,
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              _profileController.errorMessage ?? 'Could not load profile.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _profileController.loadCurrentUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}