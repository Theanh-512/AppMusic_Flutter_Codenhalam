import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_music_app/core/models/podcast.dart';
import 'package:flutter_music_app/core/models/playback_item.dart';
import 'package:flutter_music_app/features/player/providers/player_provider.dart';

class PodcastsSection extends StatefulWidget {
  final String title;
  final List<Podcast> podcasts;
  final int initialDisplayCount;

  const PodcastsSection({
    super.key,
    required this.title,
    required this.podcasts,
    this.initialDisplayCount = 5,
  });

  @override
  State<PodcastsSection> createState() => _PodcastsSectionState();
}

class _PodcastsSectionState extends State<PodcastsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.podcasts.isEmpty) return const SizedBox.shrink();

    final displayedPodcasts = _isExpanded
        ? widget.podcasts
        : widget.podcasts.take(widget.initialDisplayCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedPodcasts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            return _PodcastCard(podcast: displayedPodcasts[index]);
          },
        ),
        if (widget.podcasts.length > widget.initialDisplayCount)
          Padding(
            padding: const EdgeInsets.all(16.0),
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

class _PodcastCard extends ConsumerWidget {
  final Podcast podcast;

  const _PodcastCard({required this.podcast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat.compact();
    final listens = formatter.format(podcast.listenCount);

    return InkWell(
      onTap: () {
        // Tapping a podcast card triggers playback using generic channel name for now
        ref.read(playerNotifierProvider.notifier).playItem(
          PlaybackItem.fromPodcast(podcast, 'Podcast Channel'),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Cover Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: const Color(0xFF282828),
                      child: podcast.coverUrl != null
                          ? Image.network(
                              podcast.coverUrl!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(LucideIcons.mic, color: Colors.white24, size: 48),
                    ),
                    // Play indication overlay
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.play, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title and Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        podcast.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Podcast Channel • $listens listens',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.moreVertical, color: Colors.white54, size: 20),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
