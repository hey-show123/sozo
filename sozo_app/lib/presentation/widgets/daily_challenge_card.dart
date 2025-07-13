import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// デイリーチャレンジプロバイダー
final todaysChallengeProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) return null;
  
  try {
    // 今日のチャレンジを取得
    final today = DateTime.now().toLocal();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    final challengeResponse = await supabase
        .from('daily_challenges')
        .select()
        .eq('challenge_date', todayStr)
        .eq('is_active', true)
        .maybeSingle();
    
    if (challengeResponse == null) return null;
    
    // ユーザーの進捗を取得
    final progressResponse = await supabase
        .from('user_daily_challenges')
        .select()
        .eq('user_id', userId)
        .eq('challenge_id', challengeResponse['id'])
        .maybeSingle();
    
    return {
      ...challengeResponse,
      'user_progress': progressResponse,
    };
  } catch (e) {
    print('Error fetching daily challenge: $e');
    return null;
  }
});

class DailyChallengeCard extends ConsumerWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(todaysChallengeProvider);
    
    return challengeAsync.when(
      data: (challenge) {
        if (challenge == null) return const SizedBox.shrink();
        
        final userProgress = challenge['user_progress'] as Map<String, dynamic>?;
        final progress = userProgress?['progress'] ?? 0;
        final isCompleted = userProgress?['is_completed'] ?? false;
        final targetValue = challenge['target_value'] ?? 1;
        final progressRate = (progress / targetValue).clamp(0.0, 1.0);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCompleted
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : [Colors.orange.shade400, Colors.orange.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isCompleted
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 背景パターン
              Positioned(
                right: -30,
                top: -30,
                child: Icon(
                  _getChallengeIcon(challenge['challenge_type']),
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              // コンテンツ
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.today,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'デイリーチャレンジ',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                challenge['title'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                    if (challenge['description'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        challenge['description'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // プログレスバー
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressRate,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$progress / $targetValue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+${challenge['xp_reward'] ?? 100} XP',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
  
  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
  
  IconData _getChallengeIcon(String? type) {
    switch (type) {
      case 'lesson_count':
        return Icons.book;
      case 'xp_target':
        return Icons.star;
      case 'perfect_score':
        return Icons.emoji_events;
      case 'pronunciation_score':
        return Icons.mic;
      case 'conversation_minutes':
        return Icons.chat;
      case 'vocabulary_learned':
        return Icons.translate;
      default:
        return Icons.flag;
    }
  }
} 