import 'package:dio/dio.dart';
import '../models/playlist.dart';

class PlaylistRepository {
  final Dio _api;

  PlaylistRepository(this._api);

  /// Fetch all playlists owned by a user.
  Future<List<Playlist>> fetchUserOwnedPlaylists(String userId) async {
    try {
      final response = await _api.get('/playlists/user/$userId');
      return (response.data as List).map((e) => Playlist.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Create a new playlist.
  Future<Playlist> createPlaylist({
    required String userId,
    required String name,
    String? description,
    List<int> songIds = const [],
    String? coverUrl,
  }) async {
    try {
      final response = await _api.post('/playlists', data: {
        'user_id': userId,
        'name': name,
        'description': description,
        'cover_url': coverUrl,
        'song_ids': songIds,
      });
      return Playlist.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tạo danh sách phát: $e');
    }
  }

  /// Add songs to a playlist.
  Future<void> addSongsToPlaylist(int playlistId, List<int> songIds) async {
    try {
      await _api.post('/playlists/$playlistId/songs', data: {
        'songIds': songIds,
      });
    } catch (e) {
      throw Exception('Lỗi khi thêm bài hát vào danh sách phát: $e');
    }
  }

  /// Remove a song from a playlist.
  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    try {
      await _api.delete('/playlists/$playlistId/songs/$songId');
    } catch (e) {
      throw Exception('Lỗi khi xóa bài hát khỏi danh sách phát: $e');
    }
  }

  /// Delete a playlist.
  Future<void> deletePlaylist(int playlistId) async {
    try {
      await _api.delete('/playlists/$playlistId');
    } catch (e) {
      throw Exception('Lỗi khi xóa danh sách phát: $e');
    }
  }

  /// Rename a playlist.
  Future<void> renamePlaylist(int playlistId, String newName) async {
    try {
      await _api.put('/playlists/$playlistId', data: {
        'name': newName,
      });
    } catch (e) {
      throw Exception('Lỗi khi đổi tên danh sách phát: $e');
    }
  }
}
