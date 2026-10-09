import 'package:digital_wellbeing_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bottom navigation switches between app destinations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BehtarApp());
    await tester.pumpAndSettle();

    expect(find.text('Today’s Progress'), findsOneWidget);
    expect(find.text('Today’s Habits'), findsOneWidget);
    expect(find.text('Points'), findsOneWidget);
    expect(find.text('App Usage'), findsOneWidget);
    expect(find.text('7-Day Challenge'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Habits'));
    await tester.pumpAndSettle();
    expect(find.text('Your habits will appear here.'), findsOneWidget);

    await tester.tap(find.text('Challenges'));
    await tester.pumpAndSettle();
    expect(find.text('Find a challenge to grow together.'), findsOneWidget);

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Your progress will be shown here.'), findsOneWidget);

    await tester.tap(find.text('Apps'));
    await tester.pumpAndSettle();
    expect(
      find.text('Apps you choose to manage with Behtar will appear here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your account'), findsOneWidget);
    expect(find.byTooltip('App settings'), findsOneWidget);
  });
}
