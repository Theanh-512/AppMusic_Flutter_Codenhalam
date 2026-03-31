import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/letter_avatar.dart';

enum HomeFilter { all, music, podcasts }

class HomeFilterBar extends ConsumerWidget {
  final HomeFilter currentFilter;
  final bool showFollowing;
  final ValueChanged<HomeFilter> onFilterChanged;
  final ValueChanged<bool> onFollowingChanged;
  final VoidCallback onAvatarTap;

  const HomeFilterBar({
    super.key,
    required this.currentFilter,
    required this.showFollowing,
    required this.onFilterChanged,
    required this.onFollowingChanged,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // User Avatar
            GestureDetector(
              onTap: onAvatarTap,
              child: LetterAvatar(
                size: 32,
                name: user?.userMetadata?['display_name'] ?? 
                      (user?.email?.split('@')[0] ?? 'Guest'),
              ),
            ),
            const SizedBox(width: 12),

            // All Chip
            _FilterChip(
              label: 'All',
              isActive: currentFilter == HomeFilter.all,
              onTap: () {
                onFilterChanged(HomeFilter.all);
                onFollowingChanged(false);
              },
            ),
            const SizedBox(width: 8),

            // Music Chip / Joined Chip
            if (currentFilter == HomeFilter.music)
              _JoinedChip(
                mainLabel: 'Music',
                subLabel: 'Following',
                isSubActive: showFollowing,
                onMainTap: () {
                  onFilterChanged(HomeFilter.all);
                  onFollowingChanged(false);
                },
                onSubTap: () => onFollowingChanged(!showFollowing),
              )
            else
              _FilterChip(
                label: 'Music',
                isActive: false,
                onTap: () => onFilterChanged(HomeFilter.music),
              ),
            const SizedBox(width: 8),

            // Podcasts Chip / Joined Chip
            if (currentFilter == HomeFilter.podcasts)
              _JoinedChip(
                mainLabel: 'Podcasts',
                subLabel: 'Following',
                isSubActive: showFollowing,
                onMainTap: () {
                  onFilterChanged(HomeFilter.all);
                  onFollowingChanged(false);
                },
                onSubTap: () => onFollowingChanged(!showFollowing),
              )
            else
              _FilterChip(
                label: 'Podcasts',
                isActive: false,
                onTap: () => onFilterChanged(HomeFilter.podcasts),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0xFF282828),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _JoinedChip extends StatelessWidget {
  final String mainLabel;
  final String subLabel;
  final bool isSubActive;
  final VoidCallback onMainTap;
  final VoidCallback onSubTap;

  const _JoinedChip({
    required this.mainLabel,
    required this.subLabel,
    required this.isSubActive,
    required this.onMainTap,
    required this.onSubTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close Icon + Main Label
          GestureDetector(
            onTap: onMainTap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.close, size: 16, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(
                    mainLabel,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sub Label (Following)
          GestureDetector(
            onTap: onSubTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSubActive ? Colors.white24 : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
              ),
              child: Text(
                subLabel,
                style: TextStyle(
                  color: isSubActive ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
