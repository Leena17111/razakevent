import 'package:flutter/material.dart';
import 'package:razakevent/core/constants/app_colors.dart';
import 'package:razakevent/core/constants/app_text_styles.dart';
import 'package:razakevent/core/widgets/custom_button.dart';
import 'package:razakevent/data/services/auth_service.dart';
import 'package:razakevent/features/auth/presentation/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'RazakEvent',
          style: AppTextStyles.title.copyWith(color: AppColors.textWhite),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textWhite),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 72),
              const SizedBox(height: 16),
              Text('Login Successful!', style: AppTextStyles.title),
              const SizedBox(height: 8),
              Text(user?.email ?? '', style: AppTextStyles.subtitle),
              const SizedBox(height: 32),
              CustomButton(
                  text: 'Logout',
                  onPressed: () async {
                    await authService.logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}