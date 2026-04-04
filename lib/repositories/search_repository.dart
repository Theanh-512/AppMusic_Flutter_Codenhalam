import 'package:dio/dio.dart';
import '../models/song.dart';
import '../models/artist.dart';
import '../models/album.dart';
import '../models/playlist.dart';
import '../models/podcast.dart';
import '../helpers/local_recent_search_helper.dart';

class SearchRepository {
  final Dio _api;

  SearchRepository(this._api);

  // ─── Multi-Entity Search ──────────────────────────────────────────────────
  
  Future<List<Song>> searchSongs(String query) async {
    try {
      final response = await _api.get('/search/songs', queryParameters: {'query': query});
      return (response.data as List).map((e) => Song.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Artist>> searchArtists(String query) async {
    try {
      final response = await _api.get('/search/artists', queryParameters: {'query': query});
      return (response.data as List).map((e) => Artist.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Album>> searchAlbums(String query) async {
    try {
      final response = await _api.get('/search/albums', queryParameters: {'query': query});
      return (response.data as List).map((e) => Album.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Playlist>> searchPlaylists(String query) async {
    try {
      final response = await _api.get('/search/playlists', queryParameters: {'query': query});
      return (response.data as List).map((e) => Playlist.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Podcast>> searchPodcasts(String query) async {
    try {
      final response = await _api.get('/search/podcasts', queryParameters: {'query': query});
      return (response.data as List).map((e) => Podcast.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchGenres(String query) async {
    try {
      final response = await _api.get('/search/genres', queryParameters: {'query': query});
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchMoods(String query) async {
    try {
      final response = await _api.get('/search/moods', queryParameters: {'query': query});
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchHashtags(String query) async {
    try {
      final response = await _api.get('/search/hashtags', queryParameters: {'query': query});
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  // ─── Search History (Kept Local) ──────────────────────────────────────────

  final LocalRecentSearchHelper _localHelper = LocalRecentSearchHelper();

  Future<List<Map<String, dynamic>>> getRecentSearches(String? userId) async {
    return await _localHelper.getRecentSearches();
  }

  Future<void> saveSearchItem({
    String? userId,
    required String keyword,
    required String contentType,
    String? contentId,
    required String title,
    String? subtitle,
    String? imageUrl,
  }) async {
    final item = {
      'keyword': keyword,
      'content_type': contentType,
      'content_id': contentId,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    };
    await _localHelper.saveSearch(item);
  }

  Future<void> clearRecentSearches(String? userId) async {
    await _localHelper.clearAll();
  }

  Future<void> removeSearchItem({
    String? userId,
    required String contentType,
    String? contentId,
    String? keyword,
  }) async {
    await _localHelper.removeSearch({
      'content_type': contentType,
      'content_id': contentId,
      'keyword': keyword,
    });
  }

  // ─── Discovery Data ────────────────────────────────────────────────────────

  Future<List<String>> getTrendingKeywords() async {
    try {
      final response = await _api.get('/search/trending-keywords');
      return (response.data as List).map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHashtags() async {
    try {
      final response = await _api.get('/search/discovery/hashtags');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getGenres() async {
    try {
      final response = await _api.get('/search/discovery/genres');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMoods() async {
    try {
      final response = await _api.get('/search/discovery/moods');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }
}
