class Playlist {
  final int id;
  final String? userId;
  final String name;
  final String? description;
  final String? coverUrl;
  final String playlistType;
  final bool isSystem;
  final bool isPublic;
  final int songsCountCache;

  const Playlist({
    required this.id,
    this.userId,
    required this.name,
    this.description,
    this.coverUrl,
    required this.playlistType,
    required this.isSystem,
    required this.isPublic,
    this.songsCountCache = 0,
  });

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      userId: map['user_id'] as String?,
      name: map['name'] ?? '',
      description: map['description'] as String?,
      coverUrl: map['cover_url'] as String?,
      playlistType: map['playlist_type'] ?? 'user',
      isSystem: map['is_system'] ?? false,
      isPublic: map['is_public'] ?? false,
      songsCountCache: map['songs_count_cache'] ?? 0,
    );
  }
}
