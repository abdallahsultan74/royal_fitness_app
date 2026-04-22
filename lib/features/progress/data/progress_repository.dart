import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/build_config.dart';
import '../../challenges/domain/challenge_progress.dart';
import '../../plans/data/home_plan_json_slots.dart';
import '../domain/weight_log.dart';

class ProgressRepository {
  ProgressRepository();

  SupabaseClient get _client => Supabase.instance.client;
  String get _uid => _client.auth.currentUser!.id;

  Stream<List<WeightLog>> watchWeightLogs({int limit = 12}) {
    final controller = StreamController<List<WeightLog>>();

    Future<void> load() async {
      final rows = await _client
          .from('weight_logs')
          .select()
          .eq('user_id', _uid)
          .order('logged_at', ascending: false)
          .limit(limit);
      final mapped = rows.map((data) {
        final loggedAt = DateTime.tryParse(data['logged_at']?.toString() ?? '') ??
            DateTime.now();
        return WeightLog(
          id: data['id']?.toString() ?? '',
          loggedAt: loggedAt,
          weightKg: (data['weight_kg'] as num? ?? 0).toDouble(),
          source: data['source']?.toString() ?? 'app',
        );
      }).toList(growable: false);
      controller.add(mapped.reversed.toList(growable: false));
    }

    load();
    if (BuildConfig.realtimeEnabled) {
      late final RealtimeChannel channel;
      channel = _client
          .channel('weight-logs-$_uid')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'weight_logs',
            callback: (_) => load(),
          )
          .subscribe();

      controller.onCancel = () {
        _client.removeChannel(channel);
      };
    } else {
      controller.onCancel = () {};
    }
    return controller.stream;
  }

  Future<void> logWeight(double weightKg, {DateTime? loggedAt}) async {
    final day = (loggedAt ?? DateTime.now()).toUtc();
    final dateKey =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    // `weight_logs` has a unique constraint on (user_id, logged_at).
    // Make sure we upsert on that key to avoid duplicate-key errors.
    await _client.from('weight_logs').upsert(
      <String, dynamic>{
        'user_id': _uid,
        'logged_at': dateKey,
        'weight_kg': weightKg,
        'source': 'app',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,logged_at',
    );
  }

  Future<List<ChallengeTemplate>> fetchChallengeTemplates() async {
    final rows = await _client
        .from('challenge_templates')
        .select()
        .eq('is_active', true)
        .order('level', ascending: true);
    return rows.map((data) {
      return ChallengeTemplate(
        id: data['id']?.toString() ?? '',
        slug: data['slug']?.toString() ?? '',
        title: data['title']?.toString() ?? '',
        titleAr: data['title_ar']?.toString() ?? '',
        description: data['description']?.toString() ?? '',
        descriptionAr: data['description_ar']?.toString() ?? '',
        level: data['level']?.toString() ?? 'beginner',
        daysCount: (data['days_count'] as num? ?? 30).toInt(),
        isActive: data['is_active'] == true,
        coverImageUrl: data['cover_image_url']?.toString(),
      );
    }).toList(growable: false);
  }

  Future<void> startChallenge(String slug) async {
    try {
      await _client.rpc('start_user_challenge', params: <String, dynamic>{
        'challenge_slug': slug,
      });
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Cancels the user's active challenge (same effect as switching challenges server-side).
  Future<void> abandonActiveChallenge() async {
    try {
      await _client
          .from('user_challenges')
          .update(<String, dynamic>{
            'status': 'cancelled',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', _uid)
          .eq('status', 'active');
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Today's row(s) from [user_challenge_days] for the active enrollment (home "Today's plan").
  Future<List<HomeTodayPlanSlot>> fetchTodayChallengePlanSlots(ChallengeProgress active) async {
    final rows = await _client
        .from('user_challenge_days')
        .select()
        .eq('user_challenge_id', active.userChallengeId)
        .eq('day_number', active.currentDay)
        .limit(1);
    if (rows.isEmpty) return const [];
    final m = Map<String, dynamic>.from(rows.first as Map);
    final title = m['title']?.toString() ?? '';
    final titleAr = m['title_ar']?.toString() ?? '';
    final mins = (m['target_minutes'] as num? ?? 0).toInt();
    final ex = (m['target_exercises'] as num? ?? 0).toInt();
    final cal = (m['target_calories'] as num? ?? 0).toInt();
    final done = m['completed'] == true;
    final dayLine = 'challenge_progress_day'.tr(
      args: ['${active.currentDay}', '${active.daysCount}'],
    );
    final desc = 'home_plan_challenge_targets'.tr(
      namedArgs: {
        'exercises': '$ex',
        'calories': '$cal',
        'minutes': '$mins',
      },
    );
    return [
      HomeTodayPlanSlot(
        title: title.isEmpty ? 'home_plan_challenge_day_fallback'.tr() : title,
        titleAr: titleAr,
        timeLabel: dayLine,
        description: desc,
        descriptionAr: desc,
        done: done,
      ),
    ];
  }

  Future<void> completeChallengeDay(int targetDay) async {
    try {
      await _client.rpc('complete_user_challenge_day', params: <String, dynamic>{
        'target_day': targetDay,
      });
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Stream<ChallengeProgress?> watchActiveChallenge() {
    final controller = StreamController<ChallengeProgress?>();

    Future<void> load() async {
      final rows = await _client.rpc<List<dynamic>>('api_my_active_challenge');
      if (rows.isEmpty) {
        controller.add(null);
        return;
      }
      final data = rows.first as Map<String, dynamic>;
      controller.add(
        ChallengeProgress(
          userChallengeId: data['user_challenge_id']?.toString() ?? '',
          challengeId: data['challenge_id']?.toString() ?? '',
          slug: data['slug']?.toString() ?? '',
          title: data['title']?.toString() ?? '',
          titleAr: data['title_ar']?.toString() ?? '',
          level: data['level']?.toString() ?? 'beginner',
          daysCount: (data['days_count'] as num? ?? 30).toInt(),
          currentDay: (data['current_day'] as num? ?? 1).toInt(),
          completedDays: (data['completed_days'] as num? ?? 0).toInt(),
          progressPercent: (data['progress_percent'] as num? ?? 0).toDouble(),
          status: data['status']?.toString() ?? 'active',
          coverImageUrl: data['cover_image_url']?.toString(),
        ),
      );
    }

    load();
    if (BuildConfig.realtimeEnabled) {
      late final RealtimeChannel channel;
      channel = _client
          .channel('active-challenge-$_uid')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'user_challenges',
            callback: (_) => load(),
          )
          .subscribe();

      controller.onCancel = () {
        _client.removeChannel(channel);
      };
    } else {
      controller.onCancel = () {};
    }
    return controller.stream;
  }
}
