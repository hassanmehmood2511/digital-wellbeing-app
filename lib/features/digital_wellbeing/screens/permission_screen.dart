import 'package:flutter/material.dart';
import 'package:digital_wellbeing_app/core/theme/app_colors.dart';
import 'package:digital_wellbeing_app/core/theme/app_typography.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Permissions'), backgroundColor: AppColors.background, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
              child: const Icon(Icons.lock_clock, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 24),
            const Text('Enable App Usage Access', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            const Text('To show you your screen time and help you track distracting apps, we need permission to see your app usage. Your data is private and stays on your device.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Android Settings... (Mock)'), backgroundColor: AppColors.primary));
                },
                child: const Text('Grant Permission'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: () { Navigator.pop(context); }, child: const Text('Maybe Later', style: TextStyle(color: AppColors.textSecondary, fontSize: 16))),
          ],
        ),
      ),
    );
  }
}