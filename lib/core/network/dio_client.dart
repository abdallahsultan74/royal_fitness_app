import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';

@lazySingleton
class DioClient {
  DioClient() : dio = _createDio();

  final Dio dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.rapidApiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: <String, dynamic>{
          'Accept': 'application/json',
          'X-RapidAPI-Host': ApiConstants.rapidApiHost,
          if (ApiConstants.rapidApiKey.isNotEmpty)
            'X-RapidAPI-Key': ApiConstants.rapidApiKey,
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) {
          if (kDebugMode) {
            debugPrint('[Dio] ${e.requestOptions.uri} → ${e.message}');
          }
          handler.next(e);
        },
      ),
    );

    return dio;
  }
}
