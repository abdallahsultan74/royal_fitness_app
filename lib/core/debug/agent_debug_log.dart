import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-mode NDJSON ingest (session 8f9b92). No-op in release.
Future<void> agentDebugLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, dynamic>? data,
}) async {
  if (kReleaseMode) return;
  final uri = Uri.parse(
    (!kIsWeb && Platform.isAndroid)
        ? 'http://10.0.2.2:7612/ingest/c5232231-0230-4f56-abad-b095019f00c2'
        : 'http://127.0.0.1:7612/ingest/c5232231-0230-4f56-abad-b095019f00c2',
  );
  try {
    await Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 800),
        sendTimeout: const Duration(milliseconds: 800),
        headers: {
          'Content-Type': 'application/json',
          'X-Debug-Session-Id': '8f9b92',
        },
      ),
    ).postUri(
      uri,
      data: {
        'sessionId': '8f9b92',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'hypothesisId': hypothesisId,
        'location': location,
        'message': message,
        'data': data ?? const <String, dynamic>{},
      },
    );
  } catch (_) {/* ignore — debug only */}
}
