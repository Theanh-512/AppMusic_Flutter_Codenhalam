import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../providers/player_provider.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerNotifierProvider);
    final item = state.currentItem;

    return Scaffold(
      backgroundColor: Colors.black, // Typical immersive player color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronDown),
          onPressed: () => context.pop(),
        ),
        title: const Text('Now Playing', style: TextStyle(fontSize: 12)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.moreVertical),
            onPressed: () {},
          ),
        ],
      ),
      body: item == null 
        ? const Center(child: Text('Nothing is playing')) 
        : _buildPlayerBody(context, ref, state),
    );
  }

  Widget _buildPlayerBody(BuildContext context, WidgetRef ref, PlayerStateData state) {
    final item = state.currentItem!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Artwork
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.0),
                image: item.coverUrl != null
                    ? DecorationImage(
                        image: NetworkImage(item.coverUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.coverUrl == null ? const Icon(LucideIcons.music, size: 100, color: Colors.white24) : null,
            ),
          ),
          const SizedBox(height: 32),
          
          // Metadata row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.heart),
                onPressed: () {}, // Handle like toggle via user interactions provider
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Progress Slider
          Slider(
            value: state.position.inSeconds.toDouble(),
            max: state.totalDuration.inSeconds > 0 ? state.totalDuration.inSeconds.toDouble() : 1.0,
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
            onChanged: (val) {
              ref.read(playerNotifierProvider.notifier).seek(Duration(seconds: val.toInt()));
            },
          ),
          
          // Time layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(state.position), style: const TextStyle(fontSize: 12, color: Colors.white70)),
              Text(_formatDuration(state.totalDuration), style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(LucideIcons.shuffle), onPressed: () {}),
              IconButton(icon: const Icon(LucideIcons.skipBack), iconSize: 36, onPressed: () {}),
              Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: IconButton(
                  icon: Icon(state.isPlaying ? LucideIcons.pause : LucideIcons.play),
                  iconSize: 48,
                  color: Colors.black,
                  onPressed: () {
                    if (state.isPlaying) {
                      ref.read(playerNotifierProvider.notifier).pause();
                    } else {
                      ref.read(playerNotifierProvider.notifier).resume();
                    }
                  },
                ),
              ),
              IconButton(icon: const Icon(LucideIcons.skipForward), iconSize: 36, onPressed: () {}),
              IconButton(icon: const Icon(LucideIcons.repeat), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes;
    final sec = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
