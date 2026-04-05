import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/song.dart';
import '../providers/favorite_provider.dart';
import '../providers/download_provider.dart';
import '../widgets/download_status_widgets.dart';
import '../core/app_theme.dart';
import '../core/app_ui_utils.dart';
import '../providers/player_provider.dart';

class SongListItem extends ConsumerWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;
  final Widget? trailing;

  const SongListItem({
    super.key,
    required this.song,
    required this.onTap,
    this.onMoreTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLikedAsync = ref.watch(isLikedProvider(song.id));
    final isDownloaded = ref.watch(downloadProvider.notifier).isDownloaded(song.id);
    final progress = ref.watch(downloadProvider.notifier).getProgress(song.id);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: _buildCoverImage(context, song.coverUrl),
      ),

      title: Text(
        song.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.artistName ?? 'Unknown Artist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          if (isDownloaded) ...[
            const SizedBox(height: 4),
            const OfflineBadge(),
          ],
        ],
      ),
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (progress != null || isDownloaded)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DownloadStatusWidget(
                    progress: progress,
                    isDownloaded: isDownloaded,
                    onRetry: () => ref.read(downloadProvider.notifier).startDownload(song),
                  ),
                ),
              isLikedAsync.when(
                data: (isLiked) => IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? const Color(0xFF1DB954) : AppTheme.textSecondary,
                    size: 22,
                  ),
                  onPressed: () => ref.read(favoriteNotifierProvider.notifier).toggleLike(context, song.id, isLiked),
                ),
                loading: () => const SizedBox(width: 48, height: 48, child: Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2))),
                error: (_, __) => const SizedBox.shrink(),
              ),
                IconButton(
                  icon: const Icon(LucideIcons.moreVertical, size: 20),
                  onPressed: () => _showMoreOptions(context, ref),
                ),
            ],
          ),
      onTap: onTap,
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.l)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.play),
              title: const Text('Phát tiếp theo'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(audioHandlerProvider).playNext(song);
                context.showSuccess('Sẽ phát bài này tiếp theo');
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.listMusic),
              title: const Text('Thêm vào hàng chờ'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(audioHandlerProvider).addToQueue(song);
                context.showSuccess('Đã thêm vào hàng chờ');
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(LucideIcons.plusSquare),
              title: const Text('Thêm vào danh sách phát'),
              onTap: () {
                Navigator.pop(ctx);
                // Trigger add to playlist flow
                context.showInfo('Bạn có thể thêm vào playlist từ màn hình "Thư viện"');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context, String? url) {
    if (url == null) return _buildPlaceholder();
    
    if (url.startsWith('file://')) {
      final path = url.replaceFirst('file://', '');
      return Image.file(
        File(path),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    
    final fullUrl = context.fullImageUrl(url);
    return CachedNetworkImage(
      imageUrl: fullUrl,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey.shade800,
      child: const Icon(LucideIcons.music, color: Colors.white54),
    );
  }
}


