import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/build_config.dart';
import '../domain/daily_stat.dart';
import '../domain/workout_session.dart';
import '../domain/workout_session_item.dart';
import '../presentation/models/local_exercise_item.dart';

class WorkoutRepository {
  WorkoutRepository();
  SupabaseClient get _client => Supabase.instance.client;
  String get _uid => _client.auth.currentUser!.id;

  String dateKey([DateTime? time]) {
    final dt = time ?? DateTime.now();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  Future<String> startSession({required int plannedExerciseCount}) async {
    final now = DateTime.now();
    final response = await _client
        .from('workout_sessions')
        .insert(<String, dynamic>{
      'user_id': _uid,
      'started_at': now.toUtc().toIso8601String(),
      'duration_sec': 0,
      'calories': 0,
      'exercise_count': plannedExerciseCount,
      'completed': false,
      'date_key': dateKey(now),
    })
        .select('id')
        .single();
    return response['id'].toString();
  }

  Future<void> saveSessionItem({
    required String sessionId,
    required LocalExerciseItem exercise,
    required int index,
    required bool done,
  }) {
    return _client.from('workout_session_items').insert(<String, dynamic>{
      'session_id': sessionId,
      'exercise_name': exercise.name,
      'exercise_name_ar': exercise.nameAr,
      'duration_sec': exercise.durationSec,
      'minutes': exercise.minutes,
      'calories': exercise.cal,
      'done': done,
    });
  }

  Future<void> completeSession({
    required String sessionId,
    required int durationSec,
    required int calories,
    required int completedExercises,
  }) async {
    final now = DateTime.now();
    final key = dateKey(now);
    await _client.from('workout_sessions').update(<String, dynamic>{
      'ended_at': now.toUtc().toIso8601String(),
      'duration_sec': durationSec,
      'calories': calories,
      'exercise_count': completedExercises,
      'completed': true,
      'date_key': key,
    }).eq('id', sessionId);

    final dailyRows = await _client
        .from('daily_stats')
        .select()
        .eq('user_id', _uid)
        .eq('date_key', key);
    final prev = dailyRows.isNotEmpty ? dailyRows.first : <String, dynamic>{};

    await _client.from('daily_stats').upsert(<String, dynamic>{
      'user_id': _uid,
      'date_key': key,
      'total_minutes': (prev['total_minutes'] as num? ?? 0) + (durationSec ~/ 60),
      'total_calories': (prev['total_calories'] as num? ?? 0) + calories,
      'completed_exercises':
          (prev['completed_exercises'] as num? ?? 0) + completedExercises,
      'session_count': (prev['session_count'] as num? ?? 0) + 1,
      'steps': (prev['steps'] as num? ?? 0).toInt(),
    });
  }

  Stream<DailyStat> watchTodayStats() {
    final key = dateKey();
    final controller = StreamController<DailyStat>();

    Future<void> load() async {
      final rows = await _client
          .from('daily_stats')
          .select()
          .eq('user_id', _uid)
          .eq('date_key', key);
      final data = rows.isNotEmpty ? rows.first : <String, dynamic>{};
      controller.add(
        DailyStat(
          dateKey: key,
          totalMinutes: (data['total_minutes'] as num? ?? 0).toInt(),
          totalCalories: (data['total_calories'] as num? ?? 0).toInt(),
          completedExercises: (data['completed_exercises'] as num? ?? 0).toInt(),
          sessionCount: (data['session_count'] as num? ?? 0).toInt(),
          steps: (data['steps'] as num? ?? 0).toInt(),
        ),
      );
    }

    load();
    if (BuildConfig.realtimeEnabled) {
      late final RealtimeChannel channel;
      channel = _client
          .channel('daily-stats-$_uid')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'daily_stats',
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

  Stream<List<DailyStat>> watchRecentStats({int days = 30}) {
    final controller = StreamController<List<DailyStat>>();

    Future<void> load() async {
      final rows = await _client
          .from('daily_stats')
          .select()
          .eq('user_id', _uid)
          .order('date_key', ascending: false)
          .limit(days);
      final mapped = rows.map((data) {
        return DailyStat(
          dateKey: data['date_key']?.toString() ?? '',
          totalMinutes: (data['total_minutes'] as num? ?? 0).toInt(),
          totalCalories: (data['total_calories'] as num? ?? 0).toInt(),
          completedExercises: (data['completed_exercises'] as num? ?? 0).toInt(),
          sessionCount: (data['session_count'] as num? ?? 0).toInt(),
          steps: (data['steps'] as num? ?? 0).toInt(),
        );
      }).toList(growable: false);
      controller.add(mapped.reversed.toList(growable: false));
    }

    load();
    if (BuildConfig.realtimeEnabled) {
      late final RealtimeChannel channel;
      channel = _client
          .channel('daily-stats-list-$_uid')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'daily_stats',
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

  Stream<List<WorkoutSession>> watchSessions({int limit = 20}) {
    final controller = StreamController<List<WorkoutSession>>();

    Future<void> load() async {
      final rows = await _client
          .from('workout_sessions')
          .select()
          .eq('user_id', _uid)
          .order('started_at', ascending: false)
          .limit(limit);
      controller.add(
        rows.map((data) {
          return WorkoutSession(
            id: data['id'].toString(),
            startedAt: DateTime.tryParse(data['started_at']?.toString() ?? '') ??
                DateTime.now(),
            endedAt: DateTime.tryParse(data['ended_at']?.toString() ?? ''),
            durationSec: (data['duration_sec'] as num? ?? 0).toInt(),
            calories: (data['calories'] as num? ?? 0).toInt(),
            exerciseCount: (data['exercise_count'] as num? ?? 0).toInt(),
            completed: data['completed'] == true,
            dateKey: data['date_key']?.toString() ?? '',
          );
        }).toList(growable: false),
      );
    }

    load();
    if (BuildConfig.realtimeEnabled) {
      late final RealtimeChannel channel;
      channel = _client
          .channel('sessions-$_uid')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'workout_sessions',
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

  Future<List<DailyStat>> fetchMonthStats({
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final startKey = dateKey(start);
    final endKey = dateKey(end);
    final rows = await _client
        .from('daily_stats')
        .select()
        .eq('user_id', _uid)
        .gte('date_key', startKey)
        .lt('date_key', endKey)
        .order('date_key', ascending: true);
    return rows.map((data) {
      return DailyStat(
        dateKey: data['date_key']?.toString() ?? '',
        totalMinutes: (data['total_minutes'] as num? ?? 0).toInt(),
        totalCalories: (data['total_calories'] as num? ?? 0).toInt(),
        completedExercises: (data['completed_exercises'] as num? ?? 0).toInt(),
        sessionCount: (data['session_count'] as num? ?? 0).toInt(),
        steps: (data['steps'] as num? ?? 0).toInt(),
      );
    }).toList(growable: false);
  }

  Future<Set<int>> fetchMonthSessionDays({
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final startKey = dateKey(start);
    final endKey = dateKey(end);

    final rows = await _client
        .from('workout_sessions')
        .select('date_key')
        .eq('user_id', _uid)
        .gte('date_key', startKey)
        .lt('date_key', endKey)
        .order('date_key', ascending: true);

    final days = <int>{};
    for (final r in rows) {
      final s = r['date_key']?.toString() ?? '';
      // PostgREST returns dates like 'YYYY-MM-DD'
      final parts = s.split('-');
      if (parts.length >= 3) {
        final d = int.tryParse(parts[2]);
        if (d != null && d >= 1 && d <= 31) days.add(d);
      }
    }
    return days;
  }

  Future<List<WorkoutSession>> fetchDaySessions({
    required DateTime day,
  }) async {
    final key = dateKey(day);
    final rows = await _client
        .from('workout_sessions')
        .select()
        .eq('user_id', _uid)
        .eq('date_key', key)
        .order('started_at', ascending: true);
    return rows.map((data) {
      return WorkoutSession(
        id: data['id'].toString(),
        startedAt:
            DateTime.tryParse(data['started_at']?.toString() ?? '') ?? day,
        endedAt: DateTime.tryParse(data['ended_at']?.toString() ?? ''),
        durationSec: (data['duration_sec'] as num? ?? 0).toInt(),
        calories: (data['calories'] as num? ?? 0).toInt(),
        exerciseCount: (data['exercise_count'] as num? ?? 0).toInt(),
        completed: data['completed'] == true,
        dateKey: data['date_key']?.toString() ?? key,
      );
    }).toList(growable: false);
  }

  Future<List<WorkoutSessionItem>> fetchSessionItems({
    required String sessionId,
  }) async {
    final rows = await _client
        .from('workout_session_items')
        .select('exercise_name,exercise_name_ar,minutes,calories,done')
        .eq('session_id', sessionId)
        .order('id', ascending: true);
    return rows.map((data) {
      return WorkoutSessionItem(
        exerciseName: data['exercise_name']?.toString() ?? '',
        exerciseNameAr: data['exercise_name_ar']?.toString() ?? '',
        minutes: (data['minutes'] as num? ?? 0).toInt(),
        calories: (data['calories'] as num? ?? 0).toInt(),
        done: data['done'] == true,
      );
    }).toList(growable: false);
  }
}
