import '../../../workout/domain/daily_stat.dart';

/// Daily ring goals (aligned with common activity targets).
abstract final class HomeActivityGoals {
  static const int dailyCalorieGoal = 2000;
  static const int dailyMinutesGoal = 60;
  static const int dailyStepsGoal = 10000;

  /// Prefer stored steps; otherwise rough estimate from active minutes until health sync exists.
  static int effectiveSteps(DailyStat s) {
    if (s.steps > 0) return s.steps;
    return (s.totalMinutes * 100).clamp(0, 25000);
  }

  static double ringCalories(DailyStat s) =>
      (s.totalCalories / dailyCalorieGoal).clamp(0.0, 1.0);

  static double ringMinutes(DailyStat s) =>
      (s.totalMinutes / dailyMinutesGoal).clamp(0.0, 1.0);

  static double ringSteps(DailyStat s) =>
      (effectiveSteps(s) / dailyStepsGoal).clamp(0.0, 1.0);

  /// Average of the three ring progresses (0–1).
  static double overallProgress(DailyStat s) =>
      (ringCalories(s) + ringMinutes(s) + ringSteps(s)) / 3.0;
}
