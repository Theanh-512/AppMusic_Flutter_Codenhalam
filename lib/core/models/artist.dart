class Artist {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final bool verified;
  final String? country;
  final int? debutYear;

  const Artist({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.verified = false,
    this.country,
    this.debutYear,
  });

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'] as String,
      name: map['name'] ?? '',
      avatarUrl: map['avatar_url'] as String?,
      coverUrl: map['cover_url'] as String?,
      bio: map['bio'] as String?,
      verified: map['verified'] ?? false,
      country: map['country'] as String?,
      debutYear: map['debut_year'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'bio': bio,
      'verified': verified,
      'country': country,
      'debut_year': debutYear,
    };
  }
}
