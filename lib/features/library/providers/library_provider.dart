import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/playlist_repository.dart';
import '../../../core/repositories/artist_repository.dart';
import '../../../core/repositories/podcast_repository.dart';
import '../../../core/models/playlist.dart';
import '../../../core/models/artist.dart';
import '../../../core/models/podcast_channel.dart';
import '../../auth/providers/auth_provider.dart';

final libraryPlaylistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  final repo = ref.read(playlistRepositoryProvider);
  return repo.getUserPlaylists(user.id);
});

final libraryArtistsProvider = FutureProvider<List<Artist>>((ref) async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) return [];
  
  final repo = ref.read(artistRepositoryProvider);
  return repo.getFollowedArtists();
});

final libraryPodcastsProvider = FutureProvider<List<PodcastChannel>>((ref) async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) return [];
  
  final repo = ref.read(podcastRepositoryProvider);
  return repo.getFollowedChannels();
});
