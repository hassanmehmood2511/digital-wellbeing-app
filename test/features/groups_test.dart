import 'package:digital_wellbeing_app/features/groups/group.dart';
import 'package:digital_wellbeing_app/features/groups/groups_controller.dart';
import 'package:digital_wellbeing_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('creates a joined group with local invite details', () {
      final created = controller.createGroup(
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
      expect(created.inviteCode, startsWith('BETHTR'));
    });

    test('classifies invite codes and joins public and private groups', () {
      expect(
        controller.joinWithInviteCode('unknown'),
        GroupInviteResult.invalidCode,
      );
      expect(
        controller.joinWithInviteCode('EXPIRED7'),
        GroupInviteResult.expiredCode,
      );
      expect(
        controller.joinWithInviteCode('DENIED7'),
        GroupInviteResult.accessDenied,
      );
      expect(
        controller.joinWithInviteCode('OPEN42', memberName: 'Sam Lee'),
        GroupInviteResult.joined,
      );
      expect(
        controller.joinWithInviteCode('open42'),
        GroupInviteResult.alreadyJoined,
      );
      expect(
        controller.joinWithInviteCode('INVITE7'),
        GroupInviteResult.joined,
      );

      final privateGroup = controller.groupById('private-invitation')!;
      expect(privateGroup.isPrivate, isTrue);
      expect(privateGroup.isJoined, isTrue);
    });

    test('rejects invalid group fields', () {
      expect(
        () => controller.createGroup(
          name: 'ab',
          description: 'A useful group description.',
          visibility: GroupVisibility.public,
          creatorName: 'Sam',
        ),
        throwsArgumentError,
      );
    });
  });

  testWidgets('groups, invite errors, leaderboard and group creation work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BehtarApp());
    await tester.tap(find.text('Challenges'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Groups and leaderboard'));
    await tester.pumpAndSettle();

    expect(find.text('Mindful Circle'), findsOneWidget);
    expect(find.text('Weekend Walkers'), findsOneWidget);

    await tester.tap(find.text('Mindful Circle'));
    await tester.pumpAndSettle();
    expect(find.text('Group details'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Tied rank'), findsNWidgets(2));
    expect(find.text('Hassan (You)'), findsOneWidget);
    expect(find.text('Private group'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Join a group'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'BADCODE');
    await tester.tap(find.text('Join group'));
    await tester.pumpAndSettle();
    expect(
      find.text('That invite code was not found. Check it and try again.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField), 'EXPIRED7');
    await tester.tap(find.text('Join group'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'This invite code has expired. Ask a group member for a new one.',
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField), 'DENIED7');
    await tester.tap(find.text('Join group'));
    await tester.pumpAndSettle();
    expect(
      find.text('You don’t have access to this group with that invite.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField), 'INVITE7');
    await tester.tap(find.text('Join group'));
    await tester.pumpAndSettle();
    expect(find.text('Quiet Morning Club'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Groups and leaderboard'));
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

  testWidgets('group list and leaderboard remain usable on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BehtarApp());
    await tester.tap(find.text('Challenges'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Groups and leaderboard'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Mindful Circle'));
    await tester.pumpAndSettle();
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
