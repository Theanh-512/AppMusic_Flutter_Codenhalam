import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/song_repository.dart';
import '../../../core/repositories/artist_repository.dart';
import '../../../core/models/song.dart';
import '../../../core/models/artist.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider to fetch followed artists. 
/// Automatically responds to auth state changes.
final followedArtistsProvider = FutureProvider<List<Artist>>((ref) async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) return [];
  
  final repo = ref.read(artistRepositoryProvider);
  return repo.getFollowedArtists();
});

/// Provider to fetch songs from the artists the user follows.
final followedArtistsSongsProvider = FutureProvider<List<Song>>((ref) async {
  final artistsAsync = await ref.watch(followedArtistsProvider.future);
  if (artistsAsync.isEmpty) return [];

  final artistIds = artistsAsync.map((a) => a.id).toList();
  final repo = ref.read(songRepositoryProvider);
  return repo.getSongsByArtistIds(artistIds);
});
