import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/digital_wellbeing/screens/usage_overview_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Wellbeing App',
      theme: AppTheme.lightTheme,
      home: const UsageOverviewScreen(), // Back to main screen
    );
  }
}