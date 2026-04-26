class LocalExerciseItem {
  const LocalExerciseItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.type,
    required this.minutes,
    required this.cal,
    required this.level,
    required this.imageAssetPath,
    required this.exerciseSteps,
    required this.rating,
    this.instructions = const <String>[],
    this.mediaType = 'image',
    this.thumbnailUrl,
    this.audioUrl,
    this.ttsScript,
    this.ttsScriptAr,
  });

  final String id;
  final String name;
  final String nameAr;
  final String type; // all | home | gym
  final int minutes;
  final int cal;
  final String level;
  final String imageAssetPath;
  final int exerciseSteps;
  final double rating;
  final List<String> instructions;
  final String mediaType; // image | video
  final String? thumbnailUrl;
  final String? audioUrl;
  final String? ttsScript;
  final String? ttsScriptAr;

  int get durationSec => (minutes * 60).clamp(20, 300);

  String displayName(String languageCode) =>
      languageCode == 'ar' ? nameAr : name;
}
