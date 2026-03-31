import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_music_app/core/models/podcast_channel.dart';
import 'package:flutter_music_app/features/auth/providers/auth_provider.dart';
import 'package:flutter_music_app/shared/widgets/letter_avatar.dart';

class FollowedChannelsRow extends ConsumerWidget {
  final List<PodcastChannel> channels;
  final bool isLoading;

  const FollowedChannelsRow({
    super.key,
    required this.channels,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            'Podcasts you follow',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        if (!isAuthenticated)
          _buildGuestPlaceholder(context)
        else if (isLoading)
          _buildLoadingState()
        else if (channels.isEmpty)
          _buildEmptyState()
        else
          _buildChannelList(),
      ],
    );
  }

  Widget _buildGuestPlaceholder(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.mic, color: Colors.white54, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscribe to channels',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Log in to see updates from your favorite podcasts.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/login'),
            child: const Text('Login', style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      child: const Column(
        children: [
          Icon(LucideIcons.mic, color: Colors.white10, size: 48),
          SizedBox(height: 12),
          Text(
            "You haven't subscribed to any channels yet.",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 110,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildChannelList() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 8),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.push('/channel/${channel.id}'),
              child: SizedBox(
                width: 80,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF282828),
                      backgroundImage: channel.avatarUrl != null
                          ? NetworkImage(channel.avatarUrl!)
                          : null,
                      child: channel.avatarUrl == null
                          ? LetterAvatar(name: channel.name, size: 70)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      channel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
