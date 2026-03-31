class PodcastChannel {
  final String id;
  final String name;
  final String? avatarUrl;
  final int subscriberCount;

  const PodcastChannel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.subscriberCount = 0,
  });

  factory PodcastChannel.fromMap(Map<String, dynamic> map) {
    return PodcastChannel(
      id: map['id'] as String,
      name: map['name'] ?? '',
      avatarUrl: map['avatar_url'] as String?,
      subscriberCount: map['subscriber_count'] ?? 0,
    );
  }
}
