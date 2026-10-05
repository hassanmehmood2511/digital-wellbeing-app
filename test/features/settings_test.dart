import 'package:digital_wellbeing_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('profile changes are saved locally and appear on settings', (
    tester,
  ) async {
    await tester.pumpWidget(const BehtarApp());

    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Profile settings'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Sara Ahmed');
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Profile saved on this device.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Sara Ahmed'), findsOneWidget);
  });

  testWidgets('language selection and notification quiet state work', (
    tester,
  ) async {
    await tester.pumpWidget(const BehtarApp());

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اردو (Urdu)'));
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('اردو (Urdu)'), findsOneWidget);
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Quiet mode is on'), findsOneWidget);
    expect(find.text('All reminder categories are paused.'), findsNothing);
    expect(
      find.textContaining('All reminder categories are paused'),
      findsOneWidget,
    );
  });

  testWidgets('account deletion requires explicit confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(const BehtarApp());

    await tester.ensureVisible(find.text('Account settings'));
    await tester.tap(find.text('Account settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete account'));
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete account?'), findsOneWidget);
    expect(find.text('Keep account'), findsOneWidget);
    await tester.tap(find.text('Keep account'));
    await tester.pumpAndSettle();
    expect(find.text('Account actions'), findsOneWidget);
  });
}
