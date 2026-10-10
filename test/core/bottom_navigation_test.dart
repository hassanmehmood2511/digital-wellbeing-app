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

    expect(find.text('Your day starts with one small step.'), findsOneWidget);
    expect(find.text('Home'), findsNWidgets(2));

    await tester.tap(find.text('Habits'));
    await tester.pumpAndSettle();
    expect(find.text('Your habits will appear here.'), findsOneWidget);

    await tester.tap(find.text('Challenges'));
    await tester.pumpAndSettle();
    expect(find.text('7-day challenges'), findsOneWidget);
    expect(find.text('Mindful mornings'), findsOneWidget);

    await tester.tap(find.byTooltip('Create challenge'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Preview challenge'));
    await tester.tap(find.text('Preview challenge'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a challenge title.'), findsOneWidget);
    expect(find.text('Add a short description.'), findsOneWidget);
    expect(find.text('Choose a habit or goal.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Calmer evenings');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Make room for a restful end to each day.',
    );
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take a screen-free evening').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Preview challenge'));
    await tester.tap(find.text('Preview challenge'));
    await tester.pumpAndSettle();
    expect(find.text('Your challenge preview'), findsOneWidget);

    await tester.ensureVisible(find.text('Save challenge'));
    await tester.tap(find.text('Save challenge'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Calmer evenings'), findsOneWidget);

    await tester.tap(find.byTooltip('Create challenge'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Evening stretches',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Make space to move gently each evening.',
    );
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom / Add your own').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Stretch for 10 minutes',
    );
    await tester.ensureVisible(find.text('Private').first);
    await tester.tap(find.text('Private').first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(TextFormField).at(3));
    await tester.tap(find.byType(TextFormField).at(3));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Preview challenge'));
    await tester.tap(find.text('Preview challenge'));
    await tester.pumpAndSettle();
    expect(find.text('Your challenge preview'), findsOneWidget);
    expect(find.text('Stretch for 10 minutes'), findsNWidgets(2));
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Private'), findsNWidgets(2));
    await tester.ensureVisible(find.text('Save challenge'));
    await tester.tap(find.text('Save challenge'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Evening stretches'), findsOneWidget);
    expect(find.text('Stretch for 10 minutes'), findsOneWidget);
    expect(find.text('Private'), findsOneWidget);

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
