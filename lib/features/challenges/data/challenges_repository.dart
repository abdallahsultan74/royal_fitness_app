import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeDayItem {
  const ChallengeDayItem({
    required this.dayNumber,
    required this.title,
    required this.titleAr,
    required this.targetMinutes,
    required this.targetExercises,
    required this.targetCalories,
    required this.notes,
    required this.notesAr,
  });

  final int dayNumber;
  final String title;
  final String titleAr;
  final int targetMinutes;
  final int targetExercises;
  final int targetCalories;
  final String? notes;
  final String? notesAr;
}

class ChallengeDetails {
  const ChallengeDetails({
    required this.challengeId,
    required this.slug,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.level,
    required this.daysCount,
    required this.days,
  });

  final String challengeId;
  final String slug;
  final String title;
  final String titleAr;
  final String? description;
  final String? descriptionAr;
  final String level;
  final int daysCount;
  final List<ChallengeDayItem> days;
}

class ChallengesRepository {
  SupabaseClient get _client => Supabase.instance.client;

  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<ChallengeDetails> fetchChallengeDetails(String challengeId) async {
    final id = challengeId.trim();
    if (!_uuid.hasMatch(id)) {
      throw Exception('INVALID_CHALLENGE_ID');
    }
    final rows = await _client.rpc<List<dynamic>>(
      'api_challenge_details',
      params: <String, dynamic>{'challenge_id': id},
    );
    if (rows.isEmpty) {
      throw Exception('CHALLENGE_NOT_FOUND');
    }
    final list = rows.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(growable: false);
    final first = list.first;
    final days = list
        .where((r) => r['day_number'] != null)
        .map((r) => ChallengeDayItem(
              dayNumber: (r['day_number'] as num? ?? 0).toInt(),
              title: (r['day_title'] ?? '').toString(),
              titleAr: (r['day_title_ar'] ?? '').toString(),
              targetMinutes: (r['target_minutes'] as num? ?? 0).toInt(),
              targetExercises: (r['target_exercises'] as num? ?? 0).toInt(),
              targetCalories: (r['target_calories'] as num? ?? 0).toInt(),
              notes: r['notes']?.toString(),
              notesAr: r['notes_ar']?.toString(),
            ))
        .toList(growable: false);

    return ChallengeDetails(
      challengeId: (first['challenge_id'] ?? '').toString(),
      slug: (first['slug'] ?? '').toString(),
      title: (first['title'] ?? '').toString(),
      titleAr: (first['title_ar'] ?? '').toString(),
      description: first['description']?.toString(),
      descriptionAr: first['description_ar']?.toString(),
      level: (first['level'] ?? 'beginner').toString(),
      daysCount: (first['days_count'] as num? ?? days.length).toInt(),
      days: days,
    );
  }
}

