import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/user_stats_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WeeklyLearningChart extends ConsumerWidget {
  const WeeklyLearningChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStats = ref.watch(weeklyLearningStatsProvider);
    
    return weeklyStats.when(
      data: (stats) => _buildChart(context, stats),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildDefaultChart(context),
    );
  }
  
  Widget _buildChart(BuildContext context, List<DailyLearningStats> stats) {
    final theme = Theme.of(context);
    
    // 最大値を計算（Y軸のスケール用）
    final maxMinutes = stats.isEmpty 
        ? 60.0 
        : stats.map((s) => s.totalMinutes.toDouble()).reduce((a, b) => a > b ? a : b).clamp(30.0, double.infinity);
    
    // 過去7日間のデータを準備
    final now = DateTime.now();
    final List<BarChartGroupData> barGroups = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStats = stats.firstWhere(
        (s) => _isSameDay(s.date, date),
        orElse: () => DailyLearningStats(
          date: date,
          totalMinutes: 0,
          lessonsCompleted: 0,
          xpEarned: 0,
        ),
      );
      
      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: dayStats.totalMinutes.toDouble(),
              color: dayStats.totalMinutes > 0 
                  ? theme.primaryColor 
                  : theme.primaryColor.withOpacity(0.3),
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxMinutes,
                color: Colors.grey[200],
              ),
            ),
          ],
          showingTooltipIndicators: const [],
        ),
      );
    }
    
    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '週間学習時間',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '合計: ${_getTotalMinutes(stats)}分',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxMinutes,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final date = now.subtract(Duration(days: 6 - value.toInt()));
                        final isToday = _isSameDay(date, now);
                        final dayName = isToday ? '今日' : DateFormat.E('ja').format(date);
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            dayName,
                            style: TextStyle(
                              color: isToday ? theme.primaryColor : Colors.grey[700],
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                      reservedSize: 36,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: maxMinutes > 120 ? 30 : 15,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxMinutes > 120 ? 30 : 15,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDefaultChart(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '学習を始めると、ここに週間の進捗が表示されます',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  
  int _getTotalMinutes(List<DailyLearningStats> stats) {
    return stats.fold(0, (sum, stat) => sum + stat.totalMinutes);
  }
} 