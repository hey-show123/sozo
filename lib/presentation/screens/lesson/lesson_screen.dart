import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/curriculum_provider.dart';
import '../../../services/audio_player_service.dart';
import '../../../services/audio_storage_service.dart';
import '../chat/ai_buddy_screen.dart';
import '../test/pronunciation_test_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/dialog_practice_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/key_phrase_practice_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/ai_conversation_practice_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/lesson_model.dart' as lesson_model;
import '../../../data/models/curriculum_model.dart' as curriculum_model;

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  
  const LessonScreen({
    super.key,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  lesson_model.LessonModel? currentLesson;
  bool _showHints = true;
  bool _hasDialogActivity = false;
  
  @override
  void initState() {
    super.initState();
    _loadLesson();
  }
  
  void _loadLesson() async {
    try {
      final supabase = Supabase.instance.client;
      print('Loading lesson with ID: ${widget.lessonId}');
      
      final response = await supabase
          .from('lessons')
          .select()
          .eq('id', widget.lessonId)
          .single();
      
      print('Raw response from Supabase: $response');
      
      if (mounted) {
        setState(() {
          currentLesson = lesson_model.LessonModel.fromJson(response);
        });
        print('Lesson loaded successfully: ${currentLesson?.title}');
        _checkForDialogActivity();
      }
    } catch (e, stackTrace) {
      print('Error loading lesson: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('レッスンの読み込みに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkForDialogActivity() async {
    try {
      // レッスンデータから直接dialog情報を確認
      if (currentLesson != null && 
          currentLesson!.dialogues.isNotEmpty) {
        setState(() {
          _hasDialogActivity = true;
        });
      } else {
        setState(() {
          _hasDialogActivity = false;
        });
      }
    } catch (e) {
      print('Error checking for dialog activity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLesson == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(currentLesson!.title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // レッスン情報ヘッダー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // レッスンタイプとレベル
                  Row(
                    children: [
                      _buildChip(
                        _getLessonTypeLabel(currentLesson!.type),
                        _getLessonTypeColor(currentLesson!.type),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        _getDifficultyLabel(currentLesson!.difficulty),
                        _getDifficultyColor(currentLesson!.difficulty),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        '${currentLesson!.estimatedMinutes}分',
                        Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentLesson!.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // 学習目標
            if (currentLesson!.objectives.isNotEmpty) ...[
              _buildSection(
                title: '学習目標',
                icon: Icons.flag,
                child: Column(
                  children: currentLesson!.objectives.map((objective) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              objective,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            
            // シナリオ情報
            _buildSection(
              title: 'シナリオ',
              icon: Icons.theater_comedy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('状況', currentLesson!.scenario.situation),
                  _buildInfoRow('場所', currentLesson!.scenario.location),
                  _buildInfoRow('AIの役割', currentLesson!.scenario.aiRole),
                  _buildInfoRow('あなたの役割', currentLesson!.scenario.userRole),
                  const SizedBox(height: 8),
                  Text(
                    currentLesson!.scenario.context,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  if (currentLesson!.scenario.suggestedTopics.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '会話のトピック例:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentLesson!.scenario.suggestedTopics.map((topic) {
                        return Chip(
                          label: Text(
                            topic,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            // キーフレーズ
            if (currentLesson!.keyPhrases.isNotEmpty) ...[
              _buildSection(
                title: 'キーフレーズ',
                icon: Icons.format_quote,
                child: Column(
                  children: currentLesson!.keyPhrases.map((phrase) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    phrase.phrase,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (phrase.pronunciation != null)
                                  IconButton(
                                    icon: const Icon(Icons.volume_up),
                                    onPressed: () async {
                                      final audioPlayer = ref.read(audioPlayerServiceProvider);
                                      try {
                                        await audioPlayer.playKeyPhrase(
                                          phrase: phrase.phrase,
                                          lessonId: currentLesson!.id,
                                          audioUrl: phrase.audioUrl,
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('音声再生エラー: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                            if (phrase.pronunciation != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                phrase.pronunciation!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              phrase.meaning,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '使い方: ${phrase.usage}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (phrase.examples.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                '例文:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...phrase.examples.map((example) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    '• $example',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            
            // 文法ポイント
            if (currentLesson!.grammarPoints.isNotEmpty) ...[
              _buildSection(
                title: '文法ポイント',
                icon: Icons.menu_book,
                child: Column(
                  children: currentLesson!.grammarPoints.map((grammar) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              grammar.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              grammar.explanation,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                grammar.structure,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            if (grammar.examples.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                '例:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...grammar.examples.map((example) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    '• $example',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                            ],
                            if (grammar.commonMistakes != null && grammar.commonMistakes!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'よくある間違い:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ...grammar.commonMistakes!.map((mistake) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          mistake,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            
            // 発音フォーカス
            if (currentLesson!.pronunciationFocus != null) ...[
              _buildSection(
                title: '発音練習',
                icon: Icons.record_voice_over,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ターゲット音: ${currentLesson!.pronunciationFocus!.targetSounds.join(', ')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (currentLesson!.pronunciationFocus!.tips != null) ...[
                      const SizedBox(height: 12),
                      ...currentLesson!.pronunciationFocus!.tips!.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key}: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Text(entry.value),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      '練習単語:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentLesson!.pronunciationFocus!.words.map((word) {
                        return Chip(
                          label: Text(word),
                          backgroundColor: Colors.purple[100],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '練習文:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...currentLesson!.pronunciationFocus!.sentences.map((sentence) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(sentence),
                          trailing: IconButton(
                            icon: const Icon(Icons.mic),
                            onPressed: () {
                              // TODO: 発音練習を開始
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
            
            // 開始ボタンを削除し、練習メニューを上部に移動

            const SizedBox(height: 24),
            
            // 練習メニュー（モバイル最適化）
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 28,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '練習を始める',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // ステップバイステップの練習フロー
                  _buildPracticeStep(
                    number: '1',
                    icon: Icons.format_quote,
                    title: 'キーフレーズ練習',
                    subtitle: '重要フレーズの発音をマスター',
                    estimatedTime: '10分',
                    color: Colors.orange,
                    isCompleted: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KeyPhrasePracticeScreen(
                            lesson: currentLesson!,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // 接続線
                  _buildConnectionLine(),
                  
                  // ダイアログ練習（常に表示）
                  _buildPracticeStep(
                    number: '2',
                    icon: Icons.chat_bubble,
                    title: 'ダイアログ練習',
                    subtitle: 'シナリオに沿った会話練習',
                    estimatedTime: '15分',
                    color: Colors.green,
                    isCompleted: false,
                    onTap: () {
                      context.push(
                        '/lesson/${currentLesson!.id}/dialog',
                        extra: currentLesson,
                      );
                    },
                  ),
                  _buildConnectionLine(),
                  
                  // AI会話練習（5セッション）
                  _buildPracticeStep(
                    number: '3',
                    icon: Icons.psychology,
                    title: 'AI会話実践',
                    subtitle: '5つのセッションで実践力アップ',
                    estimatedTime: '15-20分',
                    color: Colors.blue,
                    isCompleted: false,
                    onTap: () {
                      context.push(
                        '/lesson/${currentLesson!.id}/ai-conversation',
                      );
                    },
                  ),
                  
                  _buildConnectionLine(),
                  
                  // 発音テスト
                  _buildPracticeStep(
                    number: '4',
                    icon: Icons.mic,
                    title: '発音テスト',
                    subtitle: '学習成果を確認',
                    estimatedTime: '5分',
                    color: Colors.purple,
                    isCompleted: false,
                    isLast: true,
                    onTap: () {
                      context.push('/test/pronunciation', extra: currentLesson);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildPracticeButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getLessonTypeLabel(lesson_model.LessonType type) {
    switch (type) {
      case lesson_model.LessonType.conversation:
        return '会話';
      case lesson_model.LessonType.pronunciation:
        return '発音';
      case lesson_model.LessonType.vocabulary:
        return '語彙';
      case lesson_model.LessonType.grammar:
        return '文法';
      case lesson_model.LessonType.review:
        return '復習';
    }
  }
  
  Color _getLessonTypeColor(lesson_model.LessonType type) {
    switch (type) {
      case lesson_model.LessonType.conversation:
        return Colors.blue;
      case lesson_model.LessonType.pronunciation:
        return Colors.purple;
      case lesson_model.LessonType.vocabulary:
        return Colors.orange;
      case lesson_model.LessonType.grammar:
        return Colors.green;
      case lesson_model.LessonType.review:
        return Colors.red;
    }
  }
  
  String _getDifficultyLabel(lesson_model.DifficultyLevel difficulty) {
    switch (difficulty) {
      case lesson_model.DifficultyLevel.beginner:
        return '初級';
      case lesson_model.DifficultyLevel.elementary:
        return '初中級';
      case lesson_model.DifficultyLevel.intermediate:
        return '中級';
      case lesson_model.DifficultyLevel.advanced:
        return '上級';
    }
  }
  
  Color _getDifficultyColor(lesson_model.DifficultyLevel difficulty) {
    switch (difficulty) {
      case lesson_model.DifficultyLevel.beginner:
        return Colors.green;
      case lesson_model.DifficultyLevel.elementary:
        return Colors.teal;
      case lesson_model.DifficultyLevel.intermediate:
        return Colors.orange;
      case lesson_model.DifficultyLevel.advanced:
        return Colors.red;
    }
  }
  
  Widget _buildPracticeStep({
    required String number,
    required IconData icon,
    required String title,
    required String subtitle,
    required String estimatedTime,
    required Color color,
    required bool isCompleted,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? color : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ステップ番号
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? color : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        number,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.white : Colors.grey[700],
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // アイコン
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            // テキスト
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          estimatedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConnectionLine() {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      height: 30,
      width: 2,
      color: Colors.grey[300],
    );
  }
} 