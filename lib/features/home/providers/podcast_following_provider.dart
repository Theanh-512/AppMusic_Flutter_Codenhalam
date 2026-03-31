import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/podcast_repository.dart';
import '../../../core/models/podcast_channel.dart';
import '../../../core/models/podcast.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider to fetch followed podcast channels.
final followedChannelsProvider = FutureProvider<List<PodcastChannel>>((ref) async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) return [];
  
  final repo = ref.read(podcastRepositoryProvider);
  return repo.getFollowedChannels();
});

/// Provider to fetch episodes from the channels the user follows.
final followedChannelsPodcastsProvider = FutureProvider<List<Podcast>>((ref) async {
  final channelsAsync = await ref.watch(followedChannelsProvider.future);
  if (channelsAsync.isEmpty) return [];

  final channelIds = channelsAsync.map((c) => c.id).toList();
  final repo = ref.read(podcastRepositoryProvider);
  return repo.getPodcastsByChannelIds(channelIds);
});
