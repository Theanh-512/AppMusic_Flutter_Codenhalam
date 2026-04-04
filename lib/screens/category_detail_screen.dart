import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_theme.dart';
import '../providers/home_providers.dart';
import '../core/player_utils.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final String title;
  final String type; // genre, mood, hashtag

  const CategoryDetailScreen({super.key, required this.title, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(categorySongsProvider((type: type, name: title)));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                type.toUpperCase() == 'HASHTAG' ? '#$title' : title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primary.withOpacity(0.8),
                      AppTheme.background,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    type == 'hashtag' ? LucideIcons.hash : LucideIcons.layers,
                    size: 80,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          songsAsync.when(
            data: (songs) {
              if (songs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.music, size: 64, color: Colors.white24),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có bài hát nào cho chuyên mục này',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = songs[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white10,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: song.coverUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: song.coverUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: Colors.white12),
                                  errorWidget: (_, __, ___) => const Icon(LucideIcons.music, color: Colors.white54),
                                )
                              : const Icon(LucideIcons.music, color: Colors.white54),
                        ),
                        title: Text(
                          song.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artistName ?? 'Nghệ sĩ ẩn danh',
                          style: const TextStyle(color: Colors.white54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          // Play the category playlist
                          context.playOrNavigate(ref, song, songs, initialIndex: index);
                        },
                      );
                    },
                    childCount: songs.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text('Lỗi tải dữ liệu: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
