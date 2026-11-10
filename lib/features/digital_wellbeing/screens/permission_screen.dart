import 'package:flutter/material.dart';
import 'package:digital_wellbeing_app/core/theme/app_colors.dart';
import 'package:digital_wellbeing_app/features/digital_wellbeing/data/app_data.dart';
import 'package:digital_wellbeing_app/features/digital_wellbeing/data/device_usage_service.dart';

/// Explains and manages Android "Usage access" for screen-time tracking.
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  bool? _granted;
  bool _openedSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final granted = await DeviceUsageService.hasPermission();
    if (!mounted) return;
    setState(() => _granted = granted);
    if (granted) {
      await AppData().syncFromDevice();
      if (!mounted || !_openedSettings) return;
      _openedSettings = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screen time tracking is on.')),
      );
    }
  }

  Future<void> _openSettings() async {
    _openedSettings = true;
    await DeviceUsageService.openSettings();
  }

  @override
  Widget build(BuildContext context) {
    final supported = DeviceUsageService.isSupported;
    final granted = _granted == true;

    final String title;
    final String message;
    if (!supported) {
      title = 'Available on Android';
      message =
          'Screen time is recorded by the Behtar app on your Android phone. '
          'Allow usage access there and your usage will sync to your account.';
    } else if (granted) {
      title = 'Screen time tracking is on';
      message =
          'Behtar can see how long you use each app. You can turn this off '
          'any time in Android Settings › Usage access.';
    } else {
      title = 'Enable App Usage Access';
      message =
          'To show your screen time and help you with distracting apps, '
          'Behtar needs usage access. It only reads how long each app is '
          'open — never your messages, photos or anything inside apps. '
          'Your daily totals are saved to your Behtar account.';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Usage access'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  granted ? Icons.verified_rounded : Icons.lock_clock,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              if (supported && !granted) ...[
                const SizedBox(height: 24),
                const _Steps(),
              ],
              const SizedBox(height: 32),
              if (supported)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openSettings,
                    child: Text(
                      granted ? 'Open usage access settings' : 'Grant Permission',
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  granted || !supported ? 'Done' : 'Maybe Later',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Tap “Grant Permission”.',
      'Find Behtar in the list.',
      'Turn on “Permit usage access”, then press back.',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.mint,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
