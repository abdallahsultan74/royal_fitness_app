import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../challenges/domain/challenge_progress.dart';
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

    load();
    controller.onCancel = () {
      _client.removeChannel(channel);
    };
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
        ),
      );
    }

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

    load();
    controller.onCancel = () {
      _client.removeChannel(channel);
    };
    return controller.stream;
  }
}
