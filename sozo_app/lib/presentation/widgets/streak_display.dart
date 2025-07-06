import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_stats_provider.dart';

class StreakDisplay extends ConsumerWidget {
  const StreakDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStats = ref.watch(userStatsProvider);
    
    return userStats.when(
      data: (stats) => _buildStreakCard(context, stats.streakCount),
      loading: () => _buildStreakCard(context, 0),
      error: (_, __) => _buildStreakCard(context, 0),
    );
  }
  
  Widget _buildStreakCard(BuildContext context, int streakCount) {
    final theme = Theme.of(context);
    final hasStreak = streakCount > 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasStreak
              ? [Colors.orange[400]!, Colors.orange[600]!]
              : [Colors.grey[300]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: hasStreak
                ? Colors.orange.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ストリーク',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (hasStreak) _buildStreakBadge(streakCount),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                streakCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '日連続',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStreakCalendar(streakCount),
          const SizedBox(height: 12),
          Text(
            _getStreakMessage(streakCount),
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreakBadge(int streakCount) {
    String badge = '';
    Color badgeColor = Colors.white;
    
    if (streakCount >= 30) {
      badge = '🏆';
      badgeColor = Colors.amber;
    } else if (streakCount >= 14) {
      badge = '🥈';
      badgeColor = Colors.grey[300]!;
    } else if (streakCount >= 7) {
      badge = '🥉';
      badgeColor = Colors.brown[300]!;
    } else if (streakCount >= 3) {
      badge = '⭐';
      badgeColor = Colors.yellow;
    }
    
    if (badge.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Text(
        badge,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
  
  Widget _buildStreakCalendar(int streakCount) {
    final today = DateTime.now();
    final days = List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final isActive = index >= (7 - streakCount) && streakCount > 0;
      final isToday = index == 6;
      
      return Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getDayName(date),
                style: TextStyle(
                  color: isActive ? Colors.orange : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isActive)
                Icon(
                  Icons.check,
                  color: Colors.orange,
                  size: 16,
                ),
            ],
          ),
        ),
      );
    });
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days,
    );
  }
  
  String _getDayName(DateTime date) {
    final weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return weekdays[date.weekday % 7];
  }
  
  String _getStreakMessage(int streakCount) {
    if (streakCount == 0) {
      return '今日から学習を始めましょう！';
    } else if (streakCount == 1) {
      return 'ストリーク開始！明日も続けましょう！';
    } else if (streakCount < 7) {
      return 'いい調子です！1週間を目指しましょう！';
    } else if (streakCount < 14) {
      return '素晴らしい！2週間まであと${14 - streakCount}日！';
    } else if (streakCount < 30) {
      return 'すごい！1ヶ月まであと${30 - streakCount}日！';
    } else {
      return '最高です！この調子で続けましょう！';
    }
  }
} 