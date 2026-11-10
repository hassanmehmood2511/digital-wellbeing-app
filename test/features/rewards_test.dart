import 'package:flutter_test/flutter_test.dart';

import 'package:digital_wellbeing_app/features/rewards/rewards_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('awards are idempotent and counted in the balance', () async {
    final store = PointsStore.instance..reset();

    final firstAward = await store.award(
      id: 'habit:morning-walk:2026-11-10',
      activityName: 'Morning walk',
      points: RewardConfig.habitCompletionPoints,
      type: RewardType.habit,
    );
    final duplicateAward = await store.award(
      id: 'habit:morning-walk:2026-11-10',
      activityName: 'Morning walk',
      points: RewardConfig.habitCompletionPoints,
      type: RewardType.habit,
    );

    expect(firstAward, RewardConfig.habitCompletionPoints);
    expect(duplicateAward, 0);
    expect(store.balance, RewardConfig.habitCompletionPoints);
    expect(store.lifetimeEarned, RewardConfig.habitCompletionPoints);
    expect(store.earnedToday, RewardConfig.habitCompletionPoints);
    expect(store.transactions, hasLength(1));
    expect(store.transactions.single.activityName, 'Morning walk');
  });
}
