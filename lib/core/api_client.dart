import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = _createDio();

  static Dio _createDio() {
    // Android Emulator: 10.0.2.2 maps to host machine's localhost
    // Web: use 127.0.0.1 directly
    final baseUrl = kIsWeb
        ? 'http://127.0.0.1:5094/api/'
        : 'http://10.0.2.2:5094/api/';

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // Add logging interceptor for debugging
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      error: true,
      logPrint: (o) => debugPrint('[API] $o'),
    ));

    // Add retry interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        debugPrint('[API] Error: ${e.type} - ${e.message}');
        debugPrint('[API] URL: ${e.requestOptions.uri}');
        handler.next(e);
      },
    ));

    return dio;
  }

  Dio get instance => _dio;
}
