// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'core/localization/locale_controller.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/documents/presentation/document_details_screen.dart';
import 'features/documents/presentation/document_status_screen.dart';
import 'features/documents/presentation/upload_document_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/profile/presentation/manage_profile_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RazakEventApp());
}

class RazakEventApp extends StatelessWidget {
  const RazakEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'RazakEvent',
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
            ),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.register: (context) => const RegisterScreen(),
            AppRoutes.resetPassword: (context) => const ForgotPasswordScreen(),
            AppRoutes.home: (context) => const HomeScreen(),
            AppRoutes.profile: (context) => const ManageProfileScreen(),
            AppRoutes.uploadEventDocument: (_) => const UploadDocumentScreen(),
            AppRoutes.trackEventDocumentStatus: (_) => const DocumentStatusScreen(),
            AppRoutes.documentDetails: (_) => const DocumentDetailsScreen(),
          },
        );
      },
    );
  }
}