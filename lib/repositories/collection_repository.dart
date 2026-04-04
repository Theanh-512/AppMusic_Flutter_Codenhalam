import 'package:dio/dio.dart';
import '../models/playlist.dart';
import '../models/album.dart';
import '../models/song.dart';

class CollectionRepository {
  final Dio _api;

  CollectionRepository(this._api);

  /// Fetch system curated playlists.
  Future<List<Playlist>> fetchSystemPlaylists() async {
    try {
      final response = await _api.get('/collections/system-playlists');
      return (response.data as List).map((e) => Playlist.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch new albums.
  Future<List<Album>> fetchNewAlbums() async {
    try {
      final response = await _api.get('/collections/new-albums');
      return (response.data as List).map((e) => Album.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get details and songs of a playlist.
  Future<List<Song>> fetchPlaylistSongs(int playlistId) async {
    try {
      final response = await _api.get('/collections/playlists/$playlistId/songs');
      return (response.data as List).map((e) => Song.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get details and songs of an album.
  Future<List<Song>> fetchAlbumSongs(int albumId) async {
    try {
      final response = await _api.get('/collections/albums/$albumId/songs');
      return (response.data as List).map((e) => Song.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if a playlist is saved/bookmarked by a user.
  Future<bool> isPlaylistSaved(String userId, int playlistId) async {
    try {
      final response = await _api.get('/collections/check-saved', queryParameters: {
        'userId': userId,
        'playlistId': playlistId,
      });
      return response.data['isSaved'] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Toggle saving/bookmarking status for a playlist.
  Future<void> toggleSavePlaylist(String userId, int playlistId, bool isAlreadySaved) async {
    try {
      await _api.post('/collections/toggle-save', data: {
        'userId': userId,
        'playlistId': playlistId,
      });
    } catch (e) {
      throw Exception('Lỗi khi lưu danh sách phát: $e');
    }
  }

  /// Fetch all playlists saved (bookmarked) by a user.
  Future<List<Playlist>> fetchSavedPlaylists(String userId) async {
    try {
      final response = await _api.get('/collections/user/$userId/saved-playlists');
      return (response.data as List).map((e) => Playlist.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
