import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sozo_app/core/theme/app_theme.dart';
import 'package:sozo_app/data/models/lesson_model.dart';
import 'package:sozo_app/services/azure_speech_service.dart';
import 'package:sozo_app/services/audio_player_service.dart';
import 'package:sozo_app/services/audio_storage_service.dart';
import 'package:sozo_app/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:sozo_app/presentation/providers/curriculum_provider.dart';
import 'package:sozo_app/services/progress_service.dart';
import 'package:sozo_app/services/character_service.dart';
import 'package:sozo_app/presentation/widgets/xp_animation.dart';
import 'package:sozo_app/presentation/widgets/achievement_notification.dart';
import 'package:sozo_app/presentation/widgets/level_up_notification.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sozo_app/presentation/widgets/animated_avatar.dart';
import 'package:sozo_app/core/utils/platform_utils.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';
import 'package:sozo_app/presentation/providers/user_profile_provider.dart';

enum RecordingState {
  idle,
  recording,
  analyzing,
  error,
}

class DialogPracticeScreen extends ConsumerStatefulWidget {
  final LessonModel lesson;
  final VoidCallback? onComplete; // チュートリアル完了時のコールバック

  const DialogPracticeScreen({
    super.key,
    required this.lesson,
    this.onComplete,
  });

  @override
  ConsumerState<DialogPracticeScreen> createState() => _DialogPracticeScreenState();
}

