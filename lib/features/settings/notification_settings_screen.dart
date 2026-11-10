import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/backend/backend.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({required this.controller, super.key});

  final SettingsController controller;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  bool _isSaving = false;

  /// Whether Android lets Behtar post notifications (null = checking).
  bool? _systemAllowed;

  static const MethodChannel _deviceChannel = MethodChannel(
    'behtar/usage_stats',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSystemPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from Android settings: re-check.
    if (state == AppLifecycleState.resumed) _checkSystemPermission();
  }

  Future<void> _checkSystemPermission() async {
    if (!NotificationService.isSupported) return;
    final allowed = await NotificationService.areEnabled();
    if (mounted) setState(() => _systemAllowed = allowed);
  }

  Future<void> _allowNotifications() async {
    final granted = await NotificationService.requestPermission();
    if (granted) {
      await _checkSystemPermission();
      return;
    }
    // Android won't show the popup again once denied: open app settings.
    try {
      await _deviceChannel.invokeMethod<void>('openNotificationSettings');
    } catch (_) {
      if (mounted) {
        showSettingsMessage(
          context,
          'Open Android Settings › Apps › Behtar › Notifications to allow them.',
        );
      }
    }
  }

  Future<void> _pickTime({required bool habit}) async {
    final settings = widget.controller;
    final picked = await showTimePicker(
      context: context,
      initialTime: habit ? settings.habitReminderTime : settings.checkInTime,
      helpText: habit ? 'Habit reminder time' : 'Daily check-in time',
    );
    if (picked == null) return;
    settings.updateReminderTimes(
      habitReminder: habit ? picked : null,
      checkIn: habit ? null : picked,
    );
  }

  Future<void> _sendTest() async {
    if (_systemAllowed == false) {
      await _allowNotifications();
      return;
    }
    await NotificationService.showTest();
    if (mounted) {
      showSettingsMessage(context, 'Test notification sent.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.controller;
    final supported = NotificationService.isSupported;
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final on = settings.notificationsEnabled;
        return SettingsPage(
          title: 'Notifications',
          children: [
            Text(
              'Choose the gentle nudges that support your routine.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: BehtarColors.secondaryText,
              ),
            ),
            const SizedBox(height: BehtarSpacing.lg),
            if (!supported) ...[
              const _InfoCard(
                icon: Icons.phone_android_rounded,
                title: 'Reminders arrive on your phone',
                message:
                    'Notifications are sent by the Behtar Android app. The '
                    'choices you save here apply there too.',
              ),
              const SizedBox(height: BehtarSpacing.md),
            ] else if (on && _systemAllowed == false) ...[
              _InfoCard(
                icon: Icons.notifications_off_outlined,
                title: 'Notifications are blocked on this phone',
                message:
                    'Allow notifications so Behtar can send the reminders '
                    'you choose below.',
                action: FilledButton(
                  onPressed: _allowNotifications,
                  child: const Text('Allow notifications'),
                ),
              ),
              const SizedBox(height: BehtarSpacing.md),
            ],
            SettingsCard(
              padding: EdgeInsets.zero,
              child: _NotificationSwitch(
                title: 'Notifications',
                subtitle: 'Allow Behtar reminders on this device',
                value: on,
                onChanged: (value) async {
                  settings.updateNotifications(enabled: value);
                  if (value && supported && _systemAllowed != true) {
                    await _allowNotifications();
                  }
                },
                prominent: true,
              ),
            ),
            if (!on) ...[
              const SizedBox(height: BehtarSpacing.md),
              const _QuietStateCard(),
            ],
            const SizedBox(height: BehtarSpacing.xl),
            const SettingsSectionTitle('Reminder categories'),
            SettingsCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _NotificationSwitch(
                    title: 'Habit reminders',
                    subtitle:
                        'An evening nudge if habits are left (skipped on days '
                        'you finish them all)',
                    value: settings.habitRemindersEnabled,
                    onChanged: on
                        ? (value) => settings.updateNotifications(
                            habitReminders: value,
                          )
                        : null,
                  ),
                  if (on && settings.habitRemindersEnabled)
                    _TimeTile(
                      label: 'Reminder time',
                      time: settings.habitReminderTime,
                      onTap: () => _pickTime(habit: true),
                    ),
                  const _Divider(),
                  _NotificationSwitch(
                    title: 'Daily check-in',
                    subtitle: 'A morning moment to plan your day',
                    value: settings.dailyCheckInEnabled,
                    onChanged: on
                        ? (value) =>
                              settings.updateNotifications(dailyCheckIn: value)
                        : null,
                  ),
                  if (on && settings.dailyCheckInEnabled)
                    _TimeTile(
                      label: 'Check-in time',
                      time: settings.checkInTime,
                      onTap: () => _pickTime(habit: false),
                    ),
                  const _Divider(),
                  _NotificationSwitch(
                    title: 'Wellbeing tips',
                    subtitle: 'One short idea each afternoon',
                    value: settings.wellbeingTipsEnabled,
                    onChanged: on
                        ? (value) =>
                              settings.updateNotifications(wellbeingTips: value)
                        : null,
                  ),
                  const _Divider(),
                  _NotificationSwitch(
                    title: 'Screen time alerts',
                    subtitle:
                        'When an app reaches 80% and 100% of its daily limit',
                    value: settings.gentleRemindersEnabled,
                    onChanged: on
                        ? (value) => settings.updateGentleReminders(value)
                        : null,
                  ),
                ],
              ),
            ),
            if (supported && on) ...[
              const SizedBox(height: BehtarSpacing.md),
              Center(
                child: TextButton.icon(
                  onPressed: _sendTest,
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Send a test notification'),
                ),
              ),
            ],
            const SizedBox(height: BehtarSpacing.lg),
            SettingsSaveButton(
              isSaving: _isSaving,
              onPressed: _saveNotifications,
            ),
            const SizedBox(height: BehtarSpacing.sm),
            Center(
              child: Text(
                'Preferences are saved to your Behtar account. '
                'Reminder times are saved on this device.',
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNotifications() async {
    setState(() => _isSaving = true);
    try {
      await widget.controller.save();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showSettingsMessage(context, friendlyErrorMessage(error));
      return;
    }
    if (!mounted) return;
    setState(() => _isSaving = false);
    showSettingsMessage(context, 'Notification preferences saved.');
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: BehtarSpacing.base),
      child: Divider(height: 1),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: BehtarSpacing.base,
        right: BehtarSpacing.base,
      ),
      leading: const Icon(
        Icons.schedule_rounded,
        color: BehtarColors.primary,
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Text(
        time.format(context),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: BehtarColors.primary,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BehtarColors.primary),
          const SizedBox(width: BehtarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: BehtarSpacing.xs),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                if (action != null) ...[
                  const SizedBox(height: BehtarSpacing.md),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.prominent = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: BehtarSpacing.base,
        vertical: BehtarSpacing.xs,
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontSize: prominent ? 16 : null),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: BehtarSpacing.xs),
        child: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _QuietStateCard extends StatelessWidget {
  const _QuietStateCard();

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            color: BehtarColors.secondaryText,
          ),
          const SizedBox(width: BehtarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiet mode is on',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: BehtarSpacing.xs),
                Text(
                  'All reminder categories are paused. Turn notifications '
                  'back on whenever you are ready.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
