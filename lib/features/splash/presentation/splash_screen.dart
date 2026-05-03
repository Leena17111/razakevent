// lib/features/splash/presentation/splash_screen.dart

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../logic/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _loadingController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  final SplashController _splashController = SplashController();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );

    _fadeController.forward();
    _scaleController.forward();
    _loadingController.repeat();

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final route = await _splashController.getInitialRoute();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.primary,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 80,
              left: 32,
              child: AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -20 * _loadingController.value),
                    child: const Opacity(
                      opacity: 0.2,
                      child: Icon(
                        Icons.groups,
                        size: 60,
                        color: AppColors.accent,
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              bottom: 130,
              right: 48,
              child: AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 15 * _loadingController.value),
                    child: const Opacity(
                      opacity: 0.2,
                      child: Icon(
                        Icons.celebration,
                        size: 50,
                        color: AppColors.accent,
                      ),
                    ),
                  );
                },
              ),
            ),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.surface,
                                  AppColors.surfaceSoft,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowDark,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.accent.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'R',
                                    style: AppTextStyles.heading.copyWith(
                                      fontSize: 50,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: -8,
                            right: -8,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.5),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: AppColors.textWhite,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'RazakEvent',
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textWhite,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        height: 6,
                        width: 96,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.accentDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'KTR',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Kolej Tun Razak',
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textWhite.withOpacity(0.8),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Universiti Teknologi Malaysia',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          color: AppColors.textWhite.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final delay = index * 0.2;
                      final animValue =
                          (_loadingController.value - delay).clamp(0.0, 1.0);

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.textWhite.withOpacity(
                            0.4 + 0.6 * animValue,
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}