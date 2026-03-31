import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/album.dart';
import 'base_repository.dart';

final albumRepositoryProvider = Provider((ref) => AlbumRepository(Supabase.instance.client));

class AlbumRepository with SupabaseRepositoryHelper {
  final SupabaseClient _client;
  AlbumRepository(this._client);

  Future<List<Album>> getRecentAlbums({int limit = 10}) {
    return runAction(() async {
      final response = await _client
          .from('albums')
          .select()
          .eq('is_active', true)
          .order('release_date', ascending: false)
          .limit(limit);
      return (response as List).map((e) => Album.fromMap(e)).toList();
    });
  }
}
