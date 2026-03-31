class Podcast {
  final String id;
  final String title;
  final String channelId;
  final String audioUrl;
  final String? coverUrl;
  final int durationSeconds;
  final int listenCount;

  const Podcast({
    required this.id,
    required this.title,
    required this.channelId,
    required this.audioUrl,
    this.coverUrl,
    required this.durationSeconds,
    this.listenCount = 0,
  });

  factory Podcast.fromMap(Map<String, dynamic> map) {
    return Podcast(
      id: map['id'] as String,
      title: map['title'] ?? '',
      channelId: map['channel_id'] as String,
      audioUrl: map['audio_url'] ?? '',
      coverUrl: map['cover_url'] as String?,
      durationSeconds: map['duration_seconds'] ?? 0,
      listenCount: map['listen_count'] ?? 0,
    );
  }
}
