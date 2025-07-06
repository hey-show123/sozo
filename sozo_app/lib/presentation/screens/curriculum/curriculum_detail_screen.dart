import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sozo_app/presentation/providers/curriculum_provider.dart';
import 'package:sozo_app/presentation/widgets/lesson_card.dart';

class CurriculumDetailScreen extends ConsumerStatefulWidget {
  final String curriculumId;

  const CurriculumDetailScreen({
    super.key,
    required this.curriculumId,
  });

  @override
  ConsumerState<CurriculumDetailScreen> createState() => _CurriculumDetailScreenState();
}

class _CurriculumDetailScreenState extends ConsumerState<CurriculumDetailScreen> {
  @override
  void initState() {
    super.initState();
    // レッスンをロード
    Future.microtask(() {
      ref.read(lessonsProvider.notifier).loadLessons(widget.curriculumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final curriculumsAsync = ref.watch(curriculumProvider);
    final lessonsAsync = ref.watch(lessonsProvider);
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: curriculumsAsync.when(
        data: (curriculums) {
          final curriculum = curriculums.firstWhere(
            (c) => c.id == widget.curriculumId,
            orElse: () => throw Exception('カリキュラムが見つかりません'),
          );
          
          return CustomScrollView(
            slivers: [
              // カスタムAppBar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: _getCategoryColor(curriculum.category),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _getCategoryColor(curriculum.category),
                          _getCategoryColor(curriculum.category).withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            // カテゴリバッジ
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                curriculum.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // タイトル
                            Text(
                              curriculum.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // 説明
                            if (curriculum.description != null)
                              Text(
                                curriculum.description!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                            const Spacer(),
                            // 統計情報
                            Row(
                              children: [
                                _buildStatItem(
                                  icon: Icons.schedule,
                                  label: '推定時間',
                                  value: '${curriculum.estimatedHours ?? 0}時間',
                                ),
                                const SizedBox(width: 24),
                                _buildStatItem(
                                  icon: Icons.trending_up,
                                  label: '難易度',
                                  value: _getDifficultyText(curriculum.difficultyLevel),
                                ),
                                const SizedBox(width: 24),
                                _buildStatItem(
                                  icon: Icons.star,
                                  label: '評価',
                                  value: '4.5',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // レッスン一覧
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'レッスン一覧',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'このコースに含まれるレッスンです。順番に進めていきましょう。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // レッスンリスト
              lessonsAsync.when(
                data: (lessons) {
                  print('Lessons loaded: ${lessons.length}');
                  if (lessons.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.book_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'レッスンの準備中です',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'このコースのレッスンを準備中です。\nもうしばらくお待ちください。',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return progressAsync.when(
                    data: (progress) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              try {
                                final lesson = lessons[index];
                                final lessonProgress = progress[lesson.id];
                                print('Rendering lesson: ${lesson.title}');

                                return LessonCard(
                                  lesson: lesson,
                                  progress: lessonProgress?.toJson(),
                                  onTap: () {
                                    context.push('/lesson/${lesson.id}');
                                  },
                                );
                              } catch (e) {
                                print('Error rendering lesson at index $index: $e');
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'レッスンの表示エラー: $e',
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                );
                              }
                            },
                            childCount: lessons.length,
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    error: (error, stack) {
                      print('Progress loading error: $error');
                      print('Stack trace: $stack');
                      return SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'エラーが発生しました',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.read(lessonsProvider.notifier).loadLessons(widget.curriculumId),
                                child: const Text('再試行'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (error, stack) {
                  print('Lessons loading error: $error');
                  print('Stack trace: $stack');
                  return SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'エラーが発生しました',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.read(lessonsProvider.notifier).loadLessons(widget.curriculumId),
                            child: const Text('再試行'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // 下部の余白
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) {
          print('Curriculum loading error: $error');
          print('Stack trace: $stack');
          return Scaffold(
            appBar: AppBar(title: const Text('エラー')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('カリキュラムの読み込みに失敗しました'),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'haircare':
        return const Color(0xFF1E3A8A);
      case 'makeup':
        return const Color(0xFFEC4899);
      case 'nail':
        return const Color(0xFF7C3AED);
      case 'esthetics':
        return const Color(0xFF059669);
      case 'coloring':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _getDifficultyText(int level) {
    switch (level) {
      case 1:
        return '初級';
      case 2:
        return '初中級';
      case 3:
        return '中級';
      case 4:
        return '上級';
      default:
        return '不明';
    }
  }
} 