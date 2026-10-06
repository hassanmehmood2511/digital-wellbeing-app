import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/habit_store.dart';
import '../../models/habit_model.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController(text: '1');

  String _selectedCategory = 'Health';
  String _selectedFrequency = 'Daily';
  String _selectedIcon = '🌱';

  final List<String> _categories = [
    'Health',
    'Study',
    'Learning',
    'Fitness',
    'Mindfulness',
    'Other',
  ];

  final List<String> _frequencies = ['Daily', 'Weekly', 'Weekdays', 'Weekends'];

  final List<String> _icons = ['🌱', '📚', '🏃', '🌙', '📖', '🧘', '💧', '🎯'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _createHabit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final target = int.tryParse(_targetController.text.trim());

    if (target == null || target < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target.')),
      );
      return;
    }

    final habit = HabitModel(
      habitId: 'habit_${DateTime.now().millisecondsSinceEpoch}',
      ownerUid: 'user_001',
      title: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      frequency: _selectedFrequency,
      targetCount: target,
      completedCount: 0,
      currentStreak: 0,
      icon: _selectedIcon,
    );

    HabitStore.instance.addHabit(habit);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit created successfully!')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(
          'Create Habit',
          style: AppTextStyles.h2.copyWith(color: AppColors.text),
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit icon
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _selectedIcon,
                    style: const TextStyle(fontSize: 38),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'Habit name',
                style: AppTextStyles.label.copyWith(color: AppColors.text),
              ),

              const SizedBox(height: AppSpacing.sm),

              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'e.g. Read for 20 minutes',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.muted,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name.';
                  }

                  if (value.trim().length < 2) {
                    return 'Habit name is too short.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'Description',
                style: AppTextStyles.label.copyWith(color: AppColors.text),
              ),

              const SizedBox(height: AppSpacing.sm),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe your habit',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.muted,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'Category',
                style: AppTextStyles.label.copyWith(color: AppColors.text),
              ),

              const SizedBox(height: AppSpacing.sm),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration(),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'Frequency',
                style: AppTextStyles.label.copyWith(color: AppColors.text),
              ),

              const SizedBox(height: AppSpacing.sm),

              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: _inputDecoration(),
                items: _frequencies.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedFrequency = value;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'Daily target',
                style: AppTextStyles.label.copyWith(color: AppColors.text),
              ),

              const SizedBox(height: AppSpacing.sm),

              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(hintText: 'e.g. 1'),
                validator: (value) {
                  final target = int.tryParse(value?.trim() ?? '');

                  if (target == null || target < 1) {
                    return 'Target must be at least 1.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'Choose an icon',
                style: AppTextStyles.label.copyWith(color: AppColors.text),
              ),

              const SizedBox(height: AppSpacing.sm),

              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _icons.map((icon) {
                  final isSelected = icon == _selectedIcon;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primarySoft
                            : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 23)),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _createHabit,
                  child: const Text('Create Habit'),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
