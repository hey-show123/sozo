import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tutorial_avatar_screen.dart';

class TutorialUsernameScreen extends ConsumerStatefulWidget {
  const TutorialUsernameScreen({super.key});

  @override
  ConsumerState<TutorialUsernameScreen> createState() => _TutorialUsernameScreenState();
}

class _TutorialUsernameScreenState extends ConsumerState<TutorialUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('profiles')
            .upsert({
              'id': user.id,
              'username': _usernameController.text.trim(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', user.id);
      }

      if (!mounted) return;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TutorialAvatarScreen(),
        ),
      );
    } catch (e) {
      print('Error saving username: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                value: 0.2, // 1/5ステップ
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 40),
              
              // タイトル
              const Text(
                'あなたのお名前を\n教えてください',
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
                'アプリ内で表示される名前です',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              
              // フォーム
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _usernameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '例: 太郎',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.shade600,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  style: const TextStyle(fontSize: 18),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '名前を入力してください';
                    }
                    if (value.trim().length < 2) {
                      return '2文字以上で入力してください';
                    }
                    if (value.trim().length > 20) {
                      return '20文字以内で入力してください';
                    }
                    return null;
                  },
                ),
              ),
              
              const Spacer(),
              
              // 次へボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveUsername,
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