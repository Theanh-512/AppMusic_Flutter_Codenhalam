import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/podcast.dart';
import '../models/podcast_channel.dart';
import 'base_repository.dart';

final podcastRepositoryProvider = Provider((ref) => PodcastRepository(Supabase.instance.client));

class PodcastRepository with SupabaseRepositoryHelper {
  final SupabaseClient _client;
  PodcastRepository(this._client);

  Future<List<Podcast>> getTrendingPodcasts({int limit = 10}) {
    return runAction(() async {
      final response = await _client
          .from('podcasts')
          .select()
          .eq('is_active', true)
          .order('listen_count', ascending: false)
          .limit(limit);
      return (response as List).map((e) => Podcast.fromMap(e)).toList();
    });
  }

  Future<List<PodcastChannel>> getTopChannels({int limit = 10}) {
    return runAction(() async {
      final response = await _client
          .from('podcast_channels')
          .select()
          .order('subscriber_count', ascending: false)
          .limit(limit);
      return (response as List).map((e) => PodcastChannel.fromMap(e)).toList();
    });
  }

  Future<void> recordPodcastListen(String podcastId) {
    return runAction(() async {
      await _client.rpc('record_podcast_listen', params: {'p_podcast_id': podcastId});
    });
  }

  Future<void> subscribeChannel(String channelId) {
    return runAction(() async {
      await _client.rpc('subscribe_channel', params: {'p_channel_id': channelId});
    });
  }
  
  Future<void> unsubscribeChannel(String channelId) {
    return runAction(() async {
      await _client.rpc('unsubscribe_channel', params: {'p_channel_id': channelId});
    });
  }
  Future<List<PodcastChannel>> getFollowedChannels() {
    return runAction(() async {
      final response = await _client
          .from('podcast_subscriptions')
          .select('..., podcast_channels(*)')
          .eq('user_id', _client.auth.currentUser!.id);
      
      return (response as List).map((e) => PodcastChannel.fromMap(e['podcast_channels'])).toList();
    });
  }
  Future<List<Podcast>> getPodcastsByChannelIds(List<String> channelIds, {int limit = 20}) {
    if (channelIds.isEmpty) return Future.value([]);
    return runAction(() async {
      final response = await _client
          .from('podcasts')
          .select()
          .inFilter('channel_id', channelIds)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(limit);
      return (response as List).map((e) => Podcast.fromMap(e)).toList();
    });
  }
}
