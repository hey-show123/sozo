import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';

class LessonCompleteScreen extends ConsumerStatefulWidget {
  final double score;
  final int sessionCount;
  final String lessonId;

  const LessonCompleteScreen({
    super.key,
    required this.score,
    required this.sessionCount,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonCompleteScreen> createState() =>
      _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends ConsumerState<LessonCompleteScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // 高スコアの場合は紙吹雪を表示
    if (widget.score >= 80) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExcellent = widget.score >= 90;
    final isGood = widget.score >= 80;
    final isPassing = widget.score >= 70;

    return Scaffold(
      body: Stack(
        children: [
          // 背景グラデーション
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isExcellent
                      ? Colors.green[400]!
                      : isGood
                          ? Colors.blue[400]!
                          : Colors.orange[400]!,
                  Colors.white,
                ],
              ),
            ),
          ),
          
          // メインコンテンツ
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 完了アイコン
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      isExcellent
                          ? Icons.star
                          : isGood
                              ? Icons.thumb_up
                              : Icons.check_circle,
                      size: 60,
                      color: isExcellent
                          ? Colors.amber
                          : isGood
                              ? Colors.blue
                              : Colors.orange,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // タイトル
                  Text(
                    isExcellent
                        ? '素晴らしい！'
                        : isGood
                            ? 'よくできました！'
                            : '完了しました！',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // スコア表示
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '総合スコア',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.score.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // セッション情報
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          icon: Icons.chat_bubble_outline,
                          label: '完了セッション',
                          value: '${widget.sessionCount}/5',
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          icon: Icons.timer,
                          label: '学習時間',
                          value: '${widget.sessionCount * 3}分',
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          icon: Icons.stars,
                          label: '獲得XP',
                          value: '+${(widget.score * 2).toInt()} XP',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // フィードバックメッセージ
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getFeedbackMessage(),
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // アクションボタン
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // レッスン一覧に戻る
                            context.go('/lessons');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(width: 2),
                          ),
                          child: const Text('レッスン一覧へ'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 次のレッスンへ
                            context.go('/lessons/next');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('次のレッスンへ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 紙吹雪
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
              createParticlePath: (size) {
                final path = Path();
                path.addOval(Rect.fromCircle(center: Offset.zero, radius: 5));
                return path;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _getFeedbackMessage() {
    if (widget.score >= 90) {
      return '完璧です！このまま続けましょう。次のレッスンでさらにスキルアップ！';
    } else if (widget.score >= 80) {
      return 'とても良いです！もう少し練習すれば完璧になります。';
    } else if (widget.score >= 70) {
      return '頑張りました！キーフレーズをもう一度復習してみましょう。';
    } else {
      return '練習を続けましょう！焦らず自分のペースで上達できます。';
    }
  }
} 