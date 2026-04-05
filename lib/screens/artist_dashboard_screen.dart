import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';

import '../core/api_client.dart'; // Ensure correct path
import '../core/app_theme.dart';
import '../core/app_ui_utils.dart';
import '../models/song.dart';
import '../models/artist.dart';
import '../providers/auth_provider.dart';
import '../providers/supabase_provider.dart';
import '../widgets/state_widgets.dart';

final apiClientInstanceProvider = Provider<Dio>((ref) {
  return ref.watch(apiClientProvider).instance;
});

class ArtistDashboardScreen extends ConsumerStatefulWidget {
  const ArtistDashboardScreen({super.key});

  @override
  ConsumerState<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends ConsumerState<ArtistDashboardScreen> {
  Artist? _artistProfile;
  List<Song> _mySongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = ref.read(authStateProvider);
    if (user == null) return;

    try {
      final dio = ref.read(apiClientInstanceProvider);
      
      // 1. Get artist profile
      final profileRes = await dio.get('artists/me/${user.id}');
      _artistProfile = Artist.fromJson(profileRes.data);
      
      // 2. Get artist songs
      if (_artistProfile != null) {
        final songsRes = await dio.get('artists/${_artistProfile!.id}/songs');
        setState(() {
          _mySongs = (songsRes.data as List).map((e) => Song.fromJson(e)).toList();
        });
      }
    } catch (e) {
      print('Error loading artist data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSong(int songId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài hát?'),
        content: const Text('Bạn có chắc chắn muốn xóa bài hát này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final user = ref.read(authStateProvider);
      final dio = ref.read(apiClientInstanceProvider);
      await dio.delete('songs/$songId', queryParameters: {'userId': user?.id});
      context.showSuccess('Đã xóa bài hát');
      _loadData();
    } catch (e) {
      context.showError('Lỗi khi xóa: $e');
    }
  }

  Future<void> _editSong(Song song) async {
    final controller = TextEditingController(text: song.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa bài hát'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Tên bài hát'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Lưu')),
        ],
      ),
    );

    if (newTitle == null || newTitle.isEmpty || newTitle == song.title) return;

    try {
      final user = ref.read(authStateProvider);
      final dio = ref.read(apiClientInstanceProvider);
      await dio.put('songs/${song.id}', data: {
        'userId': user?.id,
        'title': newTitle,
      });
      context.showSuccess('Đã cập nhật bài hát');
      _loadData();
    } catch (e) {
      context.showError('Lỗi khi cập nhật: $e');
    }
  }

  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _UploadSongBottomSheet(onSuccess: _loadData),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_artistProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nghệ sĩ')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.userX, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              const Text('Bạn chưa có hồ sơ nghệ sĩ'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.showInfo('Tính năng nâng cấp đang phát triển'),
                child: const Text('Trở thành Nghệ sĩ'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_artistProfile!.name),
              background: _artistProfile!.coverUrl != null
                  ? Image.network(context.fullImageUrl(_artistProfile!.coverUrl!), fit: BoxFit.cover)
                  : Container(color: AppTheme.primary.withOpacity(0.2)),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bài hát của bạn',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showUploadDialog,
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('Phát hành mới'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          if (_mySongs.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('Bạn chưa phát hành bài hát nào')),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = _mySongs[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        context.fullImageUrl(song.coverUrl),
                        width: 48, height: 48, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(LucideIcons.music),
                      ),
                    ),
                    title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: ${song.id}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.edit3, size: 18),
                          onPressed: () => _editSong(song),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                          onPressed: () => _deleteSong(song.id),
                        ),
                      ],
                    ),
                  );
                },
                childCount: _mySongs.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _UploadSongBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const _UploadSongBottomSheet({required this.onSuccess});

  @override
  ConsumerState<_UploadSongBottomSheet> createState() => _UploadSongBottomSheetState();
}

class _UploadSongBottomSheetState extends ConsumerState<_UploadSongBottomSheet> {
  final _titleController = TextEditingController();
  fp.PlatformFile? _audioFile;
  fp.PlatformFile? _coverFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickAudio() async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.audio,
      withData: kIsWeb,
    );
    if (result != null) setState(() => _audioFile = result.files.first as fp.PlatformFile?);
  }

  Future<void> _pickCover() async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.image,
      withData: kIsWeb,
    );
    if (result != null) setState(() => _coverFile = result.files.first as fp.PlatformFile?);
  }

  Future<void> _upload() async {
    if (_titleController.text.isEmpty || _audioFile == null) {
      context.showError('Vui lòng nhập tên và chọn file nhạc');
      return;
    }

    setState(() => _isUploading = true);
    try {
      final user = ref.read(authStateProvider);
      final dio = ref.read(apiClientInstanceProvider);

      final formData = FormData.fromMap({
        'userId': user!.id,
        'title': _titleController.text,
        'audioFile': kIsWeb 
            ? MultipartFile.fromBytes(_audioFile!.bytes!, filename: _audioFile!.name)
            : await MultipartFile.fromFile(_audioFile!.path!, filename: _audioFile!.name),
        if (_coverFile != null)
          'coverFile': kIsWeb 
              ? MultipartFile.fromBytes(_coverFile!.bytes!, filename: _coverFile!.name)
              : await MultipartFile.fromFile(_coverFile!.path!, filename: _coverFile!.name),
      });

      await dio.post(
        'artists/release', 
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            setState(() {
              _uploadProgress = sent / total;
            });
          }
        },
      );
      
      if (mounted) {
        Navigator.pop(context);
        context.showSuccess('Phát hành bài hát thành công!');
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) context.showError('Lỗi tải lên: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Phát hành bài hát mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Tên bài hát'),
          ),
          const SizedBox(height: 16),
          
          ListTile(
            leading: const Icon(LucideIcons.music),
            title: Text(_audioFile?.name ?? 'Chọn file nhạc (MP3, WAV)'),
            tileColor: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: _pickAudio,
          ),
          const SizedBox(height: 12),
          
          ListTile(
            leading: const Icon(LucideIcons.image),
            title: Text(_coverFile?.name ?? 'Chọn ảnh bìa (Tùy chọn)'),
            tileColor: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: _pickCover,
          ),
          if (_isUploading) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.white10,
                color: AppTheme.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang tải lên: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: _isUploading ? null : _upload,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: _isUploading ? Colors.grey : AppTheme.primary,
              foregroundColor: Colors.black,
            ),
            child: _isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Text('Phát hành ngay', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
