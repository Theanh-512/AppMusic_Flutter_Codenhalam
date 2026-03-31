import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import 'widgets/home_sections.dart';
import '../../../core/models/playback_item.dart';

class HomeAllTab extends ConsumerWidget {
  const HomeAllTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(mixedHomeContentProvider);

    return contentAsync.when(
      data: (content) {
        if (content.isEmpty) {
          return const Center(
            child: Text(
              'No content available',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 100), // Account for MiniPlayer
          children: [
            // Trending Songs Section
            if (content.trendingSongs.isNotEmpty) ...[
              const SectionHeader(title: 'Top Hits'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: content.trendingSongs.map((song) {
                    return MediaCard(
                      title: song.title,
                      subtitle: song.artist,
                      imageUrl: song.coverUrl,
                      type: PlaybackItemType.song,
                      onTap: () {
                        // Play Song logic
                      },
                    );
                  }).toList(),
                ),
              ),
            ],

            // Recent Albums Section
            if (content.recentAlbums.isNotEmpty) ...[
              const SectionHeader(title: 'New Releases'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: content.recentAlbums.map((album) {
                    return MediaCard(
                      title: album.title,
                      subtitle: 'Album', // Or fetch artist name if available in model later
                      imageUrl: album.coverUrl,
                      type: PlaybackItemType.song, // Visual styling is similar
                      onTap: () {
                        // Open Album logic
                      },
                    );
                  }).toList(),
                ),
              ),
            ],

            // Trending Podcasts Section
            if (content.trendingPodcasts.isNotEmpty) ...[
              const SectionHeader(title: 'Popular Podcasts'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: content.trendingPodcasts.map((podcast) {
                    return MediaCard(
                      title: podcast.title,
                      subtitle: 'Podcast',
                      imageUrl: podcast.coverUrl,
                      type: PlaybackItemType.podcast,
                      onTap: () {
                        // Play Podcast logic
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white24, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Failed to load content',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(mixedHomeContentProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
