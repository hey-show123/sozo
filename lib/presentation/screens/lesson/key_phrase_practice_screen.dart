import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/data/models/lesson_model.dart';
import 'package:sozo_app/services/audio_player_service.dart';
import 'package:sozo_app/services/audio_storage_service.dart';
import 'package:sozo_app/services/azure_speech_service.dart';
import 'package:sozo_app/services/progress_service.dart';
import 'package:sozo_app/presentation/widgets/xp_animation.dart';
import 'package:sozo_app/presentation/widgets/achievement_notification.dart';
import 'package:sozo_app/presentation/widgets/level_up_notification.dart';
import 'package:sozo_app/core/utils/platform_utils.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:go_router/go_router.dart';

enum RecordingState {
  idle,           // 待機状態
  recording,      // 録音中
  processing,     // 音声処理中
  error,          // エラー状態
  success,        // 成功状態
}

class KeyPhrasePracticeScreen extends ConsumerStatefulWidget {
  final LessonModel lesson;
  
  const KeyPhrasePracticeScreen({
    super.key,
    required this.lesson,
  });

  @override
  ConsumerState<KeyPhrasePracticeScreen> createState() => _KeyPhrasePracticeScreenState();
}

class _KeyPhrasePracticeScreenState extends ConsumerState<KeyPhrasePracticeScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  int _currentPhraseIndex = 0;
  RecordingState _recordingState = RecordingState.idle;
  bool _showPhonetic = true;
  bool _showMeaning = true;
  Map<String, PronunciationAssessmentResult?> _assessmentResults = {};
  DateTime? _startTime;
  int _elapsedSeconds = 0;
  DateTime? _recordingStartTime;  // 録音開始時刻を記録
  Timer? _recordingTimer;  // 録音時間更新用タイマー
  
  KeyPhrase get _currentPhrase => widget.lesson.keyPhrases[_currentPhraseIndex];
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    // レッスン開始を記録
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressServiceProvider).startLesson(widget.lesson.id);
    });
  }
  
  @override
  void dispose() {
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _playPhrase() async {
    try {
      final audioPlayer = ref.read(audioPlayerServiceProvider);
      await audioPlayer.playKeyPhrase(
        phrase: _currentPhrase.phrase,
        lessonId: widget.lesson.id,
        audioUrl: _currentPhrase.audioUrl,
      );
    } catch (e) {
      print('Error playing phrase: $e');
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
    if (!PlatformUtils.isRecordingSupported) {
      _showWebNotSupportedDialog();
      return;
    }
    
    // シミュレーターでの警告を表示
    if (Platform.isIOS && (Platform.environment['SIMULATOR_DEVICE_NAME'] != null || 
        Platform.localHostname.endsWith('.simulator'))) {
      _showSimulatorWarningDialog();
    }
    
    setState(() {
      _recordingState = RecordingState.recording;
    });
    
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/key_phrase_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        // 録音設定（シミュレーター対応）
        final config = RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        );
        
        await _audioRecorder.start(config, path: path);
        _recordingStartTime = DateTime.now();  // 録音開始時刻を記録
        
        // 録音時間を更新するタイマーを開始
        _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (mounted && _recordingState == RecordingState.recording) {
            setState(() {
              // 状態を更新してUIをリフレッシュ
            });
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
        // 2秒後に待機状態に戻す
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
      // 2秒後に待機状態に戻す
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
    if (!PlatformUtils.isRecordingSupported) {
      _showWebNotSupportedDialog();
      return;
    }
    
    if (_recordingState != RecordingState.recording) return;
    
    // 最小録音時間チェック（1秒未満は無効）
    if (_recordingStartTime != null) {
      final recordingDuration = DateTime.now().difference(_recordingStartTime!);
      if (recordingDuration.inMilliseconds < 1000) {
        // タイマーをキャンセル
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
        // 2秒後に待機状態に戻す
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
    
    // タイマーをキャンセル
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
      // 2秒後に待機状態に戻す
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
      // 録音ファイルを確認
      final audioFile = File(path);
      if (!await audioFile.exists()) {
        throw Exception('録音ファイルが見つかりません');
      }
      
      // ファイルサイズチェック
      final fileSize = await audioFile.length();
      print('評価するフレーズ: "${_currentPhrase.phrase}"');
      print('録音ファイルパス: $path');
      print('ファイルサイズ: $fileSize bytes');
      
      // 最小ファイルサイズチェック（10KB以下は無音の可能性が高い）
      if (fileSize < 10000) {
        throw Exception('録音が短すぎるか、音声が入っていない可能性があります。もう一度お試しください。');
      }
      
      // Azureサービスを呼び出す
      final speechService = ref.read(azureSpeechServiceProvider);
      final result = await speechService.assessPronunciation(
        audioFile: audioFile,
        expectedText: _currentPhrase.phrase,
      );
      
      if (result != null) {
        // デバッグ情報を表示
        print('認識されたテキスト: "${result.recognizedText}"');
        print('表示テキスト: "${result.displayText}"');
        print('総合スコア: ${result.overallScore}');
        
        setState(() {
          _assessmentResults[_currentPhrase.phrase] = result;
          _recordingState = RecordingState.success;
          _recordingStartTime = null;
        });
        
        // 結果に基づいてフィードバック
        _showFeedbackDialog(result);
        
        // 3秒後に待機状態に戻す
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
      
      // 録音ファイルを削除
      try {
        await audioFile.delete();
      } catch (_) {}
    } catch (e) {
      print('発音評価エラー: $e');
      
      setState(() {
        _recordingState = RecordingState.error;
        _recordingStartTime = null;
      });
      
      // エラーメッセージを表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('発音評価に失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      // 3秒後に待機状態に戻す
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _recordingState = RecordingState.idle;
          });
        }
      });
    }
  }

  void _showSimulatorWarningDialog() {
    // 初回のみ警告を表示
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.yellow),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'シミュレーターでの録音は不安定な場合があります。実機でのテストを推奨します。',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '了解',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
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
            const SizedBox(height: 16),
            const Text(
              'Web版でも次のフレーズに進むことができます。',
              style: TextStyle(fontSize: 14),
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
              _proceedToNextPhrase();
            },
            child: const Text('次のフレーズへ'),
          ),
        ],
      ),
    );
  }

  void _proceedToNextPhrase() {
    if (_currentPhraseIndex < widget.lesson.keyPhrases.length - 1) {
      setState(() {
        _currentPhraseIndex++;
      });
    } else {
      _showCompletionDialog();
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
              if (_currentPhraseIndex < widget.lesson.keyPhrases.length - 1) {
                setState(() {
                  _currentPhraseIndex++;
                });
              } else {
                _showCompletionDialog();
              }
            },
            child: Text(
              _currentPhraseIndex < widget.lesson.keyPhrases.length - 1
                  ? '次のフレーズへ'
                  : '完了',
            ),
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
        return '長押しで録音';
    }
  }

  Widget _buildScoreBar(String label, double score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${score.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
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
            const Text('キーフレーズ練習完了！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'すべてのキーフレーズの練習が完了しました！',
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
                      '次はダイアログ練習で実際の会話を練習しましょう！',
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
              context.push(
                '/lesson/${widget.lesson.id}/dialog',
                extra: widget.lesson,
              );
            },
            child: const Text('ダイアログ練習へ'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = (_currentPhraseIndex + 1) / widget.lesson.keyPhrases.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('キーフレーズ練習'),
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
                      const Icon(Icons.star, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_currentPhraseIndex + 1} / ${widget.lesson.keyPhrases.length}',
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
                
                // キーフレーズカード
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
                        // フレーズ
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade400],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _currentPhrase.phrase,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        // 発音記号
                        if (_showPhonetic && _currentPhrase.pronunciation != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              _currentPhrase.pronunciation!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                        
                        // 意味
                        if (_showMeaning) ...[
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
                              _currentPhrase.meaning,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        
                        // 使い方
                        if (_currentPhrase.usage.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            _currentPhrase.usage,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        
                        // 再生ボタン
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
                            onPressed: _playPhrase,
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
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 表示オプション
                Wrap(
                  spacing: 12,
                  children: [
                    _buildToggleChip(
                      '発音記号',
                      _showPhonetic,
                      Icons.text_fields,
                      (value) => setState(() => _showPhonetic = value),
                    ),
                    _buildToggleChip(
                      '意味',
                      _showMeaning,
                      Icons.translate,
                      (value) => setState(() => _showMeaning = value),
                    ),
                                    ],
                ),
                    ],
                  ),
                ),
              ),
              
              // 固定コンテンツ（録音ボタンとナビゲーション）
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // 録音ボタン
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
                
                    // ナビゲーションボタン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavigationButton(
                          '前へ',
                          Icons.arrow_back_ios,
                          _currentPhraseIndex > 0,
                          () => setState(() => _currentPhraseIndex--),
                          isLeft: true,
                        ),
                        _buildNavigationButton(
                          '次へ',
                          Icons.arrow_forward_ios,
                          _currentPhraseIndex < widget.lesson.keyPhrases.length - 1,
                          () => setState(() => _currentPhraseIndex++),
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

  Widget _buildToggleChip(
    String label,
    bool isSelected,
    IconData icon,
    Function(bool) onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.blue.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 10 : 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.blue.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.blue.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
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