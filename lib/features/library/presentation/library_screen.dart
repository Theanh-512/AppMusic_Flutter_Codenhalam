import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../providers/library_filter_provider.dart';
import '../providers/library_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/letter_avatar.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(libraryFilterProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, user),
            _buildFilterChips(ref, filter),
            Expanded(
              child: _buildLibraryContent(context, ref, filter, user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: user != null
              ? CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF282828),
                  child: LetterAvatar(name: user.userMetadata?['display_name'] ?? 'U', size: 36),
                )
              : const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  child: Icon(LucideIcons.user, size: 20, color: Colors.white),
                ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Your Library',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.search, color: Colors.white),
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus, color: Colors.white),
            onPressed: () {
              // Same as bottom nav create
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, LibraryFilter currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildChip('Playlists', currentFilter == LibraryFilter.playlists, () {
            ref.read(libraryFilterProvider.notifier).setFilter(
              currentFilter == LibraryFilter.playlists ? LibraryFilter.all : LibraryFilter.playlists
            );
          }),
          const SizedBox(width: 8),
          _buildChip('Artists', currentFilter == LibraryFilter.artists, () {
            ref.read(libraryFilterProvider.notifier).setFilter(
              currentFilter == LibraryFilter.artists ? LibraryFilter.all : LibraryFilter.artists
            );
          }),
          const SizedBox(width: 8),
          _buildChip('Podcasts', currentFilter == LibraryFilter.podcasts, () {
            ref.read(libraryFilterProvider.notifier).setFilter(
              currentFilter == LibraryFilter.podcasts ? LibraryFilter.all : LibraryFilter.podcasts
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1DB954) : const Color(0xFF282828),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryContent(BuildContext context, WidgetRef ref, LibraryFilter filter, user) {
    final playlistsAsync = ref.watch(libraryPlaylistsProvider);
    final artistsAsync = ref.watch(libraryArtistsProvider);
    final podcastsAsync = ref.watch(libraryPodcastsProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        if (filter == LibraryFilter.all || filter == LibraryFilter.playlists) 
          _buildLikedSongsTile(context),

        // User Playlists
        if (filter == LibraryFilter.all || filter == LibraryFilter.playlists)
          playlistsAsync.when(
            data: (playlists) => Column(
              children: playlists.map((p) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF282828),
                    borderRadius: BorderRadius.circular(4),
                    image: p.coverUrl != null ? DecorationImage(image: NetworkImage(p.coverUrl!), fit: BoxFit.cover) : null,
                  ),
                  child: p.coverUrl == null ? const Icon(LucideIcons.music, color: Colors.white24) : null,
                ),
                title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text('Playlist • ${p.userId == user?.id ? 'You' : 'Curated'}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () => context.go('/playlist/${p.id}'),
              )).toList(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
          ),

        // Artists
        if (filter == LibraryFilter.all || filter == LibraryFilter.artists)
          artistsAsync.when(
            data: (artists) => Column(
              children: artists.map((a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF282828),
                  backgroundImage: a.avatarUrl != null ? NetworkImage(a.avatarUrl!) : null,
                  child: a.avatarUrl == null ? LetterAvatar(name: a.name, size: 50) : null,
                ),
                title: Text(a.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Artist', style: TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () => context.go('/artist/${a.id}'),
              )).toList(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
          ),

        // Podcasts
        if (filter == LibraryFilter.all || filter == LibraryFilter.podcasts)
          podcastsAsync.when(
            data: (channels) => Column(
              children: channels.map((c) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 50, height: 50,
                    color: const Color(0xFF282828),
                    child: c.avatarUrl != null ? Image.network(c.avatarUrl!, fit: BoxFit.cover) : const Icon(LucideIcons.mic, color: Colors.white24),
                  ),
                ),
                title: Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Podcast • Channel', style: TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () => context.go('/channel/${c.id}'),
              )).toList(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
          ),
      ],
    );
  }

  Widget _buildLikedSongsTile(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF450AF5), Color(0xFFC4EFD9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(LucideIcons.heart, color: Colors.white, size: 24),
      ),
      title: const Text('Liked Songs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: const Text('Playlist • 0 songs', style: TextStyle(color: Colors.white54, fontSize: 12)),
      onTap: () => context.go('/library/liked-songs'),
    );
  }
}
