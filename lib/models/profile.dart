class Profile {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool isArtist;

  Profile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.isArtist = false,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      isArtist: json['is_artist'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'is_artist': isArtist,
    };
  }
}
