import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(
    // kIsWeb is true when running on Edge/Chrome. Use 127.0.0.1 instead of localhost to avoid IPv6 issues.
    baseUrl: kIsWeb ? 'http://127.0.0.1:5094/api' : 'http://10.0.2.2:5094/api', 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Dio get instance => _dio;
}
