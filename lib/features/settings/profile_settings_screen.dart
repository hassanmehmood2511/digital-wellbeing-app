import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({required this.controller, super.key});

  final SettingsController controller;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.controller.fullName);
    _emailController = TextEditingController(text: widget.controller.email);
    _phoneController = TextEditingController(text: widget.controller.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Profile settings',
      children: [
        const _ProfileIntro(),
        const SizedBox(height: BehtarSpacing.lg),
        SettingsCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileField(
                  label: 'Full name',
                  controller: _nameController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: BehtarSpacing.base),
                _ProfileField(
                  label: 'Sign-up email',
                  controller: _emailController,
                  readOnly: true,
                  helperText: 'Your sign-up email cannot be changed.',
                ),
                const SizedBox(height: BehtarSpacing.base),
                _ProfileField(
                  label: 'Phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: BehtarSpacing.lg),
        SettingsSaveButton(isSaving: _isSaving, onPressed: _saveProfile),
        const SizedBox(height: BehtarSpacing.sm),
        Center(
          child: Text(
            'Your details stay on this device in this demo.',
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await widget.controller.saveMockChanges();
    if (!mounted) return;
    widget.controller.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    setState(() => _isSaving = false);
    showSettingsMessage(context, 'Profile saved on this device.');
  }
}

class _ProfileIntro extends StatelessWidget {
  const _ProfileIntro();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Keep your details up to date.',
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: BehtarColors.secondaryText),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.helperText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: BehtarSpacing.sm),
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          decoration: InputDecoration(helperText: helperText),
          textCapitalization: keyboardType == TextInputType.emailAddress
              ? TextCapitalization.none
              : TextCapitalization.words,
        ),
      ],
    );
  }
}
