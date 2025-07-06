import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tutorial_level_screen.dart';

class TutorialGoalScreen extends ConsumerStatefulWidget {
  const TutorialGoalScreen({super.key});

  @override
  ConsumerState<TutorialGoalScreen> createState() => _TutorialGoalScreenState();
}

class _TutorialGoalScreenState extends ConsumerState<TutorialGoalScreen> {
  String? _selectedGoal;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'conversation',
      'title': '日常会話',
      'description': '友達や家族との会話を\nスムーズにしたい',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.blue,
    },
    {
      'id': 'business',
      'title': 'ビジネス英語',
      'description': '仕事で英語を\n使えるようになりたい',
      'icon': Icons.business_center,
      'color': Colors.green,
    },
    {
      'id': 'travel',
      'title': '旅行',
      'description': '海外旅行で\n困らないようになりたい',
      'icon': Icons.flight_takeoff,
      'color': Colors.orange,
    },
    {
      'id': 'exam',
      'title': '試験対策',
      'description': 'TOEICやTOEFLの\nスコアを上げたい',
      'icon': Icons.school,
      'color': Colors.purple,
    },
  ];

  Future<void> _saveGoal() async {
    if (_selectedGoal == null) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('user_settings')
            .upsert({
              'user_id': user.id,
              'learning_goal': _selectedGoal,
            });
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TutorialLevelScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error saving goal: $e');
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
                value: 0.6, // 3/5ステップ
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 40),
              
              // タイトル
              const Text(
                '学習目標を\n選んでください',
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
                'あなたに合ったレッスンをご提案します',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              
              // 目標リスト
              Expanded(
                child: ListView.builder(
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final isSelected = _selectedGoal == goal['id'];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedGoal = goal['id'];
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? goal['color'].withOpacity(0.1)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? goal['color']
                                  : Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: goal['color'].withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  goal['icon'],
                                  color: goal['color'],
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? goal['color']
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      goal['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: goal['color'],
                                  size: 28,
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
                  onPressed: (_isLoading || _selectedGoal == null) ? null : _saveGoal,
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