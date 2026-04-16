/// Domain entity for a single exercise (ExerciseDB / RapidAPI shape).
class ExerciseEntity {
  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.target,
    required this.equipment,
    required this.gifUrl,
    this.secondaryMuscles = const [],
    this.instructions = const [],
  });

  final String id;
  final String name;
  final String bodyPart;
  final String target;
  final String equipment;
  final String gifUrl;
  final List<String> secondaryMuscles;
  final List<String> instructions;
}
