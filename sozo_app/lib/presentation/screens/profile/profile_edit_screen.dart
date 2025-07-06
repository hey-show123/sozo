import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _displayNameController = TextEditingController();
  File? _imageFile;
  String? _currentAvatarUrl;
  bool _isLoading = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 現在のプロフィール情報を取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(profileNotifierProvider).value;
      if (profile != null) {
        _displayNameController.text = profile.displayName ?? '';
        _currentAvatarUrl = profile.avatarUrl;
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('画像の選択に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('カメラで撮影'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('ギャラリーから選択'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_currentAvatarUrl != null || _imageFile != null) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('画像を削除', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _imageFile = null;
                      _currentAvatarUrl = null;
                    });
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? avatarUrl = _currentAvatarUrl;

      // 新しい画像が選択されている場合はアップロード
      if (_imageFile != null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw Exception('ユーザーが見つかりません');

        // ファイル名を生成
        final fileName = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // ファイルをアップロード
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(
              fileName, 
              _imageFile!,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        // 公開URLを取得
        avatarUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);
      }

      // プロフィールを更新
      await ref.read(profileNotifierProvider.notifier).updateProfile(
        displayName: _displayNameController.text.trim(),
        avatarUrl: avatarUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールを更新しました'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 現在のアバター
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _imageFile != null
                              ? Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                )
                              : _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                  ? Image.network(
                                      _currentAvatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey[600],
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'タップして写真を変更',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 表示名
              const Text(
                '表示名',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  hintText: 'ニックネームを入力',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '他のユーザーに表示される名前です',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '保存',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('エラーが発生しました: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(profileNotifierProvider);
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 