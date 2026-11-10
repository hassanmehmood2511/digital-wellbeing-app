import 'package:digital_wellbeing_app/features/groups/group.dart';
import 'package:digital_wellbeing_app/features/groups/groups_controller.dart';
import 'package:digital_wellbeing_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Without a Supabase connection the controller works in memory; invite codes
// are checked on the server, so unknown codes report "not found" here.
void main() {
  group('GroupsController', () {
    late GroupsController controller;
    final now = DateTime(2026, 10, 9);

    setUp(() {
      controller = GroupsController(clock: () => now);
    });

    tearDown(() {
      controller.dispose();
    });

    test('creates a joined group with invite details', () async {
      final created = await controller.createGroup(
        name: 'Morning Walkers',
        description: 'A supportive space for daily walks.',
        visibility: GroupVisibility.private,
        creatorName: 'Sam Lee',
      );

      expect(controller.joinedGroups.first.id, created.id);
      expect(created.isCreator, isTrue);
      expect(created.isJoined, isTrue);
      expect(created.isPrivate, isTrue);
      expect(created.members.single.name, 'Sam Lee');
      expect(created.inviteCode, startsWith('BHT'));
      expect(created.inviteCode, hasLength(9));
      expect(created.inviteExpiresOn, DateTime(2026, 11, 8));
    });

    test('classifies invite codes without a server', () async {
      final created = await controller.createGroup(
        name: 'Readers',
        description: 'Reading a little every day.',
        visibility: GroupVisibility.public,
        creatorName: 'Sam',
      );

      expect(
        await controller.joinWithInviteCode('   '),
        GroupInviteResult.invalidCode,
      );
      expect(
        await controller.joinWithInviteCode(created.inviteCode.toLowerCase()),
        GroupInviteResult.alreadyJoined,
      );
      expect(
        await controller.joinWithInviteCode('UNKNOWN1'),
        GroupInviteResult.invalidCode,
      );
    });

    test('rejects invalid group fields', () async {
      await expectLater(
        controller.createGroup(
          name: 'ab',
          description: 'A useful group description.',
          visibility: GroupVisibility.public,
          creatorName: 'Sam',
        ),
        throwsArgumentError,
      );
    });
  });

  testWidgets('group creation and invite errors work', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BehtarApp(skipStartupFlow: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Challenges'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Groups and leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Find your people'), findsOneWidget);

    await tester.tap(find.byTooltip('Join a group'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'BADCODE');
    await tester.tap(find.text('Join group'));
    await tester.pumpAndSettle();
    expect(
      find.text('That invite code was not found. Check it and try again.'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Create group'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Preview group'));
    await tester.tap(find.text('Preview group'));
    await tester.pumpAndSettle();
    expect(find.textContaining('at least 3 characters'), findsOneWidget);
    expect(find.textContaining('at least 8 characters'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Daily Readers');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'A supportive space to read every day.',
    );
    await tester.tap(find.text('Private group'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Preview group'));
    await tester.tap(find.text('Preview group'));
    await tester.pumpAndSettle();
    expect(find.text('Group preview'), findsOneWidget);
    expect(find.text('Daily Readers'), findsNWidgets(2));
    final createButton = find.widgetWithText(FilledButton, 'Create group');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();
    expect(find.text('Group details'), findsOneWidget);
    expect(find.text('Daily Readers'), findsOneWidget);
    expect(find.text('Private group'), findsOneWidget);
    expect(find.byTooltip('Copy invite code'), findsOneWidget);
  });
}
