import 'package:digital_wellbeing_app/features/home/models/dashboard_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardData', () {
    test('first-use preview retains its habit and challenge progress', () {
      final data = DashboardData.forScenario(DashboardScenario.firstUse);

      expect(data.completedHabits, 2);
      expect(data.totalHabits, 4);
      expect(data.challengeProgress, 4);
      expect(data.challengeTotal, 7);
    });

    test('completed-day preview marks all habits complete', () {
      final data = DashboardData.forScenario(DashboardScenario.completedDay);

      expect(data.completedHabits, data.totalHabits);
      expect(data.totalHabits, 4);
      expect(data.challengeProgress, data.challengeTotal);
    });

    test('empty, loading, and error previews have no habit progress', () {
      for (final scenario in [
        DashboardScenario.empty,
        DashboardScenario.loading,
        DashboardScenario.error,
      ]) {
        final data = DashboardData.forScenario(scenario);

        expect(data.completedHabits, 0);
        expect(data.totalHabits, 0);
      }
    });
  });
}
