import 'package:dio/dio.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../models/album.dart';

class ArtistRepository {
  final Dio _api;

  ArtistRepository(this._api);

  /// Fetch public popular artists.
  Future<List<Artist>> fetchPopularArtists({int limit = 20}) async {
    try {
      final response = await _api.get(
        '/artists/popular',
        queryParameters: {'limit': limit},
      );
      return (response.data as List).map((e) => Artist.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get detailed metadata for a single artist.
  Future<Artist> getArtistDetail(String artistId) async {
    try {
      final response = await _api.get('/artists/$artistId');
      return Artist.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin nghệ sĩ: $e');
    }
  }

  /// Fetch all songs where this artist is a primary or featured artist.
  Future<List<Song>> getArtistSongs(String artistId) async {
    try {
      final response = await _api.get('/artists/$artistId/songs');
      return (response.data as List).map((e) => Song.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch all albums associated with this artist.
  Future<List<Album>> getArtistAlbums(String artistId) async {
    try {
      final response = await _api.get('/artists/$artistId/albums');
      return (response.data as List).map((e) => Album.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
