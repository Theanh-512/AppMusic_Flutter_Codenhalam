import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/podcast_following_provider.dart';
import 'widgets/followed_channels_row.dart';
import 'widgets/podcasts_section.dart';

class HomePodcastsFollowingTab extends ConsumerWidget {
  const HomePodcastsFollowingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(followedChannelsProvider);
    final podcastsAsync = ref.watch(followedChannelsPodcastsProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // Followed Channels Row
        channelsAsync.maybeWhen(
          data: (channels) => FollowedChannelsRow(
            channels: channels,
            isLoading: channelsAsync.isLoading,
          ),
          orElse: () => const FollowedChannelsRow(channels: [], isLoading: true),
        ),

        // Episodes from those channels
        podcastsAsync.when(
          data: (podcasts) {
            if (podcasts.isEmpty) {
              return const SizedBox.shrink();
            }
            return PodcastsSection(
              title: 'Latest from your favorite shows',
              podcasts: podcasts,
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
