// lib/features/splash/logic/splash_controller.dart

import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/routes/app_routes.dart';

class SplashController {
  Future<String> getInitialRoute() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return AppRoutes.login;
    }

    return AppRoutes.home;
  }
}