import 'package:flutter/material.dart';
import 'package:razakevent/core/constants/app_colors.dart';
import 'package:razakevent/core/constants/app_text_styles.dart';
import 'package:razakevent/core/utils/validators.dart';
import 'package:razakevent/core/widgets/custom_button.dart';
import 'package:razakevent/core/widgets/custom_text_field.dart';
import 'package:razakevent/data/services/auth_service.dart';
import 'package:razakevent/features/home/presentation/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error,
              style: AppTextStyles.body.copyWith(color: AppColors.textWhite)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Gradient background
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 64, 28, 36),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: AppTextStyles.heading
                            .copyWith(color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to discover campus events',
                        style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.textWhite.withOpacity(0.85)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Decorative calendar icon — partially clipped off right edge
                Positioned(
                  right: -30,
                  top: 10,
                  bottom: 10,
                  child: Center(
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: 180,
                      color: AppColors.textWhite.withOpacity(0.10),
                    ),
                  ),
                ),
              ],
            ),

            // ── Form Card ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.shadowDark,
                        blurRadius: 16,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      CustomTextField(
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        hint: 'student@graduate.utm.my',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 20),

                      // Password
                      CustomTextField(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        hint: 'Enter your password',
                        obscureText: _obscurePassword,
                        validator: Validators.loginPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Forgot Password — blue by default, red on hover
                      Align(
                        alignment: Alignment.centerRight,
                        child: _HoverTextButton(
                          text: 'Forgot Password?',
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Login Button
                      CustomButton(
                        text: 'Login to Continue',
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: AppColors.border)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or',
                                style: AppTextStyles.body
                                    .copyWith(color: AppColors.textMuted)),
                          ),
                          const Expanded(
                              child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Create Account
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                overlayColor: Colors.transparent,
                              ),
                              child: Text(
                                'Create Account',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Kolej Tun Razak · Universiti Teknologi Malaysia',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hover Text Button ────────────────────────────────
class _HoverTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _HoverTextButton({required this.text, required this.onPressed});

  @override
  State<_HoverTextButton> createState() => _HoverTextButtonState();
}

class _HoverTextButtonState extends State<_HoverTextButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          overlayColor: Colors.transparent,
        ),
        child: Text(
          widget.text,
          style: AppTextStyles.label.copyWith(
            color: _hovered ? AppColors.accent : AppColors.primary,
          ),
        ),
      ),
    );
  }
}