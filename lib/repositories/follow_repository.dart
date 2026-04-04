import 'package:dio/dio.dart';
import '../models/artist.dart';

class FollowRepository {
  final Dio _api;

  FollowRepository(this._api);

  /// Check if an artist is followed by a user.
  Future<bool> isArtistFollowed(String userId, String artistId) async {
    try {
      final response = await _api.get('/follows/check', queryParameters: {
        'userId': userId,
        'artistId': artistId,
      });
      return response.data['isFollowed'] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Toggle following status for an artist.
  Future<void> toggleFollow(String userId, String artistId, bool isAlreadyFollowing) async {
    try {
      await _api.post('/follows/toggle', data: {
        'userId': userId,
        'artistId': artistId,
      });
    } catch (e) {
      throw Exception('Lỗi khi thay đổi trạng thái theo dõi: $e');
    }
  }

  /// Fetch all artists followed by a user.
  Future<List<Artist>> fetchFollowedArtists(String userId) async {
    try {
      final response = await _api.get('/follows/user/$userId/artists');
      return (response.data as List).map((e) => Artist.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
