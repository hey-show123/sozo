import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/data/models/lesson_model.dart';
import 'package:sozo_app/services/audio_player_service.dart';
import 'package:sozo_app/services/audio_storage_service.dart';
import 'package:sozo_app/services/openai_service.dart';
import 'package:sozo_app/services/azure_speech_service.dart';
import 'package:sozo_app/services/progress_service.dart';
import 'package:sozo_app/presentation/widgets/xp_animation.dart';
import 'package:sozo_app/presentation/widgets/achievement_notification.dart';
import 'package:sozo_app/presentation/widgets/level_up_notification.dart';
import 'package:sozo_app/core/utils/platform_utils.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

enum RecordingState {
  idle,           // 待機状態
  recording,      // 録音中
  processing,     // 音声処理中
  error,          // エラー状態
  success,        // 成功状態
}

class DialogPracticeScreen extends ConsumerStatefulWidget {
  final LessonModel lesson;

  const DialogPracticeScreen({
    super.key,
    required this.lesson,
  });

  @override
  ConsumerState<DialogPracticeScreen> createState() => _DialogPracticeScreenState();
}

class _DialogPracticeScreenState extends ConsumerState<DialogPracticeScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  late final AzureSpeechService _azureSpeechService;
  DateTime? _startTime;
  int _elapsedSeconds = 0;
  final Map<int, double> _dialogScores = {};
  
  int _currentDialogIndex = 0;
  RecordingState _recordingState = RecordingState.idle;
  PronunciationAssessmentResult? _currentAssessmentResult;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  
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
    _azureSpeechService = AzureSpeechService();
    _startTime = DateTime.now();
    
    // レッスン開始を記録
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressServiceProvider).startLesson(widget.lesson.id);
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _playDialog() async {
    if (_isUserTurn) return;
    
    try {
      final audioPlayer = ref.read(audioPlayerServiceProvider);
      final audioStorage = ref.read(audioStorageServiceProvider);
      
      final text = _currentDialog['text'] as String;
      final speaker = _currentDialog['speaker'] as String;
      
      // スピーカーに基づいて音声設定を変更
      // Customer（お客さん）の音声はnovaを使用（明るく親しみやすい）
      // Staff（スタッフ）の音声はfableを使用（温かみのあるプロフェッショナル）
      final voice = speaker == 'Customer' ? 'nova' : 'fable';
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
      _recordingState = RecordingState.processing;
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
      
      final result = await _azureSpeechService.assessPronunciation(
        audioFile: audioFile,
        expectedText: expectedText,
      );
      
      if (result != null) {
        setState(() {
          _currentAssessmentResult = result;
          _dialogScores[_currentDialogIndex] = result.pronunciationScore;
          _recordingState = RecordingState.success;
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
                _showCompletionDialog();
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
    } else {
      _showCompletionDialog();
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
              Navigator.pop(context);
            },
            child: const Text('レッスン一覧へ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/lesson/${widget.lesson.id}/ai-conversation');
            },
            child: const Text('AI会話練習へ'),
          ),
        ],
      ),
    );
  }

  // 録音ボタンのサイズを取得
  double _getRecordingButtonSize() {
    switch (_recordingState) {
      case RecordingState.recording:
        return 140;
      case RecordingState.processing:
        return 130;
      case RecordingState.success:
        return 135;
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
      case RecordingState.processing:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case RecordingState.success:
        return [Colors.green.shade400, Colors.green.shade600];
      case RecordingState.error:
        return [Colors.grey.shade400, Colors.grey.shade600];
      case RecordingState.idle:
      default:
        return [Colors.blue.shade400, Colors.blue.shade600];
    }
  }

  // 録音ボタンの影の色を取得
  Color _getRecordingButtonShadowColor() {
    switch (_recordingState) {
      case RecordingState.recording:
        return Colors.red;
      case RecordingState.processing:
        return Colors.orange;
      case RecordingState.success:
        return Colors.green;
      case RecordingState.error:
        return Colors.grey;
      case RecordingState.idle:
      default:
        return Colors.blue;
    }
  }

  // 録音ボタンのぼかし半径を取得
  double _getRecordingButtonBlurRadius() {
    switch (_recordingState) {
      case RecordingState.recording:
        return 25;
      case RecordingState.processing:
        return 20;
      case RecordingState.success:
        return 22;
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
      case RecordingState.processing:
        return 5;
      case RecordingState.success:
        return 6;
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
      case RecordingState.processing:
        return const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4,
          ),
        );
      case RecordingState.success:
        return const Icon(Icons.check, size: 52, color: Colors.white);
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
      case RecordingState.processing:
        return Colors.orange.shade700;
      case RecordingState.success:
        return Colors.green.shade700;
      case RecordingState.error:
        return Colors.grey.shade700;
      case RecordingState.idle:
      default:
        return Colors.blue.shade700;
    }
  }

  // 録音状態のアイコンを取得
  Widget _getRecordingStatusIcon() {
    switch (_recordingState) {
      case RecordingState.recording:
        return Icon(Icons.mic, color: _getRecordingStatusColor(), size: 20);
      case RecordingState.processing:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: _getRecordingStatusColor(),
            strokeWidth: 2,
          ),
        );
      case RecordingState.success:
        return Icon(Icons.check_circle, color: _getRecordingStatusColor(), size: 20);
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
      case RecordingState.processing:
        return '音声を処理中...';
      case RecordingState.success:
        return '評価完了！';
      case RecordingState.error:
        return 'エラーが発生しました';
      case RecordingState.idle:
      default:
        return _isUserTurn ? '長押しで録音' : 'AIの番です';
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
      appBar: AppBar(
        title: const Text('ダイアログ練習'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blue.shade800,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Container(
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
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // スクロール可能なコンテンツ
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // 進捗状況
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade600, Colors.blue.shade400],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_currentDialogIndex + 1} / ${widget.lesson.dialogues.length}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // ダイアログカード
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              // 話者
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isUserTurn
                                        ? [Colors.green.shade600, Colors.green.shade400]
                                        : [Colors.blue.shade600, Colors.blue.shade400],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isUserTurn ? Icons.cut : Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      speaker,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // ダイアログテキスト
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              
                              // 日本語訳
                              if (japanese.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.cyan.shade50, Colors.blue.shade50],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Text(
                                    japanese,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              
                              // 再生ボタン（AIのターンのみ）
                              if (!_isUserTurn) ...[
                                const SizedBox(height: 28),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: _playDialog,
                                    icon: const Icon(Icons.volume_up),
                                    iconSize: 32,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      fixedSize: const Size(70, 70),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 会話履歴
                      if (_currentDialogIndex > 0) ...[
                        Text(
                          '会話履歴',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_currentDialogIndex, (index) {
                          final prevDialog = widget.lesson.dialogues[index];
                          final prevSpeaker = prevDialog['speaker'] as String;
                          final prevText = prevDialog['text'] as String;
                          final isPrevUserTurn = prevSpeaker == 'Staff';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isPrevUserTurn
                                  ? Colors.green.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isPrevUserTurn
                                    ? Colors.green.shade200
                                    : Colors.blue.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isPrevUserTurn ? Icons.cut : Icons.person,
                                  size: 20,
                                  color: isPrevUserTurn
                                      ? Colors.green.shade600
                                      : Colors.blue.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    prevText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              
              // 固定コンテンツ（録音ボタンとナビゲーション）
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // 録音ボタン（ユーザーのターンのみ）
                    if (_isUserTurn) ...[
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
                          width: _getRecordingButtonSize(),
                          height: _getRecordingButtonSize(),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _getRecordingButtonColors(),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getRecordingButtonShadowColor().withOpacity(0.4),
                                blurRadius: _getRecordingButtonBlurRadius(),
                                spreadRadius: _getRecordingButtonSpreadRadius(),
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: _buildRecordingButtonContent(),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getRecordingStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getRecordingStatusColor().withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _getRecordingStatusIcon(),
                            const SizedBox(width: 8),
                            Text(
                              _getRecordingStatusText(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _getRecordingStatusColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                    
                    // ナビゲーションボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavigationButton(
                          '前へ',
                          Icons.arrow_back_ios,
                          _currentDialogIndex > 0,
                          () => setState(() {
                            _currentDialogIndex--;
                            _currentAssessmentResult = null;
                          }),
                          isLeft: true,
                        ),
                        _buildNavigationButton(
                          _currentDialogIndex < widget.lesson.dialogues.length - 1 ? '次へ' : '完了',
                          Icons.arrow_forward_ios,
                          !_isUserTurn || _currentAssessmentResult != null || _recordingState == RecordingState.idle,
                          () => _proceedToNextDialog(),
                          isLeft: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    String label,
    IconData icon,
    bool isEnabled,
    VoidCallback onPressed, {
    required bool isLeft,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600])
            : null,
        color: isEnabled ? null : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLeft) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: isEnabled ? Colors.white : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (!isLeft) ...[
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    size: 18,
                    color: isEnabled ? Colors.white : Colors.grey.shade500,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 