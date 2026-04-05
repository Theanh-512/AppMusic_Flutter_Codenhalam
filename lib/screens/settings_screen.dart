import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'dart:io' as io;

import '../core/app_theme.dart';
import '../core/app_ui_utils.dart';
import '../providers/auth_provider.dart';
import '../providers/supabase_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  fp.PlatformFile? _newAvatarFile;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    if (profile != null) {
      _nameController.text = profile.displayName ?? '';
    }
  }

  Future<void> _pickAvatar() async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.image,
      withData: kIsWeb,
    );
    if (result != null) {
      setState(() => _newAvatarFile = result.files.first as fp.PlatformFile?);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authStateProvider);
      final dio = ref.read(dioProvider);

      final formData = FormData.fromMap({
        'displayName': _nameController.text,
        if (_newAvatarFile != null)
          'avatarFile': kIsWeb
              ? MultipartFile.fromBytes(_newAvatarFile!.bytes!, filename: _newAvatarFile!.name)
              : await MultipartFile.fromFile(_newAvatarFile!.path!, filename: _newAvatarFile!.name),
      });

      await dio.put('auth/profile/${user!.id}', data: formData);
      
      // Refresh profile
      ref.invalidate(profileProvider);
      if (mounted) context.showSuccess('Cập nhật hồ sơ thành công');
    } catch (e) {
      if (mounted) context.showError('Lỗi cập nhật: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      context.showError('Vui lòng nhập đầy đủ mật khẩu');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authStateProvider);
      final dio = ref.read(dioProvider);

      await dio.put('auth/change-password/${user!.id}', data: {
        'oldPassword': _oldPasswordController.text,
        'newPassword': _newPasswordController.text,
      });

      _oldPasswordController.clear();
      _newPasswordController.clear();
      if (mounted) context.showSuccess('Đổi mật khẩu thành công');
    } catch (e) {
      if (mounted) context.showError('Lỗi đổi mật khẩu: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt & Quyền riêng tư')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Profile
            const Text('Hồ sơ người dùng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _newAvatarFile != null
                        ? (kIsWeb ? MemoryImage(_newAvatarFile!.bytes!) : FileImage(io.File(_newAvatarFile!.path!)) as ImageProvider)
                        : (profile?.avatarUrl != null ? NetworkImage(context.fullImageUrl(profile!.avatarUrl!)) : null),
                    child: (profile?.avatarUrl == null && _newAvatarFile == null) ? const Icon(LucideIcons.user, size: 40) : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(LucideIcons.camera, size: 18, color: Colors.black),
                        onPressed: _pickAvatar,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên hiển thị', prefixIcon: Icon(LucideIcons.user)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: const Text('Lưu thay đổi hồ sơ'),
              ),
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            // Section: Password
            const Text('Bảo mật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu cũ', prefixIcon: Icon(LucideIcons.lock)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới', prefixIcon: Icon(LucideIcons.shieldCheck)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: const Text('Đổi mật khẩu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
