import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'register_screen.dart';
import 'features/auth/presentation/register_screen.dart';Future<void> main() async {
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
    return MaterialApp(
      title: 'RazakEvent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          primary: const Color(0xFF1A237E),
        ),
        useMaterial3: true,
      ),
      home: const RegisterScreen(),
    );
  }
}