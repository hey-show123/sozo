import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sozo_app/presentation/widgets/xp_animation.dart';
import 'package:sozo_app/presentation/widgets/achievement_notification.dart';
import 'package:sozo_app/presentation/widgets/level_up_notification.dart';
import 'package:sozo_app/presentation/widgets/animated_avatar.dart';
import 'package:sozo_app/data/models/lesson_model.dart';
import 'package:sozo_app/services/audio_player_service.dart';
import 'package:sozo_app/services/audio_storage_service.dart';
import 'package:sozo_app/services/progress_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sozo_app/services/character_service.dart';
import 'package:sozo_app/presentation/providers/user_profile_provider.dart';
import 'package:sozo_app/services/azure_speech_service.dart';
import 'package:sozo_app/core/utils/platform_utils.dart';
import 'listening_practice_screen.dart';

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
  bool _isPlayingAudio = false;
  
  KeyPhrase get _currentPhrase => widget.lesson.keyPhrases[_currentPhraseIndex];
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    

    
    // レッスン開始を記録
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressServiceProvider).startLesson(widget.lesson.id);
    });
    
    // 初回の音声自動再生
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoPlayPhrase();
    });
  }
  
  @override
  void dispose() {
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }
  
  // 自動再生用の関数
  Future<void> _autoPlayPhrase() async {
    if (_isPlayingAudio) return;
    
    // 少し遅延を入れてUI描画を待つ
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      await _playPhrase();
    }
  }

  // 手動再生用の関数（ボタン押下時）
  Future<void> _playPhrase() async {
    if (_isPlayingAudio) return;
    
    setState(() {
      _isPlayingAudio = true;
    });
    
    try {
      final audioPlayerService = ref.read(audioPlayerServiceProvider);
      final audioStorage = ref.read(audioStorageServiceProvider);
      
      // キャラクターの音声でフレーズを再生
      final voice = CharacterService.getVoiceModel(widget.lesson.characterId);
      final audioUrl = await audioStorage.getOrCreateKeyPhraseAudio(
        phrase: _currentPhrase.phrase,
        lessonId: widget.lesson.id,
        voice: voice,
      );
      
      // 音声を再生開始（非同期で開始）
      final playbackFuture = audioPlayerService.playAudioFromUrl(audioUrl);
      
      // フレーズの長さから推定再生時間を計算（単語数 * 600ms + 余裕時間）
      final words = _currentPhrase.phrase.split(' ').length;
      final estimatedDuration = Duration(milliseconds: (words * 600) + 1000);
      
      // 推定時間待機（最低2秒、最大8秒）
      final waitDuration = Duration(
        milliseconds: estimatedDuration.inMilliseconds.clamp(2000, 8000),
      );
      
      await Future.wait([
        playbackFuture,
        Future.delayed(waitDuration),
      ]);
      
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
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
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
      // マイクの許可を確認
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
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
        return;
      }
      
      // 前の録音が残っている場合は停止
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      // 録音先のパスを生成
      final tempDir = await getTemporaryDirectory();
      // iOSの場合は拡張子を.m4aに変更
      final extension = Platform.isIOS ? 'm4a' : 'wav';
      final fileName = 'key_phrase_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final path = '${tempDir.path}/$fileName';
      
      print('録音開始: $path');
      print('録音形式: ${Platform.isIOS ? "AAC (iOS)" : "WAV"}');
      
      // 録音設定（iOSシミュレーター対応）
      RecordConfig config;
      if (Platform.isIOS) {
        // iOS専用の設定 - AACを使用
        config = const RecordConfig(
          encoder: AudioEncoder.aacLc,  // iOSではAACを使用
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
          // iOSシミュレーター用の追加設定
          echoCancel: false,
          noiseSuppress: false,
          autoGain: false,
        );
      } else {
        // その他のプラットフォーム
        config = const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
          echoCancel: false,
          noiseSuppress: false,
        );
      }
      
      // 少し待機してから録音開始（iOSシミュレーターの安定性のため）
      await Future.delayed(const Duration(milliseconds: 100));
      
      await _audioRecorder.start(config, path: path);
      _recordingStartTime = DateTime.now();  // 録音開始時刻を記録
      
      // 録音が実際に開始されたか確認
      final isRecording = await _audioRecorder.isRecording();
      if (!isRecording) {
        throw Exception('録音を開始できませんでした');
      }
      
      print('録音開始成功');
      
      // 録音時間を更新するタイマーを開始
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (mounted && _recordingState == RecordingState.recording) {
          setState(() {
            // 状態を更新してUIをリフレッシュ
          });
        }
      });
      
    } catch (e) {
      print('録音開始エラー: $e');
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
      // iOSシミュレーターは500msでも許可
      final minDuration = Platform.isIOS ? 500 : 1000;
      if (recordingDuration.inMilliseconds < minDuration) {
        // タイマーをキャンセル
        _recordingTimer?.cancel();
        _recordingTimer = null;
        
        setState(() {
          _recordingState = RecordingState.error;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('録音時間が短すぎます。${minDuration / 1000}秒以上録音してください。'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
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
    
    try {
      // 録音が実際に行われているか確認
      final isRecording = await _audioRecorder.isRecording();
      if (!isRecording) {
        throw Exception('録音が正しく行われていません');
      }
      
      print('録音停止中...');
      final path = await _audioRecorder.stop();
      print('録音停止完了: $path');
      
      if (path == null) {
        throw Exception('録音ファイルのパスが取得できませんでした');
      }
      
      // ファイルが実際に作成されているか確認（少し待機）
      await Future.delayed(const Duration(milliseconds: 200));
      
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
      
      // 最小ファイルサイズチェック
      // iOSの場合は5KB、その他は10KB
      final minFileSize = Platform.isIOS ? 5000 : 10000;
      if (fileSize < minFileSize) {
        // iOSシミュレーターの場合は、さらに小さなサイズも許可
        if (Platform.isIOS && 
            (Platform.environment['SIMULATOR_DEVICE_NAME'] != null || 
             Platform.localHostname.endsWith('.simulator')) &&
            fileSize > 1000) {
          print('iOSシミュレーター: 小さなファイルサイズを許可 ($fileSize bytes)');
        } else {
          // 録音が失敗している可能性が高い
          if (fileSize < 100) {
            throw Exception('録音に失敗しました。マイクの許可を確認してください。');
          } else {
            throw Exception('録音が短すぎるか、音声が入っていない可能性があります。もう一度お試しください。');
          }
        }
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
  
  // 録音ボタンの色を取得（シンプル化）
  Color _getRecordingButtonColor() {
    switch (_recordingState) {
      case RecordingState.recording:
        return Colors.red.shade500;
      case RecordingState.processing:
        return Colors.orange.shade500;
      case RecordingState.success:
        return Colors.green.shade500;
      case RecordingState.error:
        return Colors.grey.shade500;
      case RecordingState.idle:
      default:
        return Colors.blue.shade500;
    }
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
                      '次はリスニング練習で会話を聞いてみましょう！',
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ListeningPracticeScreen(lesson: widget.lesson),
                ),
              );
            },
            child: const Text('リスニング練習へ'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = (_currentPhraseIndex + 1) / widget.lesson.keyPhrases.length;
    
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
          'キーフレーズ練習',
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
                      const Icon(Icons.star, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_currentPhraseIndex + 1}/${widget.lesson.keyPhrases.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // アバターと名前
                Column(
                  children: [
                    // アバター画像
                    AnimatedAvatar(
                      isPlaying: _isPlayingAudio,
                      size: 180,
                      fallbackAvatarPath: CharacterService.getAvatarImagePath(widget.lesson.characterId),
                    ),
                    const SizedBox(height: 10),
                    
                    // キャラクター名
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        CharacterService.getDisplayName(widget.lesson.characterId),
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
                
                // フレーズ吹き出し
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.35,
                      minHeight: 120,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blue.shade400,
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
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text(
                              _currentPhrase.phrase,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          
                          // 発音記号（オプション）
                          if (_showPhonetic) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: Text(
                                _currentPhrase.pronunciation ?? '(発音記号なし)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                          
                          // 意味（オプション）
                          if (_showMeaning) ...[
                            const SizedBox(height: 8),
                            Divider(color: Colors.blue.shade200, thickness: 1.5, height: 16),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: Text(
                                _currentPhrase.meaning,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 録音ボタン
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景の円（美容室のインテリアのような雰囲気）
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // 操作ボタン（再生・表示オプション）
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        onPressed: _isPlayingAudio ? null : _playPhrase,
                        icon: Icon(
                          Icons.volume_up,
                          color: _isPlayingAudio ? Colors.grey : Colors.blue.shade600,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    
                    // 表示オプション
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _showPhonetic = !_showPhonetic);
                            },
                            icon: Icon(
                              Icons.abc,
                              color: _showPhonetic ? Colors.blue.shade600 : Colors.grey.shade400,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.grey.shade300,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => _showMeaning = !_showMeaning);
                            },
                            icon: Icon(
                              Icons.translate,
                              color: _showMeaning ? Colors.blue.shade600 : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // ナビゲーションボタン
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 前へボタン
                      Container(
                        decoration: BoxDecoration(
                          color: _currentPhraseIndex > 0
                              ? Colors.white
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: _currentPhraseIndex > 0
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
                            onTap: _currentPhraseIndex > 0
                                ? () {
                                    setState(() => _currentPhraseIndex--);
                                    _autoPlayPhrase();
                                  }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chevron_left,
                                    color: _currentPhraseIndex > 0 
                                        ? Colors.blue.shade600 
                                        : Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '前へ',
                                    style: TextStyle(
                                      color: _currentPhraseIndex > 0 
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
                            colors: [Colors.blue.shade400, Colors.blue.shade600],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: _currentPhraseIndex < widget.lesson.keyPhrases.length - 1
                                ? () {
                                    setState(() => _currentPhraseIndex++);
                                    _autoPlayPhrase();
                                  }
                                : _showCompletionDialog,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Text(
                                    _currentPhraseIndex < widget.lesson.keyPhrases.length - 1
                                        ? '次へ'
                                        : '完了',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
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
                
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 