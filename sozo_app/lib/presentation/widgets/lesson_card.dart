import 'package:flutter/material.dart';
import 'package:sozo_app/data/models/lesson_model.dart';

class LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final Map<String, dynamic>? progress;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final isCompleted = progress?['status'] == 'completed';
      final isInProgress = progress?['status'] == 'in_progress';
      final bestScore = progress?['best_score'] as double?;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ヘッダー部分（ステータスとタイプ）
                  Row(
                    children: [
                      // レッスンタイプのアイコン
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getLessonTypeColor(lesson.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getLessonTypeIcon(lesson.type),
                              size: 14,
                              color: _getLessonTypeColor(lesson.type),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getLessonTypeText(lesson.type),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getLessonTypeColor(lesson.type),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // ステータスアイコン
                      _buildStatusIcon(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // タイトルと説明
                  Text(
                    lesson.title ?? 'レッスン',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.description ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // 進捗情報
                  Row(
                    children: [
                      // 所要時間
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${lesson.estimatedMinutes}分',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // 難易度
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 16,
                            color: _getDifficultyColor(lesson.difficulty),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getDifficultyText(lesson.difficulty),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDifficultyColor(lesson.difficulty),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // スコア表示
                      if (bestScore != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(bestScore).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: _getScoreColor(bestScore),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${bestScore.toInt()}点',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(bestScore),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // 進捗バー（進行中の場合）
                  if (isInProgress) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (lesson.completionRate / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error building LessonCard: $e');
      print('Lesson data: ${lesson.toJson()}');
      
      // エラー時のフォールバックUI
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lesson.title ?? 'エラー: タイトルなし',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'レッスンの表示中にエラーが発生しました',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'エラー詳細: $e',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatusIcon() {
    final isCompleted = progress?['status'] == 'completed';
    final isInProgress = progress?['status'] == 'in_progress';
    
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFF10B981),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 16,
          color: Colors.white,
        ),
      );
    } else if (isInProgress) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFF3B82F6),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.play_arrow,
          size: 16,
          color: Colors.white,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock_outline,
          size: 16,
          color: Colors.grey[600],
        ),
      );
    }
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.conversation:
        return Icons.chat_bubble_outline;
      case LessonType.pronunciation:
        return Icons.record_voice_over;
      case LessonType.vocabulary:
        return Icons.book_outlined;
      case LessonType.grammar:
        return Icons.language;
      case LessonType.review:
        return Icons.refresh;
    }
  }

  String _getLessonTypeText(LessonType type) {
    switch (type) {
      case LessonType.conversation:
        return '会話';
      case LessonType.pronunciation:
        return '発音';
      case LessonType.vocabulary:
        return '語彙';
      case LessonType.grammar:
        return '文法';
      case LessonType.review:
        return '復習';
    }
  }

  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.conversation:
        return const Color(0xFF3B82F6);
      case LessonType.pronunciation:
        return const Color(0xFFEF4444);
      case LessonType.vocabulary:
        return const Color(0xFF10B981);
      case LessonType.grammar:
        return const Color(0xFFF59E0B);
      case LessonType.review:
        return const Color(0xFF8B5CF6);
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return '初級';
      case DifficultyLevel.elementary:
        return '初中級';
      case DifficultyLevel.intermediate:
        return '中級';
      case DifficultyLevel.advanced:
        return '上級';
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return const Color(0xFF10B981);
      case DifficultyLevel.elementary:
        return const Color(0xFF3B82F6);
      case DifficultyLevel.intermediate:
        return const Color(0xFFF59E0B);
      case DifficultyLevel.advanced:
        return const Color(0xFFEF4444);
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 90) {
      return const Color(0xFF10B981); // Green
    } else if (score >= 70) {
      return const Color(0xFF3B82F6); // Blue
    } else if (score >= 50) {
      return const Color(0xFFF59E0B); // Yellow
    } else {
      return const Color(0xFFEF4444); // Red
    }
  }
} 