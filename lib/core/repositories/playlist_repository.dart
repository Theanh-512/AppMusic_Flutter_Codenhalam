import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import 'base_repository.dart';

final playlistRepositoryProvider = Provider((ref) => PlaylistRepository(Supabase.instance.client));

class PlaylistRepository with SupabaseRepositoryHelper {
  final SupabaseClient _client;
  PlaylistRepository(this._client);

  Future<List<Playlist>> getSystemPlaylists({int limit = 10}) {
    return runAction(() async {
      final response = await _client
          .from('playlists')
          .select()
          .eq('is_system', true)
          .order('saves_count_cache', ascending: false)
          .limit(limit);
      return (response as List).map((e) => Playlist.fromMap(e)).toList();
    });
  }

  Future<List<Playlist>> getUserPlaylists(String userId) {
    return runAction(() async {
      final response = await _client
          .from('playlists')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (response as List).map((e) => Playlist.fromMap(e)).toList();
    });
  }

  Future<void> savePlaylist(int playlistId) {
    return runAction(() async {
      await _client.rpc('save_playlist', params: {'p_playlist_id': playlistId});
    });
  }

  Future<void> unsavePlaylist(int playlistId) {
    return runAction(() async {
      await _client.rpc('unsave_playlist', params: {'p_playlist_id': playlistId});
    });
  }
}
