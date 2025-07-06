import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tutorial_lesson_goal_screen.dart';

class TutorialDailyGoalScreen extends ConsumerStatefulWidget {
  const TutorialDailyGoalScreen({super.key});

  @override
  ConsumerState<TutorialDailyGoalScreen> createState() => _TutorialDailyGoalScreenState();
}

class _TutorialDailyGoalScreenState extends ConsumerState<TutorialDailyGoalScreen> {
  int _selectedMinutes = 30; // デフォルト30分
  bool _isLoading = false;
  
  final List<int> _minuteOptions = [15, 30, 45, 60, 90, 120];

  Future<void> _saveDailyGoal() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('user_settings')
            .upsert({
              'user_id': user.id,
              'daily_goal_minutes': _selectedMinutes,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);
      }

      if (!mounted) return; // 早期リターン
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TutorialLessonGoalScreen(),
        ),
      );
    } catch (e) {
      print('Error saving daily goal: $e');
      if (!mounted) return; // 早期リターン
      
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
                value: 0.85, // 4.25/5ステップ
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 40),
              
              // タイトル
              const Text(
                '1日の目標学習時間を\n設定しましょう',
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
                '無理のない時間から始めましょう',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              
              // 現在の選択値表示
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 48,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$_selectedMinutes分',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '毎日の目標',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // 時間選択オプション
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _minuteOptions.map((minutes) {
                  final isSelected = minutes == _selectedMinutes;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMinutes = minutes;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade600
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue.shade600
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$minutes分',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const Spacer(),
              
              // スキップボタン
              TextButton(
                onPressed: _isLoading ? null : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TutorialLessonGoalScreen(),
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
                  onPressed: _isLoading ? null : _saveDailyGoal,
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