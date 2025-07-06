import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tutorial_daily_goal_screen.dart';

class TutorialLevelScreen extends ConsumerStatefulWidget {
  const TutorialLevelScreen({super.key});

  @override
  ConsumerState<TutorialLevelScreen> createState() => _TutorialLevelScreenState();
}

class _TutorialLevelScreenState extends ConsumerState<TutorialLevelScreen> {
  String? _selectedLevel;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _levels = [
    {
      'id': 'beginner',
      'title': '初級',
      'description': '簡単な挨拶や自己紹介ができる',
      'examples': '・Hello, Nice to meet you\n・My name is...\n・Thank you',
      'color': Colors.green,
    },
    {
      'id': 'elementary',
      'title': '初中級',
      'description': '日常的な簡単な会話ができる',
      'examples': '・買い物での会話\n・道を尋ねる\n・簡単な質問と回答',
      'color': Colors.blue,
    },
    {
      'id': 'intermediate',
      'title': '中級',
      'description': '身近な話題について話せる',
      'examples': '・趣味について話す\n・意見を述べる\n・過去の経験を話す',
      'color': Colors.orange,
    },
    {
      'id': 'advanced',
      'title': '上級',
      'description': '複雑な話題でも議論できる',
      'examples': '・ビジネスでの交渉\n・抽象的な話題\n・専門的な内容',
      'color': Colors.purple,
    },
  ];

  Future<void> _saveLevel() async {
    if (_selectedLevel == null) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('user_settings')
            .upsert({
              'user_id': user.id,
              'english_level': _selectedLevel,
            });
      }

      if (!mounted) return;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TutorialDailyGoalScreen(),
        ),
      );
    } catch (e) {
      print('Error saving level: $e');
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
                value: 0.8, // 4/5ステップ
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 40),
              
              // タイトル
              const Text(
                '英語レベルを\n選んでください',
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
                'あなたのレベルに合わせて調整します',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              
              // レベルリスト
              Expanded(
                child: ListView.builder(
                  itemCount: _levels.length,
                  itemBuilder: (context, index) {
                    final level = _levels[index];
                    final isSelected = _selectedLevel == level['id'];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedLevel = level['id'];
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? level['color'].withOpacity(0.1)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? level['color']
                                  : Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: level['color'].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      level['title'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: level['color'],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: level['color'],
                                      size: 24,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                level['description'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                level['examples'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 次へボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || _selectedLevel == null) ? null : _saveLevel,
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