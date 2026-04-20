class WorkoutSessionItem {
  const WorkoutSessionItem({
    required this.exerciseName,
    required this.exerciseNameAr,
    required this.minutes,
    required this.calories,
    required this.done,
  });

  final String exerciseName;
  final String exerciseNameAr;
  final int minutes;
  final int calories;
  final bool done;
}

