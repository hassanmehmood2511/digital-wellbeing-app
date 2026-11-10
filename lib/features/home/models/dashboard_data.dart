/// Numbers shown on the Home dashboard, built from the user's live data.
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
}
