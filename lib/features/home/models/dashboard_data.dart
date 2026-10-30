enum DashboardScenario { firstUse, completedDay, empty, loading, error }

class DashboardData {
  const DashboardData({
    required this.points,
    required this.pointsDelta,
    required this.streak,
    required this.focusLabel,
    required this.screenTimeLabel,
    required this.screenTimeSubtitle,
    required this.challengeName,
    required this.challengeProgress,
    required this.challengeTotal,
    required this.challengeReward,
    required this.completedHabits,
    required this.totalHabits,
  });

  final int points;
  final int pointsDelta;
  final int streak;
  final String focusLabel;
  final String screenTimeLabel;
  final String screenTimeSubtitle;
  final String challengeName;
  final int challengeProgress;
  final int challengeTotal;
  final String challengeReward;
  final int completedHabits;
  final int totalHabits;

  factory DashboardData.forScenario(DashboardScenario scenario) {
    switch (scenario) {
      case DashboardScenario.firstUse:
        return const DashboardData(
          points: 240,
          pointsDelta: 35,
          streak: 6,
          focusLabel: '42 min',
          screenTimeLabel: '2h 18m',
          screenTimeSubtitle: 'Limit: 3h',
          challengeName: '7-Day Calm Scroll Reset',
          challengeProgress: 4,
          challengeTotal: 7,
          challengeReward: 'Premium plant badge',
          completedHabits: 2,
          totalHabits: 4,
        );
      case DashboardScenario.completedDay:
        return const DashboardData(
          points: 520,
          pointsDelta: 80,
          streak: 11,
          focusLabel: '1h 12m',
          screenTimeLabel: '1h 45m',
          screenTimeSubtitle: 'Limit: 3h',
          challengeName: '7-Day Calm Scroll Reset',
          challengeProgress: 7,
          challengeTotal: 7,
          challengeReward: 'Golden habit badge',
          completedHabits: 4,
          totalHabits: 4,
        );
      case DashboardScenario.empty:
        return const DashboardData(
          points: 0,
          pointsDelta: 0,
          streak: 0,
          focusLabel: '0 min',
          screenTimeLabel: 'Not tracked',
          screenTimeSubtitle: 'No limit set yet',
          challengeName: 'Start your first week',
          challengeProgress: 0,
          challengeTotal: 7,
          challengeReward: 'Starter badge',
          completedHabits: 0,
          totalHabits: 0,
        );
      case DashboardScenario.loading:
      case DashboardScenario.error:
        return const DashboardData(
          points: 0,
          pointsDelta: 0,
          streak: 0,
          focusLabel: '—',
          screenTimeLabel: '—',
          screenTimeSubtitle: '—',
          challengeName: 'Loading challenge',
          challengeProgress: 0,
          challengeTotal: 7,
          challengeReward: '—',
          completedHabits: 0,
          totalHabits: 0,
        );
    }
  }
}
