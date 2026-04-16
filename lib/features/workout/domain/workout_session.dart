class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.durationSec,
    required this.calories,
    required this.exerciseCount,
    required this.completed,
    required this.dateKey,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSec;
  final int calories;
  final int exerciseCount;
  final bool completed;
  final String dateKey;
}
