import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/playback_item.dart';
import '../providers/player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final currentItem = playerState.currentItem;

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      alignment: Alignment.topCenter,
      child: currentItem == null
          ? const SizedBox.shrink()
          : MiniPlayerUI(
              item: currentItem,
              isPlaying: playerState.isPlaying,
              onTap: () => context.push('/player'),
              onPlayPause: () {
                if (playerState.isPlaying) {
                  ref.read(playerNotifierProvider.notifier).pause();
                } else {
                  ref.read(playerNotifierProvider.notifier).resume();
                }
              },
              onNext: () {
                // Future Implementation for skipping
              },
            ),
    );
  }
}

class MiniPlayerUI extends StatelessWidget {
  final PlaybackItem item;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const MiniPlayerUI({
    super.key,
    required this.item,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A), // Slightly lighter than background
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 4),
              blurRadius: 8.0,
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            // Cover Image
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4.0),
                image: item.coverUrl != null
                    ? DecorationImage(
                        image: NetworkImage(item.coverUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.coverUrl == null
                  ? Icon(
                      item.type == PlaybackItemType.podcast
                          ? LucideIcons.mic
                          : LucideIcons.music,
                      color: Colors.white54,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Controls
            IconButton(
              icon: Icon(isPlaying ? LucideIcons.pause : LucideIcons.play, color: Colors.white),
              iconSize: 28,
              onPressed: onPlayPause,
            ),
            IconButton(
              icon: const Icon(LucideIcons.skipForward, color: Colors.white),
              iconSize: 28,
              onPressed: onNext,
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

