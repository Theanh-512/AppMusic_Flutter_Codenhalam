import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import 'base_repository.dart';

final songRepositoryProvider = Provider((ref) => SongRepository(Supabase.instance.client));

class SongRepository with SupabaseRepositoryHelper {
  final SupabaseClient _client;
  SongRepository(this._client);

  Future<List<Song>> getTrendingSongs({int limit = 10}) {
    return runAction(() async {
      final response = await _client
          .from('songs')
          .select()
          .eq('is_active', true)
          .order('total_listens', ascending: false)
          .limit(limit);
      return (response as List).map((e) => Song.fromMap(e)).toList();
    });
  }

  Future<Song?> getSongById(int id) {
    return runAction(() async {
      final response = await _client
          .from('songs')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return Song.fromMap(response);
    });
  }

  Future<void> recordSongListen(int songId) {
    return runAction(() async {
      await _client.rpc('record_song_listen', params: {'p_song_id': songId});
    });
  }

  Future<void> likeSong(int songId) {
    return runAction(() async {
      await _client.rpc('like_song', params: {'p_song_id': songId});
    });
  }

  Future<void> unlikeSong(int songId) {
    return runAction(() async {
      await _client.rpc('unlike_song', params: {'p_song_id': songId});
    });
  }
  Future<List<Song>> getSongsByArtistIds(List<String> artistIds, {int limit = 20}) {
    if (artistIds.isEmpty) return Future.value([]);
    return runAction(() async {
      final response = await _client
          .from('songs')
          .select()
          .inFilter('artist_id', artistIds)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(limit);
      return (response as List).map((e) => Song.fromMap(e)).toList();
    });
  }
}
