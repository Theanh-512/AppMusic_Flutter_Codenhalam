class Song {
  final int id;
  final String title;
  final String artist;
  final int? albumId;
  final String? coverUrl;
  final String audioUrl;
  final int durationSeconds;
  final int totalListens;
  final int likeCountCache;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.albumId,
    this.coverUrl,
    required this.audioUrl,
    required this.durationSeconds,
    this.totalListens = 0,
    this.likeCountCache = 0,
  });

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      albumId: map['album_id'] is int ? map['album_id'] : int.tryParse(map['album_id']?.toString() ?? ''),
      coverUrl: map['cover_url'] as String?,
      audioUrl: map['audio_url'] ?? '',
      durationSeconds: map['duration_seconds'] ?? 0,
      totalListens: map['total_listens'] ?? 0,
      likeCountCache: map['like_count_cache'] ?? 0,
    );
  }
}
