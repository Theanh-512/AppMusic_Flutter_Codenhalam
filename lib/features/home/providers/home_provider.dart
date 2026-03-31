import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/song_repository.dart';
import '../../../core/repositories/album_repository.dart';
import '../../../core/repositories/podcast_repository.dart';
import '../../../core/models/song.dart';
import '../../../core/models/album.dart';
import '../../../core/models/podcast.dart';

/// State model for the Mixed Home Content
class MixedHomeContent {
  final List<Song> trendingSongs;
  final List<Album> recentAlbums;
  final List<Podcast> trendingPodcasts;

  const MixedHomeContent({
    required this.trendingSongs,
    required this.recentAlbums,
    required this.trendingPodcasts,
  });

  bool get isEmpty =>
      trendingSongs.isEmpty && recentAlbums.isEmpty && trendingPodcasts.isEmpty;
}

/// Provider that orchestrates loading all content for the "All" tab.
final mixedHomeContentProvider = FutureProvider<MixedHomeContent>((ref) async {
  final songRepo = ref.read(songRepositoryProvider);
  final albumRepo = ref.read(albumRepositoryProvider);
  final podcastRepo = ref.read(podcastRepositoryProvider);

  // Load all sections in parallel for better performance
  final results = await Future.wait([
    songRepo.getTrendingSongs(limit: 6),
    albumRepo.getRecentAlbums(limit: 6),
    podcastRepo.getTrendingPodcasts(limit: 6),
  ]);

  return MixedHomeContent(
    trendingSongs: results[0] as List<Song>,
    recentAlbums: results[1] as List<Album>,
    trendingPodcasts: results[2] as List<Podcast>,
  );
});
