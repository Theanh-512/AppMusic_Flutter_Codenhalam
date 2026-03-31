import 'package:supabase_flutter/supabase_flutter.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message ${code != null ? '($code)' : ''}';
}

mixin SupabaseRepositoryHelper {
  Future<T> runAction<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      throw AppException(e.message, code: e.code, details: e.details);
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode?.toString());
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }
}
