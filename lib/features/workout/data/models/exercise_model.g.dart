// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseModel _$ExerciseModelFromJson(Map<String, dynamic> json) =>
    ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      bodyPart: json['bodyPart'] as String,
      target: json['target'] as String,
      equipment: json['equipment'] as String,
      gifUrl: json['gifUrl'] as String,
      secondaryMuscles:
          (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      instructions:
          (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ExerciseModelToJson(ExerciseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bodyPart': instance.bodyPart,
      'target': instance.target,
      'equipment': instance.equipment,
      'gifUrl': instance.gifUrl,
      'secondaryMuscles': instance.secondaryMuscles,
      'instructions': instance.instructions,
    };
