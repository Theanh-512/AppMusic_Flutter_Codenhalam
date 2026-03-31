import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_repository.dart';

final playbackStateRepositoryProvider = Provider((ref) => PlaybackStateRepository(Supabase.instance.client));

class PlaybackStateRepository with SupabaseRepositoryHelper {
  final SupabaseClient _client;
  PlaybackStateRepository(this._client);

  Future<void> setUserPlayerState({
    int? currentSongId,
    int? currentPlaylistId,
    int positionSeconds = 0,
    bool isPlaying = false,
    bool shuffleEnabled = false,
    String repeatMode = 'off',
  }) {
    return runAction(() async {
      await _client.rpc('set_user_player_state', params: {
        'p_current_song_id': currentSongId,
        'p_current_playlist_id': currentPlaylistId,
        'p_position_seconds': positionSeconds,
        'p_is_playing': isPlaying,
        'p_shuffle_enabled': shuffleEnabled,
        'p_repeat_mode': repeatMode,
      });
    });
  }

  Future<void> clearUserPlayerState() {
    return runAction(() async {
      await _client.rpc('clear_user_player_state');
    });
  }
}
