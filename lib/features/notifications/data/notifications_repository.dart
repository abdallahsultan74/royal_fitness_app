import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class UserNotificationItem {
  const UserNotificationItem({
    required this.id,
    required this.userId,
    required this.senderId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.readAt,
  });

  final String id;
  final String userId;
  final String? senderId;
  final String type; // notification | message
  final String? title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;
}

class NotificationsRepository {
  NotificationsRepository();

  SupabaseClient get _client => Supabase.instance.client;
  String get _uid => _client.auth.currentUser!.id;

  Stream<List<UserNotificationItem>> watchInbox({int limit = 50}) {
    final controller = StreamController<List<UserNotificationItem>>();

    Future<void> load() async {
      final rows = await _client
          .from('user_notifications')
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false)
          .limit(limit);
      controller.add(_map(rows));
    }

    late final RealtimeChannel channel;
    channel = _client
        .channel('user-notifications-$_uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_notifications',
          callback: (_) => load(),
        )
        .subscribe();

    load();
    controller.onCancel = () => _client.removeChannel(channel);
    return controller.stream;
  }

  Stream<List<UserNotificationItem>> watchSent({int limit = 50}) {
    final controller = StreamController<List<UserNotificationItem>>();

    Future<void> load() async {
      final rows = await _client
          .from('user_notifications')
          .select()
          .eq('sender_id', _uid)
          .order('created_at', ascending: false)
          .limit(limit);
      controller.add(_map(rows));
    }

    late final RealtimeChannel channel;
    channel = _client
        .channel('user-notifications-sent-$_uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_notifications',
          callback: (_) => load(),
        )
        .subscribe();

    load();
    controller.onCancel = () => _client.removeChannel(channel);
    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> listStaffRecipients() async {
    final rows = await _client.rpc('list_staff_recipients');
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> sendMessageToStaff({
    required String staffUserId,
    required String body,
    String? title,
  }) async {
    final text = body.trim();
    if (text.isEmpty) throw Exception('MESSAGE_REQUIRED');
    await _client.from('user_notifications').insert(<String, dynamic>{
      'user_id': staffUserId,
      'sender_id': _uid,
      'type': 'message',
      'title': (title ?? '').trim().isEmpty ? null : title!.trim(),
      'body': text,
    });
  }

  Future<void> markRead(String id) async {
    await _client
        .from('user_notifications')
        .update(<String, dynamic>{'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }

  List<UserNotificationItem> _map(dynamic rows) {
    final list = (rows as List?)?.cast<Map<String, dynamic>>() ?? const <Map<String, dynamic>>[];
    return list.map((r) {
      return UserNotificationItem(
        id: r['id']?.toString() ?? '',
        userId: r['user_id']?.toString() ?? '',
        senderId: r['sender_id']?.toString(),
        type: r['type']?.toString() ?? 'notification',
        title: r['title']?.toString(),
        body: r['body']?.toString() ?? '',
        createdAt: DateTime.tryParse(r['created_at']?.toString() ?? '') ?? DateTime.now(),
        readAt: DateTime.tryParse(r['read_at']?.toString() ?? ''),
      );
    }).toList(growable: false);
  }
}

