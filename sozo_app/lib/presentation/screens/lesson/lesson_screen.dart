import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/curriculum_provider.dart';
import '../../../services/audio_player_service.dart';
import '../../../services/audio_storage_service.dart';
import '../../../services/character_service.dart';
import '../../widgets/audio_preload_screen.dart';
import '../chat/ai_buddy_screen.dart';
import '../test/pronunciation_test_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/dialog_practice_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/key_phrase_practice_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/ai_conversation_practice_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/vocabulary_practice_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/listening_practice_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/application_practice_screen.dart';
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
  bool _isPreloadingAudio = false;
  Map<String, bool> completedModes = {
    'all': false,
    'vocabulary': false,
    'keyPhrase': false,
    'listening': false,
    'dialog': false,
    'aiConversation': false,
    'pronunciation': false,
    'application': false,
  };
  
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

  // 音声事前ダウンロード機能
  Future<void> _preloadAudioForLesson() async {
    if (currentLesson == null || _isPreloadingAudio) return;
    
    setState(() {
      _isPreloadingAudio = true;
    });

    try {
      final audioStorage = ref.read(audioStorageServiceProvider);
      final characterVoice = CharacterService.getVoiceModel(currentLesson!.characterId);
      
      // キーフレーズのテキストを収集
      final keyPhrases = currentLesson!.keyPhrases.map((kp) => kp.phrase).toList();
      
      // ダイアログのテキストを収集
      final dialogues = currentLesson!.dialogues;
      
      // プログレス状態を管理
      ValueNotifier<int> currentProgressNotifier = ValueNotifier(0);
      ValueNotifier<int> totalProgressNotifier = ValueNotifier(0);
      ValueNotifier<String> currentTaskNotifier = ValueNotifier('');
      
      // フルスクリーンローディング画面を表示
      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                ValueListenableBuilder<int>(
                  valueListenable: currentProgressNotifier,
                  builder: (context, currentProgress, child) {
                    return ValueListenableBuilder<int>(
                      valueListenable: totalProgressNotifier,
                      builder: (context, totalProgress, child) {
                        return ValueListenableBuilder<String>(
                          valueListenable: currentTaskNotifier,
                          builder: (context, currentTask, child) {
                            return AnimatedAudioPreloadScreen(
                              currentProgress: currentProgress,
                              totalProgress: totalProgress,
                              lessonTitle: currentLesson!.title,
                              currentTask: currentTask.isNotEmpty ? currentTask : null,
                              onCancel: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _isPreloadingAudio = false;
                                });
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
      
      // 音声を事前ダウンロード
      await audioStorage.preloadLessonAudio(
        lessonId: currentLesson!.id,
        keyPhrases: keyPhrases,
        dialogues: dialogues,
        characterVoice: characterVoice,
        onProgress: (current, total, currentTask) {
          // プログレスを更新
          currentProgressNotifier.value = current;
          totalProgressNotifier.value = total;
          currentTaskNotifier.value = currentTask;
        },
      );
      
      // 完了後、少し待ってからローディング画面を閉じる
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.of(context).pop();
        
        // 成功メッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('音声ファイルの準備が完了しました！'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      print('Audio preloading completed for lesson: ${currentLesson!.id}');
    } catch (e) {
      print('Error preloading audio: $e');
      if (mounted) {
        Navigator.of(context).pop(); // ローディング画面を閉じる
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('音声ファイルの準備に失敗しました: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '再試行',
              onPressed: () => _preloadAudioForLesson(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPreloadingAudio = false;
        });
      }
    }
  }

  // 全てのモードを順番に実行
  Future<void> _playAllModes() async {
    await _preloadAudioForLesson();
    
    if (!mounted) return;
    
    // 単語練習（vocabulary_questionsがある場合のみ）
    if (currentLesson!.vocabularyQuestions != null && 
        currentLesson!.vocabularyQuestions!.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VocabularyPracticeScreen(
            lesson: currentLesson!,
          ),
        ),
      );
      
      setState(() {
        completedModes['vocabulary'] = true;
      });
      
      if (!mounted) return;
    }
    
    // キーフレーズ練習
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KeyPhrasePracticeScreen(
          lesson: currentLesson!,
        ),
      ),
    );
    
    setState(() {
      completedModes['keyPhrase'] = true;
    });
    
    if (!mounted) return;
    
    // リスニング練習
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListeningPracticeScreen(
          lesson: currentLesson!,
        ),
      ),
    );
    
    setState(() {
      completedModes['listening'] = true;
    });
    
    if (!mounted) return;
    
    // ダイアログ練習
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DialogPracticeScreen(
          lesson: currentLesson!,
        ),
      ),
    );
    
    setState(() {
      completedModes['dialog'] = true;
    });
    
    if (!mounted) return;
    
    // 応用練習
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationPracticeScreen(
          lesson: currentLesson!,
        ),
      ),
    );
    
    setState(() {
      completedModes['application'] = true;
    });
    
    if (!mounted) return;
    
    // AI会話練習
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIConversationPracticeScreen(
          lesson: currentLesson!,
        ),
      ),
    );
    
    setState(() {
      completedModes['aiConversation'] = true;
      completedModes['all'] = true;
    });
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
                ],
              ),
            ),
            
            // キーフレーズ（シンプル版）
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    phrase.phrase,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    phrase.meaning,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
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
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            
            // 練習を始める（横スクロール可能なカード形式）
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
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
                  ),
                  const SizedBox(height: 20),
                  
                  // 横スクロール可能なカードリスト
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // 全てのモードをプレイ
                        _buildPracticeCard(
                          title: '全てのモードをプレイ',
                          icon: Icons.play_arrow_rounded,
                          estimatedTime: '45-60分',
                          color: Colors.deepPurple,
                          isCompleted: completedModes['all']!,
                          onTap: _playAllModes,
                        ),
                        const SizedBox(width: 12),
                        
                        // 単語練習（vocabulary_questionsがある場合のみ表示）
                        if (currentLesson!.vocabularyQuestions != null && 
                            currentLesson!.vocabularyQuestions!.isNotEmpty) ...[
                          _buildPracticeCard(
                            title: '単語練習',
                            icon: Icons.quiz,
                            estimatedTime: '5分',
                            color: Colors.red,
                            isCompleted: completedModes['vocabulary']!,
                            onTap: () async {
                              await _preloadAudioForLesson();
                              if (mounted) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VocabularyPracticeScreen(
                                      lesson: currentLesson!,
                                    ),
                                  ),
                                );
                                setState(() {
                                  completedModes['vocabulary'] = true;
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                        ],
                        
                        // キーフレーズ練習
                        _buildPracticeCard(
                          title: 'キーフレーズ練習',
                          icon: Icons.format_quote,
                          estimatedTime: '10分',
                          color: Colors.orange,
                          isCompleted: completedModes['keyPhrase']!,
                          onTap: () async {
                            await _preloadAudioForLesson();
                            if (mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KeyPhrasePracticeScreen(
                                    lesson: currentLesson!,
                                  ),
                                ),
                              );
                              setState(() {
                                completedModes['keyPhrase'] = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        
                        // リスニング練習
                        _buildPracticeCard(
                          title: 'リスニング練習',
                          icon: Icons.hearing,
                          estimatedTime: '8分',
                          color: Colors.teal,
                          isCompleted: completedModes['listening']!,
                          onTap: () async {
                            await _preloadAudioForLesson();
                            if (mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ListeningPracticeScreen(
                                    lesson: currentLesson!,
                                  ),
                                ),
                              );
                              setState(() {
                                completedModes['listening'] = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        
                        // ダイアログ練習
                        _buildPracticeCard(
                          title: 'ダイアログ練習',
                          icon: Icons.chat_bubble,
                          estimatedTime: '15分',
                          color: Colors.green,
                          isCompleted: completedModes['dialog']!,
                          onTap: () async {
                            await _preloadAudioForLesson();
                            if (mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DialogPracticeScreen(
                                    lesson: currentLesson!,
                                  ),
                                ),
                              );
                              setState(() {
                                completedModes['dialog'] = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        
                        // 応用練習
                        _buildPracticeCard(
                          title: '応用練習',
                          icon: Icons.edit_note,
                          estimatedTime: '10-15分',
                          color: Colors.deepPurple,
                          isCompleted: completedModes['application']!,
                          onTap: () async {
                            await _preloadAudioForLesson();
                            if (mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ApplicationPracticeScreen(
                                    lesson: currentLesson!,
                                  ),
                                ),
                              );
                              setState(() {
                                completedModes['application'] = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        
                        // AI会話練習
                        _buildPracticeCard(
                          title: 'AI会話実践',
                          icon: Icons.psychology,
                          estimatedTime: '15-20分',
                          color: Colors.blue,
                          isCompleted: completedModes['aiConversation']!,
                          onTap: () async {
                            await _preloadAudioForLesson();
                            if (mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AIConversationPracticeScreen(
                                    lesson: currentLesson!,
                                  ),
                                ),
                              );
                              setState(() {
                                completedModes['aiConversation'] = true;
                              });
                            }
                          },
                        ),
                      ],
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
            
            const SizedBox(height: 24),
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
  
  // 縦長の練習カード
  Widget _buildPracticeCard({
    required String title,
    required IconData icon,
    required String estimatedTime,
    required Color color,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isPreloadingAudio ? null : onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: _isPreloadingAudio
              ? Colors.grey[100]
              : isCompleted ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPreloadingAudio
                ? Colors.grey[300]!
                : isCompleted ? color : Colors.grey[300]!,
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // アイコン
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isPreloadingAudio
                          ? Colors.grey[200]
                          : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isPreloadingAudio
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  // タイトル
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // 時間
                  Text(
                    estimatedTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // 完了マーク
            if (isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
          ],
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
} 