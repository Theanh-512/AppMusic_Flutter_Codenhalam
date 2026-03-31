import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_music_app/core/models/song.dart';
import 'package:flutter_music_app/core/models/playback_item.dart';
import 'package:flutter_music_app/features/player/providers/player_provider.dart';

class SongsSection extends StatefulWidget {
  final String title;
  final List<Song> songs;
  final int initialDisplayCount;

  const SongsSection({
    super.key,
    required this.title,
    required this.songs,
    this.initialDisplayCount = 10,
  });

  @override
  State<SongsSection> createState() => _SongsSectionState();
}

class _SongsSectionState extends State<SongsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.songs.isEmpty) return const SizedBox.shrink();

    final displayedSongs = _isExpanded
        ? widget.songs
        : widget.songs.take(widget.initialDisplayCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedSongs.length,
          itemBuilder: (context, index) {
            final song = displayedSongs[index];
            return _SongTile(song: song);
          },
        ),
        if (widget.songs.length > widget.initialDisplayCount)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _isExpanded ? 'Collapse' : 'Show more',
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SongTile extends ConsumerWidget {
  final Song song;

  const _SongTile({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentItem = ref.watch(playerNotifierProvider.select((s) => s.currentItem));
    final isCurrent = currentItem?.id == 'song_${song.id}';

    return ListTile(
      onTap: () {
        ref.read(playerNotifierProvider.notifier).playItem(
          PlaybackItem.fromSong(song),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(4),
          image: song.coverUrl != null
              ? DecorationImage(
                  image: NetworkImage(song.coverUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: song.coverUrl == null
            ? const Icon(LucideIcons.music, color: Colors.white24)
            : null,
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isCurrent ? const Color(0xFF1DB954) : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(LucideIcons.moreVertical, color: Colors.white54, size: 20),
        onPressed: () {
          // Show options menu
        },
      ),
    );
  }
}
