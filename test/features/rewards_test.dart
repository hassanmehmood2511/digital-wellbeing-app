import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:digital_wellbeing_app/features/rewards/rewards_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('awards are idempotent and saved to local history', () async {
    SharedPreferences.setMockInitialValues({});
    final store = PointsStore.instance;
    await store.initialize();

    final firstAward = await store.award(
      id: 'habit:morning-walk',
      activityName: 'Morning walk',
      points: RewardConfig.habitCompletionPoints,
      type: RewardType.habit,
    );
    final duplicateAward = await store.award(
      id: 'habit:morning-walk',
      activityName: 'Morning walk',
      points: RewardConfig.habitCompletionPoints,
      type: RewardType.habit,
    );

    final preferences = await SharedPreferences.getInstance();
    final savedHistory =
        jsonDecode(preferences.getString('behtar.reward_transactions.v1')!)
            as List<dynamic>;
    expect(firstAward, RewardConfig.habitCompletionPoints);
    expect(duplicateAward, 0);
    expect(store.balance, RewardConfig.habitCompletionPoints);
    expect(store.lifetimeEarned, RewardConfig.habitCompletionPoints);
    expect(store.transactions, hasLength(1));
    expect(savedHistory, hasLength(1));
    expect(savedHistory.single['activityName'], 'Morning walk');
  });
}
