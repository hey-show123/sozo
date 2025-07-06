import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tutorial_reminder_screen.dart';

class TutorialLessonGoalScreen extends ConsumerStatefulWidget {
  const TutorialLessonGoalScreen({super.key});

  @override
  ConsumerState<TutorialLessonGoalScreen> createState() => _TutorialLessonGoalScreenState();
}

class _TutorialLessonGoalScreenState extends ConsumerState<TutorialLessonGoalScreen> {
  int _selectedLessons = 2; // デフォルト2レッスン
  bool _isLoading = false;

  void _incrementLessons() {
    if (_selectedLessons < 10) {
      setState(() {
        _selectedLessons++;
      });
    }
  }

  void _decrementLessons() {
    if (_selectedLessons > 1) {
      setState(() {
        _selectedLessons--;
      });
    }
  }

  Future<void> _saveLessonGoal() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('user_settings')
            .upsert({
              'user_id': user.id,
              'daily_lesson_goal': _selectedLessons,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);
      }

      if (!mounted) return;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TutorialReminderScreen(),
        ),
      );
    } catch (e) {
      print('Error saving lesson goal: $e');
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
                value: 0.9, // 4.5/5ステップ
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 40),
              
              // タイトル
              const Text(
                '1日のレッスン数目標を\n設定しましょう',
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
                '継続しやすい数から始めましょう',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              
              // レッスン数選択
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school,
                        size: 48,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _decrementLessons,
                            icon: Icon(
                              Icons.remove_circle_outline,
                              size: 36,
                              color: _selectedLessons > 1
                                  ? Colors.green.shade600
                                  : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Column(
                            children: [
                              Text(
                                '$_selectedLessons',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              Text(
                                'レッスン',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            onPressed: _incrementLessons,
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 36,
                              color: _selectedLessons < 10
                                  ? Colors.green.shade600
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '毎日の目標',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // おすすめ表示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '初心者は1-2レッスンから始めることをおすすめします',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // スキップボタン
              TextButton(
                onPressed: _isLoading ? null : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TutorialReminderScreen(),
                    ),
                  );
                },
                child: Text(
                  'あとで設定する',
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
                  onPressed: _isLoading ? null : _saveLessonGoal,
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