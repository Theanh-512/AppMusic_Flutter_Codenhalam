import 'package:dio/dio.dart';
import '../models/song.dart';

class SongRepository {
  final Dio _api;

  SongRepository(this._api);

  /// Fetch songs for the "Trending" section, ordered by like count.
  Future<List<Song>> fetchTrendingSongs({int limit = 50}) async {
    try {
      final response = await _api.get('/songs/trending', queryParameters: {
        'limit': limit,
      });

      return (response.data as List).map((e) => Song.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải bài hát nổi bật: $e');
    }
  }

  /// Fetch all songs for a general picker, with optional search query.
  Future<List<Song>> fetchAllSongs({String? query, int limit = 100}) async {
    try {
      final response = await _api.get('/songs', queryParameters: {
        'query': query,
        'limit': limit,
      });

      return (response.data as List).map((e) => Song.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải bài hát: $e');
    }
  }

  /// Get a single song by its ID.
  Future<Song?> getSongById(int songId) async {
    try {
      final response = await _api.get('/songs/$songId');
      return Song.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Fetch all songs associated with an artist.
  Future<List<Song>> fetchSongsByArtist(String artistId, {int limit = 20}) async {
    try {
        final response = await _api.get('/songs/artist/$artistId', queryParameters: {
          'limit': limit,
        });

        return (response.data as List).map((e) => Song.fromJson(e)).toList();
    } catch (e) {
       throw Exception('Lỗi tải bài hát của nghệ sĩ: $e');
    }
  }

  /// Get a single random song from the database.
  Future<Song?> fetchRandomSong() async {
    try {
      final response = await _api.get('/songs/random');
      return Song.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// New: Fetch songs by a specific genre, mood, or hashtag.
  Future<List<Song>> fetchSongsByCategory({required String type, required String name, int limit = 50}) async {
    try {
      final response = await _api.get('/songs/category', queryParameters: {
        'type': type,
        'name': name,
        'limit': limit,
      });

      return (response.data as List).map((e) => Song.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
