import 'package:dio/dio.dart';
import '../models/profile.dart';

class AuthRepository {
  final Dio _api;
  Profile? _cachedProfile;

  AuthRepository(this._api);

  // We'll manage current user locally since we're using simple API auth
  Profile? get currentUser => _cachedProfile;

  Future<void> signInWithEmail(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      _cachedProfile = Profile.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception('Email hoặc mật khẩu không đúng');
      }
      throw Exception('Lỗi khi đăng nhập: $e');
    }
  }

  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    try {
      final response = await _api.post('/auth/register', data: {
        'email': email,
        'password': password,
        'displayName': displayName,
      });
      _cachedProfile = Profile.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('Email đã được đăng ký');
      }
      throw Exception('Lỗi khi đăng ký: $e');
    }
  }

  Future<void> signOut() async {
    _cachedProfile = null;
  }

  Future<Profile?> getProfile() async {
    return _cachedProfile;
  }

  // OTP and other advanced auth features may need implementation on backend
  Future<void> sendPasswordResetOTP(String email) async => throw UnimplementedError();
  Future<void> verifyOTP(String email, String otp) async => throw UnimplementedError();
  Future<void> updatePassword(String newPassword) async => throw UnimplementedError();
}
