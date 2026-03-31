import 'song.dart';
import 'podcast.dart';

enum PlaybackItemType { song, podcast }

class PlaybackItem {
  final String id; 
  final String title;
  final String subtitle;
  final String audioUrl;
  final String? coverUrl;
  final Duration duration;
  final PlaybackItemType type;
  
  // Keep original references strictly typed in case UI Needs to check properties 
  // without casting blindly.
  final Song? originalSong;
  final Podcast? originalPodcast;

  const PlaybackItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.audioUrl,
    this.coverUrl,
    required this.duration,
    required this.type,
    this.originalSong,
    this.originalPodcast,
  });

  factory PlaybackItem.fromSong(Song song) {
    return PlaybackItem(
      id: 'song_${song.id}',
      title: song.title,
      subtitle: song.artist,
      audioUrl: song.audioUrl,
      coverUrl: song.coverUrl,
      duration: Duration(seconds: song.durationSeconds),
      type: PlaybackItemType.song,
      originalSong: song,
    );
  }

  factory PlaybackItem.fromPodcast(Podcast podcast, String channelName) {
    return PlaybackItem(
      id: 'podcast_${podcast.id}',
      title: podcast.title,
      subtitle: channelName,
      audioUrl: podcast.audioUrl,
      coverUrl: podcast.coverUrl,
      duration: Duration(seconds: podcast.durationSeconds),
      type: PlaybackItemType.podcast,
      originalPodcast: podcast,
    );
  }
}
