import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/following_provider.dart';
import 'widgets/followed_artists_row.dart';
import 'widgets/songs_section.dart';

class HomeMusicFollowingTab extends ConsumerWidget {
  const HomeMusicFollowingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(followedArtistsProvider);
    final songsAsync = ref.watch(followedArtistsSongsProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // Top Artists Row
        artistsAsync.maybeWhen(
          data: (artists) => FollowedArtistsRow(
            artists: artists,
            isLoading: artistsAsync.isLoading,
          ),
          orElse: () => const FollowedArtistsRow(artists: [], isLoading: true),
        ),

        // Resulting Songs List
        songsAsync.when(
          data: (songs) {
            if (songs.isEmpty) {
              return const SizedBox.shrink(); // Empty state handled by the artists row mostly
            }
            return SongsSection(
              title: 'Latest from artists you follow',
              songs: songs,
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
