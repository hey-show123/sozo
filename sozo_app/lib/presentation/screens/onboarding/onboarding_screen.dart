import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // 選択された値
  String? _selectedGoal;
  String? _selectedLevel;
  String? _selectedAIPartner;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Future<void> _completeOnboarding() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    if (userId == null) return;
    
    try {
      // プロフィールを更新
      await supabase.from('profiles').update({
        'learning_goal': _selectedGoal,
        'english_level': _selectedLevel,
        'ai_partner_preference': _selectedAIPartner,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      // ユーザー設定を更新
      await supabase.from('user_settings').upsert({
        'user_id': userId,
        'learning_goal': _selectedGoal,
        'english_level': _selectedLevel,
        'ai_partner_style': _selectedAIPartner,
        'daily_goal_minutes': 30,
        'notification_enabled': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 進捗インジケーター
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // ページビュー
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildGoalSelectionPage(),
                  _buildLevelSelectionPage(),
                  _buildAIPartnerSelectionPage(),
                ],
              ),
            ),
            
            // ナビゲーションボタン
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('戻る'),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  ElevatedButton(
                    onPressed: _canProceed() ? () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    } : null,
                    child: Text(_currentPage < 2 ? '次へ' : '始める'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedGoal != null;
      case 1:
        return _selectedLevel != null;
      case 2:
        return _selectedAIPartner != null;
      default:
        return false;
    }
  }
  
  Widget _buildGoalSelectionPage() {
    final goals = [
      {
        'id': 'haircare',
        'title': 'ヘアケア英会話',
        'description': 'カット、パーマ、トリートメントの接客英語',
        'icon': Icons.cut,
        'color': Colors.blue,
      },
      {
        'id': 'makeup',
        'title': 'メイクアップ英会話',
        'description': 'メイクやスキンケアの相談・提案英語',
        'icon': Icons.brush,
        'color': Colors.pink,
      },
      {
        'id': 'nail',
        'title': 'ネイル英会話',
        'description': 'ネイルケアやアートの説明英語',
        'icon': Icons.pan_tool,
        'color': Colors.purple,
      },
      {
        'id': 'esthetics',
        'title': 'エステ英会話',
        'description': 'フェイシャル・ボディケアの接客英語',
        'icon': Icons.spa,
        'color': Colors.green,
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学習目標を選んでください',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'あなたの目標に合わせて最適な学習プランを提供します',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final isSelected = _selectedGoal == goal['id'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGoal = goal['id'] as String;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (goal['color'] as Color).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? goal['color'] as Color
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (goal['color'] as Color).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: (goal['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            goal['icon'] as IconData,
                            color: goal['color'] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal['title'] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                goal['description'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: goal['color'] as Color,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelSelectionPage() {
    final levels = [
      {
        'id': 'beginner',
        'title': '初級',
        'description': '基本的な単語や文法から始めたい',
        'examples': ['Hello, How are you?', 'My name is...'],
        'color': Colors.green,
      },
      {
        'id': 'intermediate',
        'title': '中級',
        'description': '日常会話はできるが、もっと上達したい',
        'examples': ['I\'d like to...', 'Could you please...'],
        'color': Colors.blue,
      },
      {
        'id': 'advanced',
        'title': '上級',
        'description': 'ビジネスや専門的な話題も話せる',
        'examples': ['In my opinion...', 'Let me elaborate...'],
        'color': Colors.purple,
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '現在の英語レベルを教えてください',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'レベルに合わせた最適な学習コンテンツを提供します',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                final isSelected = _selectedLevel == level['id'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLevel = level['id'] as String;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (level['color'] as Color).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? level['color'] as Color
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (level['color'] as Color).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
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
                                color: level['color'] as Color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                level['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: level['color'] as Color,
                                size: 24,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          level['description'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: (level['examples'] as List<String>).map((example) {
                            return Chip(
                              label: Text(
                                example,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey[100],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAIPartnerSelectionPage() {
    final partners = [
      {
        'id': 'friendly',
        'name': 'フレンドリー',
        'description': '親しみやすく、励ましてくれるパートナー',
        'personality': '明るく優しい性格で、間違いを恐れずに話せる雰囲気を作ります',
        'avatar': '😊',
        'color': Colors.orange,
      },
      {
        'id': 'professional',
        'name': 'プロフェッショナル',
        'description': 'ビジネスライクで的確なフィードバック',
        'personality': '丁寧で正確な指導を心がけ、ビジネスシーンでも使える表現を教えます',
        'avatar': '👔',
        'color': Colors.blue,
      },
      {
        'id': 'casual',
        'name': 'カジュアル',
        'description': '友達のように気軽に話せるパートナー',
        'personality': 'リラックスした雰囲気で、日常的な表現を中心に学習をサポートします',
        'avatar': '😎',
        'color': Colors.green,
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AIパートナーを選んでください',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'あなたの学習スタイルに合わせたAIパートナーが会話練習をサポートします',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: partners.length,
              itemBuilder: (context, index) {
                final partner = partners[index];
                final isSelected = _selectedAIPartner == partner['id'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAIPartner = partner['id'] as String;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (partner['color'] as Color).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? partner['color'] as Color
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (partner['color'] as Color).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: (partner['color'] as Color).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              partner['avatar'] as String,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partner['name'] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                partner['description'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                partner['personality'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: partner['color'] as Color,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 