class _DialogPracticeScreenState extends ConsumerState<DialogPracticeScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  DateTime? _startTime;
  int _elapsedSeconds = 0;
  final Map<int, double> _dialogScores = {};
  
  int _currentDialogIndex = 0;
  RecordingState _recordingState = RecordingState.idle;
  PronunciationAssessmentResult? _currentAssessmentResult;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  bool _isPlayingAudio = false;
  
  Map<String, dynamic> get _currentDialog {
    if (widget.lesson.dialogues.isEmpty) {
      return {};
    }
    if (_currentDialogIndex >= widget.lesson.dialogues.length) {
      return {};
    }
    return widget.lesson.dialogues[_currentDialogIndex];
  }
  
  bool get _isUserTurn => _currentDialog['speaker'] == 'Staff';

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    // レッスン開始を記録（チュートリアルレッスンの場合はスキップ）
    if (widget.onComplete == null) {
      // 通常のレッスンの場合のみ進捗を記録
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // UUIDが特別なチュートリアル用IDでないことを確認
        if (!widget.lesson.id.startsWith('00000000-0000-0000-0000-')) {
          ref.read(progressServiceProvider).startLesson(widget.lesson.id);
        }
      });
    }
    
    // 初回の音声自動再生
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoPlayDialog();
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  // 自動再生用の関数
  Future<void> _autoPlayDialog() async {
    if (_isPlayingAudio) return;
    
    // 少し遅延を入れてUI描画を待つ
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      await _playDialog();
    }
  }

  // 手動再生用の関数（ボタン押下時）
  Future<void> _playDialog() async {
    if (_isPlayingAudio) return;
    
    setState(() {
      _isPlayingAudio = true;
    });
    
    try {
      final audioPlayer = ref.read(audioPlayerServiceProvider);
      final audioStorage = ref.read(audioStorageServiceProvider);
      
      final text = _currentDialog['text'] as String;
      final speaker = _currentDialog['speaker'] as String;
      
      // 音声設定を決定
      String voice;
      if (_isUserTurn) {
        // ユーザーターン（Staff）は常にSarahの声で発音指導
        voice = CharacterService.getVoiceModel('sarah');
      } else {
        // AIターン（Customer）は選択されたキャラクターの声
        voice = CharacterService.getVoiceModel(widget.lesson.characterId);
      }
      
      final audioUrl = await audioStorage.getOrCreateKeyPhraseAudio(
        phrase: text,
        lessonId: widget.lesson.id,
        voice: voice,
      );
      await audioPlayer.playAudioFromUrl(audioUrl);
    } catch (e) {
      print('Error playing dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('音声の再生に失敗しました。OpenAI APIキーを設定してください。'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '設定方法',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('README_OPENAI_SETUP.mdを参照してください'),
                    duration: Duration(seconds: 5),
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  Future<void> _startRecording() async {
    if (!_isUserTurn) return;
    if (!PlatformUtils.isRecordingSupported) {
      _showWebNotSupportedDialog();
      return;
    }
    
    setState(() {
      _recordingState = RecordingState.recording;
    });
    
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/dialog_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        final config = RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        );
        
        await _audioRecorder.start(config, path: path);
        _recordingStartTime = DateTime.now();
        
        _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (mounted && _recordingState == RecordingState.recording) {
            setState(() {});
          }
        });
      } else {
        setState(() {
          _recordingState = RecordingState.error;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('マイクへのアクセス許可が必要です'),
            backgroundColor: Colors.red,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _recordingState = RecordingState.idle;
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        _recordingState = RecordingState.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('録音開始に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _recordingState = RecordingState.idle;
          });
        }
      });
    }
  }

  Future<void> _stopRecordingAndAssess() async {
    if (!_isUserTurn) return;
    if (!PlatformUtils.isRecordingSupported) {
      _showWebNotSupportedDialog();
      return;
    }
    
    if (_recordingState != RecordingState.recording) return;
    
    // 最小録音時間チェック（1秒未満は無効）
    if (_recordingStartTime != null) {
      final recordingDuration = DateTime.now().difference(_recordingStartTime!);
      if (recordingDuration.inMilliseconds < 1000) {
        _recordingTimer?.cancel();
        _recordingTimer = null;
        
        setState(() {
          _recordingState = RecordingState.error;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('録音時間が短すぎます。もう少し長く録音してください。'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _recordingState = RecordingState.idle;
            });
          }
        });
        return;
      }
    }
    
    setState(() {
      _recordingState = RecordingState.analyzing;
    });
    
    _recordingTimer?.cancel();
    _recordingTimer = null;
    
    final path = await _audioRecorder.stop();
    if (path == null) {
      setState(() {
        _recordingState = RecordingState.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('録音に失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _recordingState = RecordingState.idle;
          });
        }
      });
      return;
    }
    
    // 発音評価
    try {
      final audioFile = File(path);
      final expectedText = _currentDialog['text'] as String;
      
      final result = await ref.read(azureSpeechServiceProvider).assessPronunciation(
        audioFile: audioFile,
        expectedText: expectedText,
      );
      
      if (result != null) {
        setState(() {
          _currentAssessmentResult = result;
          _dialogScores[_currentDialogIndex] = result.pronunciationScore;
                      _recordingState = RecordingState.analyzing;
            _recordingStartTime = null;
        });
        
        _showFeedbackDialog(result);
        
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _recordingState = RecordingState.idle;
            });
          }
        });
      } else {
        throw Exception('発音評価結果を取得できませんでした');
      }
      
      try {
        await audioFile.delete();
      } catch (_) {}
    } catch (e) {
      print('発音評価エラー: $e');
      
      setState(() {
        _recordingState = RecordingState.error;
        _recordingStartTime = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('発音評価に失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _recordingState = RecordingState.idle;
          });
        }
      });
    }
  }

  void _showFeedbackDialog(PronunciationAssessmentResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          result.pronunciationScore >= 80 ? '素晴らしい！' : '良い調子です！',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildScoreBar('総合スコア', result.pronunciationScore, Colors.blue),
              const SizedBox(height: 8),
              _buildScoreBar('正確さ', result.accuracyScore, Colors.green),
              const SizedBox(height: 8),
              _buildScoreBar('流暢さ', result.fluencyScore, Colors.orange),
              const SizedBox(height: 8),
              _buildScoreBar('完全性', result.completenessScore, Colors.purple),
              const SizedBox(height: 16),
              Text(
                result.pronunciationScore >= 80
                    ? 'ネイティブレベルに近い発音です！'
                    : 'もう少し練習すれば完璧になります！',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              
              // 単語ごとの評価を表示
              if (result.wordScores != null && result.wordScores!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  '単語ごとの評価:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Builder(
                    builder: (context) {
                      // 重複する単語を除去
                      final uniqueWords = <String, WordScore>{};
                      for (final word in result.wordScores!) {
                        if (!uniqueWords.containsKey(word.word.toLowerCase())) {
                          uniqueWords[word.word.toLowerCase()] = word;
                        }
                      }
                      final filteredWords = uniqueWords.values.toList();
                      
                      return Wrap(
                        spacing: 4,
                        runSpacing: 8,
                        children: filteredWords.map((word) {
                          return RichText(
                            text: TextSpan(
                              text: word.word,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _getWordScoreColor(word.accuracyScore),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('もう一度'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentDialogIndex < widget.lesson.dialogues.length - 1) {
                setState(() {
                  _currentDialogIndex++;
                  _currentAssessmentResult = null;
                });
              } else {
                if (widget.onComplete != null) {
                  // チュートリアルモードの場合は直接完了処理を実行
                  widget.onComplete!();
                } else {
                  // 通常のレッスンモードの場合は完了ダイアログを表示
                  _showCompletionDialog();
                }
              }
            },
            child: Text(
              _currentDialogIndex < widget.lesson.dialogues.length - 1
                  ? '次のダイアログへ'
                  : '完了',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreBar(String label, double score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text('${score.toInt()}%', style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Color _getWordScoreColor(double score) {
    if (score >= 90) {
      return const Color(0xFF4CAF50); // 濃い緑
    } else if (score >= 80) {
      return const Color(0xFF8BC34A); // 明るい緑
    } else if (score >= 70) {
      return const Color(0xFFFFEB3B); // 黄色
    } else if (score >= 60) {
      return const Color(0xFFFF9800); // オレンジ
    } else {
      return const Color(0xFFE91E63); // ピンク/赤
    }
  }

  void _showWebNotSupportedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Web版のお知らせ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Web版では録音機能がご利用いただけません。',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 録音機能をご利用いただくには',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• スマートフォンアプリ版をご利用ください\n• iOS/Androidアプリで録音・発音評価が可能です',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToNextDialog();
            },
            child: const Text('次へ進む'),
          ),
        ],
      ),
    );
  }

  void _proceedToNextDialog() {
    if (_currentDialogIndex < widget.lesson.dialogues.length - 1) {
      setState(() {
        _currentDialogIndex++;
        _currentAssessmentResult = null;
      });
      // 次のダイアログに移動時も自動再生
      _autoPlayDialog();
    } else {
      if (widget.onComplete != null) {
        // チュートリアルモードの場合は直接完了処理を実行
        widget.onComplete!();
      } else {
        // 通常のレッスンモードの場合は完了ダイアログを表示
        _showCompletionDialog();
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Text('ダイアログ練習完了！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'すべてのダイアログの練習が完了しました！',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '次はAI会話練習で実際の会話を実践しましょう！',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onComplete != null) {
                widget.onComplete!();
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('レッスン一覧へ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onComplete != null) {
                widget.onComplete!();
              } else {
                context.push('/lesson/${widget.lesson.id}/ai-conversation');
              }
            },
            child: Text(widget.onComplete != null ? '次へ' : 'AI会話練習へ'),
          ),
        ],
      ),
    );
  }

  // 録音ボタンの色を取得
  Color _getRecordingButtonColor() {
    switch (_recordingState) {
      case RecordingState.recording:
        return Colors.red.shade500;
      case RecordingState.analyzing:
        return Colors.orange.shade500;
      case RecordingState.error:
        return Colors.grey.shade500;
      case RecordingState.idle:
      default:
        return Colors.green.shade500;
    }
  }
  
  // 録音ボタンのサイズを取得
  double _getRecordingButtonSize() {
    switch (_recordingState) {
      case RecordingState.recording:
        return 140;
      case RecordingState.analyzing:
        return 130;
      case RecordingState.error:
        return 125;
      case RecordingState.idle:
      default:
        return 120;
    }
  }

  // 録音ボタンの色を取得
  List<Color> _getRecordingButtonColors() {
    switch (_recordingState) {
      case RecordingState.recording:
        return [Colors.red.shade400, Colors.red.shade600];
      case RecordingState.analyzing:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case RecordingState.error:
        return [Colors.grey.shade400, Colors.grey.shade600];
      case RecordingState.idle:
      default:
        return [Colors.green.shade400, Colors.green.shade600];
    }
  }

  // 録音ボタンの影の色を取得
  Color _getRecordingButtonShadowColor() {
    switch (_recordingState) {
      case RecordingState.recording:
        return Colors.red;
      case RecordingState.analyzing:
        return Colors.orange;
      case RecordingState.error:
        return Colors.grey;
      case RecordingState.idle:
      default:
        return Colors.green;
    }
  }

  // 録音ボタンのぼかし半径を取得
  double _getRecordingButtonBlurRadius() {
    switch (_recordingState) {
      case RecordingState.recording:
        return 25;
      case RecordingState.analyzing:
        return 20;
      case RecordingState.error:
        return 10;
      case RecordingState.idle:
      default:
        return 15;
    }
  }

  // 録音ボタンの広がり半径を取得
  double _getRecordingButtonSpreadRadius() {
    switch (_recordingState) {
      case RecordingState.recording:
        return 8;
      case RecordingState.analyzing:
        return 5;
      case RecordingState.error:
        return 2;
      case RecordingState.idle:
      default:
        return 3;
    }
  }

  // 録音ボタンのコンテンツを作成
  Widget _buildRecordingButtonContent() {
    switch (_recordingState) {
      case RecordingState.recording:
        return const Icon(Icons.stop, size: 56, color: Colors.white);
      case RecordingState.analyzing:
        return const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4,
          ),
        );
      case RecordingState.error:
        return const Icon(Icons.error_outline, size: 48, color: Colors.white);
      case RecordingState.idle:
      default:
        return const Icon(Icons.mic, size: 48, color: Colors.white);
    }
  }

  // 録音状態の色を取得
  Color _getRecordingStatusColor() {
    switch (_recordingState) {
      case RecordingState.recording:
        return Colors.red.shade700;
      case RecordingState.analyzing:
        return Colors.orange.shade700;
      case RecordingState.error:
        return Colors.grey.shade700;
      case RecordingState.idle:
      default:
        return Colors.green.shade700;
    }
  }

  // 録音状態のアイコンを取得
  Widget _getRecordingStatusIcon() {
    switch (_recordingState) {
      case RecordingState.recording:
        return Icon(Icons.mic, color: _getRecordingStatusColor(), size: 20);
      case RecordingState.analyzing:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: _getRecordingStatusColor(),
            strokeWidth: 2,
          ),
        );
      case RecordingState.error:
        return Icon(Icons.error, color: _getRecordingStatusColor(), size: 20);
      case RecordingState.idle:
      default:
        return Icon(Icons.touch_app, color: _getRecordingStatusColor(), size: 20);
    }
  }

  // 録音状態のテキストを取得
  String _getRecordingStatusText() {
    switch (_recordingState) {
      case RecordingState.recording:
        if (_recordingStartTime != null) {
          final duration = DateTime.now().difference(_recordingStartTime!);
          final seconds = duration.inSeconds;
          final milliseconds = (duration.inMilliseconds % 1000) ~/ 100;
          return '話してください... ${seconds}.${milliseconds}秒';
        }
        return '話してください...';
      case RecordingState.analyzing:
        return '音声を処理中...';
      case RecordingState.error:
        return 'エラーが発生しました';
      case RecordingState.idle:
      default:
        return '長押しで録音';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lesson.dialogues.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ダイアログ練習'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('このレッスンにはダイアログがありません'),
            ],
          ),
        ),
      );
    }

    final progress = (_currentDialogIndex + 1) / widget.lesson.dialogues.length;
    final speaker = _currentDialog['speaker'] as String;
    final text = _currentDialog['text'] as String;
    final japanese = _currentDialog['japanese'] as String? ?? '';
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40),
          color: Colors.blue,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ダイアログ練習',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 背景画像
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/lesson_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // メインコンテンツ
          SafeArea(
            child: Column(
              children: [
                // プログレスバー
                Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.blue.shade100,
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                      minHeight: 6,
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // 進捗インジケーター
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_currentDialogIndex + 1}/${widget.lesson.dialogues.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // アバターと名前
                Column(
                  children: [
                    // アバター画像
                    AnimatedAvatar(
                      isPlaying: _isPlayingAudio,
                      size: 180,
                      fallbackAvatarPath: _isUserTurn 
                          ? CharacterService.getAvatarImagePath('sarah')
                          : CharacterService.getAvatarImagePath(widget.lesson.characterId),
                    ),
                    const SizedBox(height: 10),
                    
                    // キャラクター名
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isUserTurn ? Colors.green.shade500 : Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isUserTurn 
                            ? 'Sarah - 発音コーチ'
                            : CharacterService.getDisplayName(widget.lesson.characterId),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // ダイアログ吹き出し
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isUserTurn ? Colors.green.shade400 : Colors.blue.shade400,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _isUserTurn ? Colors.green.shade700 : Colors.blue.shade700,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          
                          // 日本語訳
                          if (japanese.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Divider(color: (_isUserTurn ? Colors.green : Colors.blue).shade200, thickness: 1, height: 12),
                            const SizedBox(height: 4),
                            Text(
                              japanese,
                              style: TextStyle(
                                fontSize: 12,
                                color: _isUserTurn ? Colors.green.shade600 : Colors.blue.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 録音ボタン（ユーザーターンのみ）
                if (_isUserTurn) ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // 背景の円
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      
                      // 録音ボタン本体
                      GestureDetector(
                        onTapDown: (_) => _startRecording(),
                        onTapUp: (_) => _stopRecordingAndAssess(),
                        onTapCancel: () async {
                          await _audioRecorder.stop();
                          _recordingTimer?.cancel();
                          _recordingTimer = null;
                          setState(() {
                            _recordingState = RecordingState.idle;
                            _recordingStartTime = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _recordingState == RecordingState.recording ? 80 : 70,
                          height: _recordingState == RecordingState.recording ? 80 : 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getRecordingButtonColor(),
                            boxShadow: [
                              BoxShadow(
                                color: _getRecordingButtonColor().withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _recordingState == RecordingState.recording ? Icons.stop : Icons.mic,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 録音状態テキスト
                  Text(
                    _getRecordingStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade700,
                    ),
                  ),
                ] else ...[
                  // AIターンの場合は説明テキスト
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 50),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade600, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${CharacterService.getDisplayName(widget.lesson.characterId)}が話しています',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // 音声再生ボタン
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _isPlayingAudio ? null : _playDialog,
                    icon: Icon(
                      Icons.volume_up,
                      color: _isPlayingAudio 
                          ? Colors.grey 
                          : (_isUserTurn ? Colors.green.shade600 : Colors.blue.shade600),
                      size: 28,
                    ),
                    iconSize: 42,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // ナビゲーションボタン
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 前へボタン
                      Container(
                        decoration: BoxDecoration(
                          color: _currentDialogIndex > 0
                              ? Colors.white
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: _currentDialogIndex > 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: _currentDialogIndex > 0
                                ? () {
                                    setState(() {
                                      _currentDialogIndex--;
                                      _currentAssessmentResult = null;
                                    });
                                    _autoPlayDialog();
                                  }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chevron_left,
                                    color: _currentDialogIndex > 0 
                                        ? Colors.blue.shade600 
                                        : Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '前へ',
                                    style: TextStyle(
                                      color: _currentDialogIndex > 0 
                                          ? Colors.blue.shade600 
                                          : Colors.grey.shade400,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 次へ/完了ボタン
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: !_isUserTurn || _currentAssessmentResult != null || 
                                   _recordingState == RecordingState.idle
                                ? [Colors.blue.shade400, Colors.blue.shade600]
                                : [Colors.grey.shade300, Colors.grey.shade400],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: (!_isUserTurn || _currentAssessmentResult != null || 
                                     _recordingState == RecordingState.idle
                                  ? Colors.blue
                                  : Colors.grey).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: !_isUserTurn || _currentAssessmentResult != null || 
                                   _recordingState == RecordingState.idle
                                ? () => _proceedToNextDialog()
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Text(
                                    _currentDialogIndex < widget.lesson.dialogues.length - 1
                                        ? '次へ'
                                        : '完了',
                                    style: TextStyle(
                                      color: !_isUserTurn || _currentAssessmentResult != null || 
                                             _recordingState == RecordingState.idle
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right,
                                    color: !_isUserTurn || _currentAssessmentResult != null || 
                                           _recordingState == RecordingState.idle
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 