import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({required this.controller, super.key});

  final SettingsController controller;

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  static const _languages = ['English', 'اردو (Urdu)'];

  late String _selectedLanguage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.controller.selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Language',
      children: [
        Text(
          'Choose the language you prefer.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: BehtarColors.secondaryText),
        ),
        const SizedBox(height: BehtarSpacing.lg),
        SettingsCard(
          padding: EdgeInsets.zero,
          child: RadioGroup<String>(
            groupValue: _selectedLanguage,
            onChanged: (value) {
              if (value != null && !_isSaving) {
                setState(() => _selectedLanguage = value);
              }
            },
            child: Column(
              children: [
                for (var index = 0; index < _languages.length; index++) ...[
                  RadioListTile<String>(
                    value: _languages[index],
                    enabled: !_isSaving,
                    activeColor: BehtarColors.primary,
                    title: Text(
                      _languages[index],
                      style: Theme.of(context).textTheme.titleMedium,
                      textDirection: index == 1 ? TextDirection.rtl : null,
                    ),
                    subtitle: Text(index == 0 ? 'English' : 'Urdu'),
                  ),
                  if (index < _languages.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: BehtarSpacing.base,
                      ),
                      child: Divider(height: 1),
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: BehtarSpacing.lg),
        SettingsSaveButton(isSaving: _isSaving, onPressed: _saveLanguage),
        const SizedBox(height: BehtarSpacing.sm),
        Center(
          child: Text(
            'Your choice is saved locally for this demo.',
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<void> _saveLanguage() async {
    setState(() => _isSaving = true);
    await widget.controller.saveMockChanges();
    if (!mounted) return;
    widget.controller.updateLanguage(_selectedLanguage);
    setState(() => _isSaving = false);
    showSettingsMessage(context, 'Language preference saved.');
  }
}
