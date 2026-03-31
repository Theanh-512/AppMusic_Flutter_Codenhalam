import 'song.dart';
import 'artist.dart';
import 'album.dart';
import 'playlist.dart';
import 'podcast.dart';

class SearchResultGroup {
  final List<Song> songs;
  final List<Artist> artists;
  final List<Album> albums;
  final List<Playlist> playlists;
  final List<Podcast> podcasts;

  const SearchResultGroup({
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlists = const [],
    this.podcasts = const [],
  });

  bool get isEmpty =>
      songs.isEmpty &&
      artists.isEmpty &&
      albums.isEmpty &&
      playlists.isEmpty &&
      podcasts.isEmpty;
}
