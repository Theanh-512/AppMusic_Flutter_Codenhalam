import 'package:dio/dio.dart';
import '../models/song.dart';
import '../models/podcast.dart';

class PlayerRepository {
  final Dio _api;

  PlayerRepository(this._api);

  Future<Map<String, dynamic>?> fetchPlayerState(String userId) async {
    try {
      final response = await _api.get('/player/state/$userId');
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePlayerState({
    required String userId,
    required String? currentSongId,
    required String? currentPlaylistId,
    required int positionSeconds,
    required String repeatMode,
    required bool shuffleEnabled,
  }) async {
    try {
      await _api.post('/player/state', data: {
        'userId': userId,
        'currentSongId': currentSongId,
        'currentPlaylistId': currentPlaylistId,
        'positionSeconds': positionSeconds,
        'repeatMode': repeatMode,
        'shuffleEnabled': shuffleEnabled,
      });
    } catch (e) {
      // Ignored
    }
  }

  Future<void> logListen({
    required String userId,
    String? songId,
    String? podcastId,
  }) async {
    try {
      await _api.post('/player/listen', data: {
        'userId': userId,
        'songId': songId,
        'podcastId': podcastId,
      });
    } catch (e) {
      // Ignored
    }
  }

  Future<List<dynamic>> fetchRecentPlays(String userId) async {
    try {
      final response = await _api.get('/player/recent/$userId');
      final List<dynamic> data = response.data;
      
      return data.map((item) {
        if (item['type'] == 'song') {
          return Song.fromJson(item['data']);
        } else {
          return Podcast.fromJson(item['data']);
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
