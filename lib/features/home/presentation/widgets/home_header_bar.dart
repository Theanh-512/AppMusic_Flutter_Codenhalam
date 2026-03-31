import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_filter_provider.dart';

class HomeHeaderBar extends ConsumerWidget {
  const HomeHeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(homeFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // User Avatar (Dummy for now)
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 16),

          // Filters based on state
          if (filter == HomeFilter.all) ...[
            _buildFilterChip('All', true, () {}),
            const SizedBox(width: 8),
            _buildFilterChip('Music', false, () {
              ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.music);
            }),
            const SizedBox(width: 8),
            _buildFilterChip('Podcasts', false, () {
              ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.podcasts);
            }),
          ] else if (filter == HomeFilter.music || filter == HomeFilter.musicFollowing) ...[
            // Joined chip mode typically involves a back button or an "X" to clear
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.all);
              },
            ),
            _buildFilterChip('Music', filter == HomeFilter.music, () {
              ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.music);
            }),
            const SizedBox(width: 8),
            _buildFilterChip('Following', filter == HomeFilter.musicFollowing, () {
              ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.musicFollowing);
            }),
          ] else if (filter == HomeFilter.podcasts || filter == HomeFilter.podcastsFollowing) ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.all);
              },
            ),
            _buildFilterChip('Podcasts', filter == HomeFilter.podcasts, () {
              ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.podcasts);
            }),
            const SizedBox(width: 8),
            _buildFilterChip('Following', filter == HomeFilter.podcastsFollowing, () {
              ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.podcastsFollowing);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1DB954) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
