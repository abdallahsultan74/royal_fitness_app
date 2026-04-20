class DailyStat {
  const DailyStat({
    required this.dateKey,
    required this.totalMinutes,
    required this.totalCalories,
    required this.completedExercises,
    required this.sessionCount,
    this.steps = 0,
  });

  final String dateKey;
  final int totalMinutes;
  final int totalCalories;
  final int completedExercises;
  final int sessionCount;
  /// Recorded steps (device sync). When 0, UI may estimate from active minutes.
  final int steps;
}
