import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_result_group.dart';
import '../models/song.dart';
import '../models/artist.dart';
import '../models/album.dart';
import '../models/playlist.dart';
import 'base_repository.dart';

final searchRepositoryProvider = Provider((ref) => SearchRepository(Supabase.instance.client));

class SearchRepository with SupabaseRepositoryHelper {
  final SupabaseClient _client;
  SearchRepository(this._client);

  Future<void> recordSearchKeyword(String keyword) {
    return runAction(() async {
      await _client.rpc('record_search_keyword', params: {'p_keyword': keyword});
    });
  }

  Future<SearchResultGroup> searchAll(String query) {
    return runAction(() async {
      // In a real optimized system, this might be a single RPC or View.
      // For now, doing concurrent queries using standard APIs.
      final songsFuture = _client.from('songs').select().ilike('title', '%$query%').limit(5);
      final artistsFuture = _client.from('artists').select().ilike('name', '%$query%').limit(5);
      final albumsFuture = _client.from('albums').select().ilike('title', '%$query%').limit(5);
      final playlistsFuture = _client.from('playlists').select().ilike('name', '%$query%').eq('is_public', true).limit(5);

      final results = await Future.wait([songsFuture, artistsFuture, albumsFuture, playlistsFuture]);

      return SearchResultGroup(
        songs: (results[0] as List).map((e) => Song.fromMap(e)).toList(),
        artists: (results[1] as List).map((e) => Artist.fromMap(e)).toList(),
        albums: (results[2] as List).map((e) => Album.fromMap(e)).toList(),
        playlists: (results[3] as List).map((e) => Playlist.fromMap(e)).toList(),
        podcasts: const [], // Could do podcast search as well
      );
    });
  }
}
