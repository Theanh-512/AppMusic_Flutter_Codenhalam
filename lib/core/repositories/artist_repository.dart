import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/artist.dart';
import 'base_repository.dart';

final artistRepositoryProvider = Provider((ref) => ArtistRepository(Supabase.instance.client));

class ArtistRepository with SupabaseRepositoryHelper {
  final SupabaseClient _client;
  ArtistRepository(this._client);

  Future<List<Artist>> getTopArtists({int limit = 10}) {
    return runAction(() async {
      final response = await _client
          .from('artists')
          .select()
          .order('followers_count_cache', ascending: false)
          .limit(limit);
      return (response as List).map((e) => Artist.fromMap(e)).toList();
    });
  }

  Future<Artist?> getArtistById(String id) {
    return runAction(() async {
      final response = await _client
          .from('artists')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return Artist.fromMap(response);
    });
  }

  Future<List<Artist>> getFollowedArtists() {
    return runAction(() async {
      final response = await _client
          .from('artist_followers')
          .select('..., artists(*)')
          .eq('user_id', _client.auth.currentUser!.id);
      
      return (response as List).map((e) => Artist.fromMap(e['artists'])).toList();
    });
  }

  Future<void> followArtist(String artistId) {
    return runAction(() async {
      await _client.rpc('follow_artist', params: {'p_artist_id': artistId});
    });
  }

  Future<void> unfollowArtist(String artistId) {
    return runAction(() async {
      await _client.rpc('unfollow_artist', params: {'p_artist_id': artistId});
    });
  }
}
