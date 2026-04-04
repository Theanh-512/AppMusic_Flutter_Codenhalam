import 'package:dio/dio.dart';
import '../models/song.dart';

class FavoriteRepository {
  final Dio _api;

  FavoriteRepository(this._api);

  /// Check if a song is liked by a specific user.
  Future<bool> isSongLiked(String userId, int songId) async {
    try {
      final response = await _api.get('/favorites/check', queryParameters: {
        'userId': userId,
        'songId': songId,
      });
      return response.data['isLiked'] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Toggle like status for a song.
  Future<void> toggleLike(String userId, int songId, bool isAlreadyLiked) async {
    try {
      await _api.post('/favorites/toggle', data: {
        'userId': userId,
        'songId': songId,
      });
    } catch (e) {
      throw Exception('Lỗi khi thay đổi trạng thái thích: $e');
    }
  }

  /// Fetch all songs liked by a user.
  Future<List<Song>> fetchLikedSongs(String userId) async {
    try {
      final response = await _api.get('/favorites/$userId');
      return (response.data as List).map((e) => Song.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách bài hát đã thích: $e');
    }
  }

  /// Get the total count of liked songs for a user.
  Future<int> getLikedSongsCount(String userId) async {
    try {
      final songs = await fetchLikedSongs(userId);
      return songs.length;
    } catch (e) {
      return 0;
    }
  }
}
