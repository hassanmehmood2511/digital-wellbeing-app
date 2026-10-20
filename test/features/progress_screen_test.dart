import 'package:digital_wellbeing_app/core/theme/app_theme.dart';
import 'package:digital_wellbeing_app/features/rewards/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows zero balance and empty history gracefully', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ProgressScreen()),
    );

    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('Your story starts here'), findsOneWidget);

    await tester.ensureVisible(find.text('See all'));
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();

    expect(find.text('Points history'), findsOneWidget);
    expect(find.text('Your story starts here'), findsOneWidget);
  });
}
