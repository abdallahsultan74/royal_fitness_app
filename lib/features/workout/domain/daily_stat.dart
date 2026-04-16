class DailyStat {
  const DailyStat({
    required this.dateKey,
    required this.totalMinutes,
    required this.totalCalories,
    required this.completedExercises,
    required this.sessionCount,
  });

  final String dateKey;
  final int totalMinutes;
  final int totalCalories;
  final int completedExercises;
  final int sessionCount;
}
