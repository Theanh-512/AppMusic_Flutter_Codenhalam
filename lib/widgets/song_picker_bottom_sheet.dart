import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/supabase_provider.dart';
import '../models/song.dart';
import '../core/app_theme.dart';
import 'state_widgets.dart';

class SongPickerBottomSheet extends ConsumerStatefulWidget {
  final List<int> existingSongIds;
  final Function(List<int> selectedIds) onSongsSelected;

  const SongPickerBottomSheet({
    super.key,
    required this.existingSongIds,
    required this.onSongsSelected,
  });

  @override
  ConsumerState<SongPickerBottomSheet> createState() => _SongPickerBottomSheetState();
}

class _SongPickerBottomSheetState extends ConsumerState<SongPickerBottomSheet> {
  final List<int> _selectedIds = [];
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSongsAsync = ref.watch(_allSongsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Huỷ', style: TextStyle(color: AppTheme.textSecondary)),
                ),
                Text(
                  _selectedIds.isEmpty ? 'Thêm bài hát' : 'Đã chọn ${_selectedIds.length} bài',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () {
                          widget.onSongsSelected(_selectedIds);
                          Navigator.pop(context);
                        },
                  child: Text(
                    'Thêm',
                    style: TextStyle(
                      color: _selectedIds.isEmpty ? AppTheme.textSecondary : AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Tìm bài hát...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Song List
          Expanded(
            child: allSongsAsync.when(
              data: (songs) {
                final filtered = songs.where((s) {
                  // Exclude already existing songs
                  if (widget.existingSongIds.contains(s.id)) return false;
                  // Search query
                  if (_searchQuery.isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  return s.title.toLowerCase().contains(q) ||
                      (s.artistName?.toLowerCase().contains(q) ?? false);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: AppEmptyState(
                    icon: LucideIcons.searchX, 
                    title: 'Không tìm thấy bài nào',
                    message: 'Hãy thử tìm kiếm với từ khoá khác.',
                  ));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.only(bottom: 32),
                  itemBuilder: (context, index) {
                    final song = filtered[index];
                    final isSelected = _selectedIds.contains(song.id);

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: song.coverUrl != null
                            ? CachedNetworkImage(
                                imageUrl: song.coverUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : Container(width: 48, height: 48, color: AppTheme.surface),
                      ),
                      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(song.artistName ?? 'Chưa biết', maxLines: 1),
                      trailing: Checkbox(
                        value: isSelected,
                        activeColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selectedIds.add(song.id);
                            } else {
                              _selectedIds.remove(song.id);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(song.id);
                          } else {
                            _selectedIds.add(song.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: AppLoadingIndicator()),
              error: (e, __) => Center(child: Text('Lỗi: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

final _allSongsProvider = FutureProvider<List<Song>>((ref) async {
  return ref.watch(songRepositoryProvider).fetchAllSongs();
});
