import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/exercise_entity.dart';

part 'exercise_model.g.dart';

@JsonSerializable()
class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.target,
    required this.equipment,
    required this.gifUrl,
    this.secondaryMuscles = const [],
    this.instructions = const [],
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  final String id;
  final String name;
  final String bodyPart;
  final String target;
  final String equipment;
  final String gifUrl;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);

  ExerciseEntity toEntity() => ExerciseEntity(
        id: id,
        name: name,
        bodyPart: bodyPart,
        target: target,
        equipment: equipment,
        gifUrl: gifUrl,
        secondaryMuscles: secondaryMuscles,
        instructions: instructions,
      );
}
