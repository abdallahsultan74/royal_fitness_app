import 'package:easy_localization/easy_localization.dart';

import '../../workout/presentation/models/local_exercise_item.dart';
import 'my_plan_repository.dart';

/// Expected shape of [MyActivePlan.jsonPlan] for "Today's plan" rows on Home.
///
/// ```json
/// {
///   "slots": [
///     {
///       "title_key": "home_plan_stretch",
///       "time": "7:00 AM",
///       "done": true,
///       "description": "Optional notes for the slot.",
///       "description_ar": "ملاحظات بالعربية"
///     },
///     {
///       "title": "Custom block",
///       "title_ar": "كتلة مخصصة",
///       "time": "10:00",
///       "done": false
///     }
///   ]
/// }
/// ```
///
/// Supported array keys (first match wins): `slots`, `todays_plan`, `days`, `items`.
/// [title_key] is passed to easy_localization `.tr()` when present.
class HomeTodayPlanSlot {
  const HomeTodayPlanSlot({
    this.titleKey,
    this.title = '',
    this.titleAr = '',
    required this.timeLabel,
    this.description = '',
    this.descriptionAr = '',
    required this.done,
    this.exercises = const [],
  });

  final String? titleKey;
  final String title;
  final String titleAr;
  final String timeLabel;
  final String description;
  final String descriptionAr;
  final bool done;
  final List<LocalExerciseItem> exercises;

  String displayTitle(String languageCode) {
    final key = titleKey;
    if (key != null && key.trim().isNotEmpty) {
      return key.tr();
    }
    if (languageCode == 'ar' && titleAr.trim().isNotEmpty) return titleAr.trim();
    if (title.trim().isNotEmpty) return title.trim();
    return 'home_plan_slot_placeholder_title'.tr();
  }

  String displayDescription(String languageCode) {
    if (languageCode == 'ar' && descriptionAr.trim().isNotEmpty) {
      return descriptionAr.trim();
    }
    return description.trim();
  }
}

List<HomeTodayPlanSlot> parseHomePlanSlotsFromJson(Map<String, dynamic> jsonPlan) {
  final out = <HomeTodayPlanSlot>[];
  final root = jsonPlan['slots'] ??
      jsonPlan['todays_plan'] ??
      jsonPlan['days'] ??
      jsonPlan['items'];
  if (root is! List) return out;

  for (final raw in root) {
    if (raw is! Map) continue;
    final m = Map<String, dynamic>.from(raw);
    final titleKey = m['title_key']?.toString().trim();
    final title = m['title']?.toString() ?? '';
    final titleAr = m['title_ar']?.toString() ?? '';
    final time =
        m['time']?.toString() ?? m['time_label']?.toString() ?? m['at']?.toString() ?? '';
    final desc = m['description']?.toString() ?? m['notes']?.toString() ?? '';
    final descAr = m['description_ar']?.toString() ?? m['notes_ar']?.toString() ?? '';
    final done = m['done'] == true || m['completed'] == true;
    final exercises = _parseExercises(m['exercises']);

    out.add(
      HomeTodayPlanSlot(
        titleKey: (titleKey == null || titleKey.isEmpty) ? null : titleKey,
        title: title,
        titleAr: titleAr,
        timeLabel: time,
        description: desc,
        descriptionAr: descAr,
        done: done,
        exercises: exercises,
      ),
    );
  }
  return out;
}

List<String> _instructionLinesFromJson(dynamic raw) {
  if (raw == null) return const [];
  if (raw is String) {
    final t = raw.trim();
    return t.isEmpty ? const [] : <String>[t];
  }
  if (raw is List) {
    return raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList(growable: false);
  }
  return const [];
}

List<LocalExerciseItem> _parseExercises(dynamic raw) {
  if (raw is! List) return const [];
  final list = <LocalExerciseItem>[];
  var i = 0;
  for (final e in raw) {
    if (e is! Map) continue;
    final m = Map<String, dynamic>.from(e);
    final name = m['name']?.toString() ?? 'Exercise';
    final nameAr = m['name_ar']?.toString() ?? name;
    final minutes = (m['minutes'] as num? ?? 5).toInt().clamp(1, 120);
    final cal = (m['calories'] as num? ?? minutes * 8).toInt();
    final mediaType = (m['media_type']?.toString() ?? m['mediaType']?.toString() ?? 'image')
        .toLowerCase();
    final safeMedia = mediaType == 'video' ? 'video' : 'image';
    final imageUrl = m['image_url']?.toString() ??
        m['gif']?.toString() ??
        m['media_url']?.toString() ??
        m['image_asset']?.toString() ??
        'assets/exercisedb_v1_sample/gifs_360x360/05Cf2v8.gif';
    final instructions = _instructionLinesFromJson(m['instructions']);
    list.add(
      LocalExerciseItem(
        id: m['id']?.toString() ?? 'plan-slot-$i',
        name: name,
        nameAr: nameAr,
        type: (m['type']?.toString() ?? 'home'),
        minutes: minutes,
        cal: cal,
        level: (m['level']?.toString() ?? 'beginner'),
        imageAssetPath: imageUrl,
        exerciseSteps: ((m['steps'] as num?) ?? (m['exercise_steps'] as num?) ?? 1).toInt(),
        rating: (m['rating'] as num? ?? 4.5).toDouble(),
        instructions: instructions,
        mediaType: safeMedia,
        audioUrl: m['audio_url']?.toString(),
        ttsScript: m['tts_script']?.toString(),
        ttsScriptAr: m['tts_script_ar']?.toString(),
      ),
    );
    i++;
  }
  return list;
}

/// Static rows when [jsonPlan] has no parsable slots (matches previous Home UI).
List<HomeTodayPlanSlot> defaultFallbackHomePlanSlots() {
  return const [
    HomeTodayPlanSlot(
      titleKey: 'home_plan_stretch',
      timeLabel: '7:00 AM',
      done: true,
    ),
    HomeTodayPlanSlot(
      titleKey: 'home_plan_hiit',
      timeLabel: '10:00 AM',
      done: true,
    ),
    HomeTodayPlanSlot(
      titleKey: 'home_plan_yoga',
      timeLabel: '6:00 PM',
      done: false,
    ),
  ];
}

List<HomeTodayPlanSlot> homePlanSlotsForUi(MyActivePlan? plan) {
  final parsed = parseHomePlanSlotsFromJson(plan?.jsonPlan ?? const <String, dynamic>{});
  if (parsed.isNotEmpty) return parsed;
  return defaultFallbackHomePlanSlots();
}
