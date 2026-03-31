class Album {
  final int id;
  final String title;
  final String? coverUrl;
  final String? description;
  final DateTime? releaseDate;
  final String albumType;

  const Album({
    required this.id,
    required this.title,
    this.coverUrl,
    this.description,
    this.releaseDate,
    required this.albumType,
  });

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      title: map['title'] ?? '',
      coverUrl: map['cover_url'] as String?,
      description: map['description'] as String?,
      releaseDate: map['release_date'] != null ? DateTime.tryParse(map['release_date']) : null,
      albumType: map['album_type'] ?? 'album',
    );
  }
}
