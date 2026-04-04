import 'package:dio/dio.dart';
import '../models/podcast.dart';
import '../models/podcast_channel.dart';

class PodcastRepository {
  final Dio _api;

  PodcastRepository(this._api);

  Future<List<Podcast>> fetchAllPodcasts() async {
    try {
      final response = await _api.get('/podcasts');
      return (response.data as List).map((row) => Podcast.fromJson(row)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PodcastChannel>> fetchSubscribedChannels(String userId) async {
    try {
      final response = await _api.get('/podcasts/user/$userId/subscriptions');
      return (response.data as List).map((row) => PodcastChannel.fromJson(row)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Podcast>> fetchPodcastsByChannel(String channelId) async {
    try {
      final response = await _api.get('/podcasts/channel/$channelId');
      return (response.data as List).map((row) => Podcast.fromJson(row)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PodcastChannel> getChannelDetail(String channelId) async {
    try {
      final response = await _api.get('/podcasts/channel-detail/$channelId');
      return PodcastChannel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin kênh: $e');
    }
  }

  Future<bool> checkIsSubscribed(String userId, String channelId) async {
    try {
      final response = await _api.get('/podcasts/check-subscription', queryParameters: {
        'userId': userId,
        'channelId': channelId,
      });
      return response.data['isSubscribed'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleSubscription(String userId, String channelId, bool isSubscribed) async {
    try {
      await _api.post('/podcasts/toggle-subscription', data: {
        'userId': userId,
        'channelId': channelId,
      });
    } catch (e) {
      throw Exception('Lỗi khi thay đổi trạng thái đăng ký: $e');
    }
  }

  Future<List<Podcast>> fetchLatestPodcastsFromSubscriptions(String userId) async {
    try {
      final response = await _api.get('/podcasts/user/$userId/latest-from-subs');
      return (response.data as List).map((row) => Podcast.fromJson(row)).toList();
    } catch (e) {
      return [];
    }
  }
}
