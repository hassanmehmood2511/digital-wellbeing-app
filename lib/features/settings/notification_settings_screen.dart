import 'package:flutter/material.dart';

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

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final settings = widget.controller;
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
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
            SettingsCard(
              padding: EdgeInsets.zero,
              child: _NotificationSwitch(
                title: 'Notifications',
                subtitle: 'Allow Behtar reminders on this device',
                value: settings.notificationsEnabled,
                onChanged: (value) =>
                    settings.updateNotifications(enabled: value),
                prominent: true,
              ),
            ),
            if (!settings.notificationsEnabled) ...[
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
                    subtitle: 'A nudge for the habits you planned',
                    value: settings.habitRemindersEnabled,
                    onChanged: settings.notificationsEnabled
                        ? (value) => settings.updateNotifications(
                            habitReminders: value,
                          )
                        : null,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: BehtarSpacing.base,
                    ),
                    child: Divider(height: 1),
                  ),
                  _NotificationSwitch(
                    title: 'Daily check-in',
                    subtitle: 'Pause and reflect on your day',
                    value: settings.dailyCheckInEnabled,
                    onChanged: settings.notificationsEnabled
                        ? (value) =>
                              settings.updateNotifications(dailyCheckIn: value)
                        : null,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: BehtarSpacing.base,
                    ),
                    child: Divider(height: 1),
                  ),
                  _NotificationSwitch(
                    title: 'Wellbeing tips',
                    subtitle: 'Occasional ideas for a healthier balance',
                    value: settings.wellbeingTipsEnabled,
                    onChanged: settings.notificationsEnabled
                        ? (value) =>
                              settings.updateNotifications(wellbeingTips: value)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: BehtarSpacing.lg),
            SettingsSaveButton(
              isSaving: _isSaving,
              onPressed: _saveNotifications,
            ),
            const SizedBox(height: BehtarSpacing.sm),
            Center(
              child: Text(
                'Preferences are stored locally. No notification service is used.',
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
    await widget.controller.saveMockChanges();
    if (!mounted) return;
    setState(() => _isSaving = false);
    showSettingsMessage(context, 'Notification preferences saved.');
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
      activeThumbColor: BehtarColors.surface,
      activeTrackColor: BehtarColors.primary,
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
