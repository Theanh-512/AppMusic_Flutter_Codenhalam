import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/repositories/search_repository.dart';
import '../../../core/models/search_result_group.dart';
import '../../../features/player/providers/player_provider.dart';
import '../../../core/models/playback_item.dart';
import '../../../shared/widgets/letter_avatar.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final searchResultsProvider = FutureProvider<SearchResultGroup>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return const SearchResultGroup();
  
  final repo = ref.read(searchRepositoryProvider);
  return repo.searchAll(query);
});

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context, ref, query),
            Expanded(
              child: query.isEmpty 
                ? _buildBrowsePlaceholder()
                : resultsAsync.when(
                    data: (results) => _buildSearchResults(context, ref, results),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white54))),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, WidgetRef ref, String query) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (val) => ref.read(searchQueryProvider.notifier).setQuery(val),
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'What do you want to listen to?',
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(LucideIcons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowsePlaceholder() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Browse all', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildCategoryCard('Podcasts', Colors.deepOrangeAccent),
              _buildCategoryCard('Live Events', Colors.purpleAccent),
              _buildCategoryCard('Made For You', Colors.blueAccent),
              _buildCategoryCard('New Releases', Colors.pinkAccent),
              _buildCategoryCard('Merch', Colors.tealAccent),
              _buildCategoryCard('Music', Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, WidgetRef ref, SearchResultGroup results) {
    if (results.isEmpty) {
      return const Center(child: Text('No results found.', style: TextStyle(color: Colors.white54)));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (results.songs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Songs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ...results.songs.map((s) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 48, height: 48,
                color: const Color(0xFF282828),
                child: s.coverUrl != null ? Image.network(s.coverUrl!, fit: BoxFit.cover) : const Icon(LucideIcons.music, color: Colors.white24),
              ),
            ),
            title: Text(s.title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(s.artist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () => ref.read(playerNotifierProvider.notifier).playItem(PlaybackItem.fromSong(s)),
          )),
        ],
        if (results.artists.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Artists', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ...results.artists.map((a) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF282828),
              backgroundImage: a.avatarUrl != null ? NetworkImage(a.avatarUrl!) : null,
              child: a.avatarUrl == null ? LetterAvatar(name: a.name, size: 48) : null,
            ),
            title: Text(a.name, style: const TextStyle(color: Colors.white)),
            onTap: () => context.go('/artist/${a.id}'),
          )),
        ],
        // Expand for albums and playlists similarly
      ],
    );
  }
}
