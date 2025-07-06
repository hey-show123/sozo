import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tutorial_goal_screen.dart';

class TutorialAvatarScreen extends ConsumerStatefulWidget {
  const TutorialAvatarScreen({super.key});

  @override
  ConsumerState<TutorialAvatarScreen> createState() => _TutorialAvatarScreenState();
}

class _TutorialAvatarScreenState extends ConsumerState<TutorialAvatarScreen> {
  File? _imageFile;
  bool _isLoading = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 60,
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

  Future<void> _uploadAvatar() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('ユーザーが見つかりません');

      String? avatarUrl;

      if (_imageFile != null) {
        // 古いアバターを削除する前に新しいアバターをアップロード
        final fileName = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // ファイルをアップロード（上書きオプション付き）
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

      // プロフィールを更新（upsertで確実に保存）
      await Supabase.instance.client
          .from('profiles')
          .update({
            if (avatarUrl != null) 'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      if (!mounted) return;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TutorialGoalScreen(),
        ),
      );
    } catch (e) {
      print('Error uploading avatar: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プログレスバー
              LinearProgressIndicator(
                value: 0.4, // 2/5ステップ
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 40),
              
              // タイトル
              const Text(
                'プロフィール画像を\n設定しましょう',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              
              // 説明
              Text(
                'あなたらしい画像を選んでください',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              
              // 画像選択エリア
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 3,
                          ),
                        ),
                        child: _imageFile != null
                            ? ClipOval(
                                child: Image.file(
                                  _imageFile!,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade600,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // スキップボタン
              TextButton(
                onPressed: _isLoading ? null : _uploadAvatar,
                child: Text(
                  'スキップ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // 次へボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || _imageFile == null) ? null : _uploadAvatar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                          '次へ',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
} 