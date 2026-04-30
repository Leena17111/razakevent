import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const RazakEventApp());
}

class RazakEventApp extends StatelessWidget {
  const RazakEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RazakEvent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text(
            'RazakEvent Sprint 1',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}