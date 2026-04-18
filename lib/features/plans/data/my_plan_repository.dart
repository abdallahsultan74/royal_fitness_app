import 'package:supabase_flutter/supabase_flutter.dart';

class MyActivePlan {
  const MyActivePlan({
    required this.assignmentId,
    required this.planId,
    required this.title,
    required this.description,
    required this.level,
    required this.durationWeeks,
    required this.jsonPlan,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.createdAt,
  });

  final String assignmentId;
  final String planId;
  final String title;
  final String? description;
  final String level;
  final int durationWeeks;
  final Map<String, dynamic> jsonPlan;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String status;
  final DateTime createdAt;
}

class MyPlanRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<MyActivePlan?> fetchMyActivePlan() async {
    final rows = await _client.rpc<List<dynamic>>('api_my_active_plan');
    if (rows.isEmpty) return null;
    final data = Map<String, dynamic>.from(rows.first as Map);
    return MyActivePlan(
      assignmentId: (data['assignment_id'] ?? '').toString(),
      planId: (data['plan_id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      description: data['description']?.toString(),
      level: (data['level'] ?? 'beginner').toString(),
      durationWeeks: (data['duration_weeks'] as num? ?? 4).toInt(),
      jsonPlan: (data['json_plan'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{},
      startsAt: DateTime.tryParse(data['starts_at']?.toString() ?? ''),
      endsAt: DateTime.tryParse(data['ends_at']?.toString() ?? ''),
      status: (data['status'] ?? 'active').toString(),
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

