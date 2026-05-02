// lib/features/auth/presentation/register_screen.dart
// Jira AD-11: Design registration screen UI only.
// No Firebase or backend logic connected yet.

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand colour tokens
// ─────────────────────────────────────────────────────────────────────────────
const _navy = Color(0xFF1A237E);
const _red = Color(0xFFC8102E);
const _bg = Color(0xFFF5F6FA);
const _inputBg = Color(0xFFF3F4F6);

// ─────────────────────────────────────────────────────────────────────────────
// Role enum
// ─────────────────────────────────────────────────────────────────────────────
enum UserRole { student, organizerHead, secretary }

extension _RoleMeta on UserRole {
  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.organizerHead:
        return 'Organizer\nHead';
      case UserRole.secretary:
        return 'Secretary';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.student:
        return Icons.school_rounded;
      case UserRole.organizerHead:
        return Icons.supervised_user_circle_rounded;
      case UserRole.secretary:
        return Icons.business_center_rounded;
    }
  }

  Color get accent {
    switch (this) {
      case UserRole.student:
        return const Color(0xFF00BFA5);
      case UserRole.organizerHead:
        return const Color(0xFFF5A623);
      case UserRole.secretary:
        return const Color(0xFF7C4DFF);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RegisterScreen
// ─────────────────────────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole? _selectedRole;

  // Common
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _matricCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // Organizer Head
  String? _orgType;
  final _verificationCtrlOrg = TextEditingController();

  // Secretary
  final _verificationCtrlSec = TextEditingController();

  // Password visibility
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _matricCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _verificationCtrlOrg.dispose();
    _verificationCtrlSec.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 480 ? 440.0 : screenWidth;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(topPad),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: SizedBox(
                  width: cardWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRoleSection(),
                            const SizedBox(height: 20),
                            if (_selectedRole == null)
                              _buildRolePrompt()
                            else ...[
                              Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
                              const SizedBox(height: 20),
                              _buildAllFields(),
                              const SizedBox(height: 28),
                              _buildCreateAccountButton(),
                            ],
                            const SizedBox(height: 20),
                            _buildLoginLink(),
                            const SizedBox(height: 12),
                            _buildFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(double topPad) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF283593), Color(0xFF1A237E)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, topPad + 28, 24, 40),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join RazakEvent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Create your account',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Role selector ─────────────────────────────────────────────────────────
  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I AM A\u2026',
          style: TextStyle(
            color: _navy,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: UserRole.values.map((r) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _buildRoleCard(r),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoleCard(UserRole role) {
    final isSelected = _selectedRole == role;
    final accent = role.accent;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.12) : _inputBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? accent : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(role.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              role.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? _navy : Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolePrompt() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'Select your role to continue',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      ),
    );
  }

  // ── All form fields (role-aware) ──────────────────────────────────────────
  Widget _buildAllFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Full Name',
          ctrl: _fullNameCtrl,
          hint: 'Ahmad bin Abdullah',
          icon: Icons.person_outline,
          validator: _required,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Email Address',
          ctrl: _emailCtrl,
          hint: 'student@graduate.utm.my',
          icon: Icons.email_outlined,
          validator: _required,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Matric Number',
          ctrl: _matricCtrl,
          hint: 'A22EC0123',
          icon: Icons.tag,
          validator: _required,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Phone Number',
          ctrl: _phoneCtrl,
          hint: '+60123456789',
          icon: Icons.phone_outlined,
          validator: _required,
          keyboardType: TextInputType.phone,
        ),

        // ── Organizer Head extras ─────────────────────────────────────────
        if (_selectedRole == UserRole.organizerHead) ...[
          const SizedBox(height: 16),
          _buildOrgTypeSelector(),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Verification Code',
            ctrl: _verificationCtrlOrg,
            hint: 'Enter verification code',
            icon: Icons.vpn_key_outlined,
            validator: _required,
          ),
        ],

        // ── Secretary extras ──────────────────────────────────────────────
        if (_selectedRole == UserRole.secretary) ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Verification Code',
            ctrl: _verificationCtrlSec,
            hint: 'Enter verification code',
            icon: Icons.vpn_key_outlined,
            validator: _required,
          ),
        ],

        const SizedBox(height: 16),
        _buildTextField(
          label: 'Password',
          ctrl: _passwordCtrl,
          hint: 'Create a password',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          validator: _required,
          suffixIcon: _visibilityToggle(
            obscure: _obscurePassword,
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Confirm Password',
          ctrl: _confirmPasswordCtrl,
          hint: 'Confirm password',
          icon: Icons.lock_outline,
          obscureText: _obscureConfirm,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'This field is required';
            // TODO: add password-match check when AuthController is connected
            return null;
          },
          suffixIcon: _visibilityToggle(
            obscure: _obscureConfirm,
            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
      ],
    );
  }

  // ── Org Type selector ─────────────────────────────────────────────────────
  Widget _buildOrgTypeSelector() {
    const options = ['Exco', 'Club'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Organization Type',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: options.map((opt) {
              final isSelected = _orgType == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _orgType = opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isSelected ? _navy : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      opt,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Generic text field ────────────────────────────────────────────────────
  Widget _buildTextField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: _inputBg,
            prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
            suffixIcon: suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(color: _navy, width: 1.5),
            errorBorder: _inputBorder(color: _red, width: 1.5),
            focusedErrorBorder: _inputBorder(color: _red, width: 1.5),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _inputBorder({Color? color, double width = 0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: color == null
          ? BorderSide.none
          : BorderSide(color: color, width: width),
    );
  }

  Widget _visibilityToggle({required bool obscure, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.grey.shade500,
        size: 20,
      ),
      onPressed: onTap,
    );
  }

  // ── Create Account button ─────────────────────────────────────────────────
  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        // TODO: Connect to AuthController.register() when backend is ready.
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ── Login link ────────────────────────────────────────────────────────────
  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          GestureDetector(
            // TODO: Navigate to LoginScreen
            onTap: () {},
            child: const Text(
              'Log In',
              style: TextStyle(
                color: _navy,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Center(
      child: Text(
        'Kolej Tun Razak \u2022 UTM',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
