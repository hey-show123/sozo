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
import 'package:sozo_app/services/character_service.dart';
import 'package:sozo_app/presentation/providers/user_profile_provider.dart';
import 'package:sozo_app/services/azure_speech_service.dart';
import 'package:sozo_app/services/openai_service.dart';
import 'package:sozo_app/core/utils/platform_utils.dart';
import 'package:sozo_app/services/achievement_service.dart';
import 'package:sozo_app/presentation/providers/auth_provider.dart';
import 'package:sozo_app/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 応用練習データモデル
class ApplicationPractice {
  final String practiceId;
  final String targetPhrase;
  final String hint;
  final String example;
  final List<String> tips;

  ApplicationPractice({
    required this.practiceId,
    required this.targetPhrase,
    required this.hint,
    required this.example,
    required this.tips,
  });

  factory ApplicationPractice.fromJson(Map<String, dynamic> json) {
    return ApplicationPractice(
      practiceId: json['practice_id'] ?? '',
      targetPhrase: json['target_phrase'] ?? '',
      hint: json['hint'] ?? '',
      example: json['example'] ?? '',
      tips: List<String>.from(json['tips'] ?? []),
    );
  }
}

enum RecordingState {
  idle,
  recording,
  processing,
  error,
  success,
}

// 文法評価の結果
class GrammarAssessmentResult {
  final String recognizedText;
  final List<WordGrammarScore> wordScores;
  final double grammarScore;
  final double completenessScore;
  final List<String> missingWords;
  final List<String> extraWords;

  GrammarAssessmentResult({
    required this.recognizedText,
    required this.wordScores,
    required this.grammarScore,
    required this.completenessScore,
    required this.missingWords,
    required this.extraWords,
  });
}

// 単語ごとの評価
class WordGrammarScore {
  final String word;
  final bool isCorrect;
  final bool isExtra;
  final bool isMissing;
  final double pronunciationScore;

  WordGrammarScore({
    required this.word,
    required this.isCorrect,
    required this.isExtra,
    required this.isMissing,
    required this.pronunciationScore,
  });
}

class ApplicationPracticeScreen extends ConsumerStatefulWidget {
  final LessonModel lesson;
  
  const ApplicationPracticeScreen({
    super.key,
    required this.lesson,
  });

  @override
  ConsumerState<ApplicationPracticeScreen> createState() => _ApplicationPracticeScreenState();
}

class _ApplicationPracticeScreenState extends ConsumerState<ApplicationPracticeScreen> {
  final _recorder = AudioRecorder();
  RecordingState _recordingState = RecordingState.idle;
  String? _audioPath;
  Map<String, dynamic>? _assessmentResult;
  Map<String, dynamic>? _pronunciationResult;
  bool _showHint = false;
  int _currentPracticeIndex = 0;
  List<ApplicationPractice> _practices = [];
  ApplicationPractice? _currentPractice;

  // サービスのプライベート変数を追加
  late AudioPlayerService _audioPlayerService;
  late AudioStorageService _audioStorageService;
  late ProgressService _progressService;
  late OpenAIService _openAIService;
  // AzureSpeechServiceは削除（プロバイダー経由で使用）
  late AchievementService _achievementService;
  
  bool _showExample = false;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  bool _isPlayingAudio = false;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadApplicationPractices();
  }
  
  void _initializeServices() {
    final supabase = Supabase.instance.client;
    
    // OpenAIServiceの初期化
    _openAIService = OpenAIService();
    
    // AudioStorageServiceの初期化
    _audioStorageService = AudioStorageService(
      supabase: supabase,
      openAIService: _openAIService,
    );
    
    // AudioPlayerServiceの初期化
    _audioPlayerService = AudioPlayerService(audioStorage: _audioStorageService);
    
    // その他のサービスの初期化
    _progressService = ProgressService();
    // AzureSpeechServiceはプロバイダー経由で使用
    _achievementService = AchievementService();
  }
  
  Future<void> _loadApplicationPractices() async {
    try {
      // Supabaseから最新のレッスンデータを取得
      final supabase = Supabase.instance.client;
      final response = await supabase
        .from('lessons')
        .select('metadata')
        .eq('id', widget.lesson.id)
        .single();
      
      if (response != null && response['metadata'] != null) {
        final metadata = response['metadata'] as Map<String, dynamic>;
        
        if (metadata['application_practices'] != null) {
          final practicesData = metadata['application_practices'] as List<dynamic>;
          _practices = practicesData.map((data) => ApplicationPractice(
            practiceId: data['practice_id'],
            targetPhrase: data['target_phrase'],
            hint: data['hint'],
            example: data['example'],
            tips: List<String>.from(data['tips'] ?? []),
          )).toList();
        } else {
          // metadataに応用練習データがない場合はデフォルトデータを使用
          _practices = _generatePractices();
        }
      } else {
        // レスポンスがない場合もデフォルトデータを使用
        _practices = _generatePractices();
      }
    } catch (e) {
      print('Error loading application practices: $e');
      // エラーの場合もデフォルトデータを使用
      _practices = _generatePractices();
    }
    
    // 練習問題が設定されたら最初の問題を現在の問題に設定
    if (_practices.isNotEmpty) {
      setState(() {
        _currentPractice = _practices[_currentPracticeIndex];
      });
    }
  }
  
  List<ApplicationPractice> _generatePractices() {
    final keyPhrases = widget.lesson.keyPhrases ?? [];
    final practices = <ApplicationPractice>[];
    
    // キーフレーズから応用練習を生成
    if (keyPhrases.isNotEmpty) {
      // "would you like"を含むフレーズを探す
      final targetPhrase = keyPhrases.firstWhere(
        (kp) => kp.phrase.toLowerCase().contains('would you like'),
        orElse: () => keyPhrases.first,
      );
      
      // 応用練習1: 基本パターン
      practices.add(ApplicationPractice(
        practiceId: 'app_001',
        targetPhrase: 'Would you like to do a ~ as well?',
        hint: 'カットはいかがですか？',
        example: 'Would you like to do a cut as well?',
        tips: ['as wellは「〜も」という意味', '丁寧な提案の表現'],
      ));
      
      // 応用練習2: 別パターン
      practices.add(ApplicationPractice(
        practiceId: 'app_002',
        targetPhrase: 'Would you like to try ~?',
        hint: '新しいヘアスタイルを試してみませんか？',
        example: 'Would you like to try a new hairstyle?',
        tips: ['tryは「試す」という意味', '提案や勧誘の表現'],
      ));
      
      // キーフレーズから動的に生成
      for (final phrase in keyPhrases) {
        if (phrase.phrase != targetPhrase.phrase) {
          practices.add(ApplicationPractice(
            practiceId: 'app_${practices.length + 1}'.padLeft(3, '0'),
            targetPhrase: phrase.phrase,
            hint: '${phrase.phrase}を使って文を作ってください',
            example: phrase.phrase,
            tips: ['自然な表現を心がけましょう'],
          ));
        }
      }
    } else {
      // デフォルトの練習
      practices.add(ApplicationPractice(
        practiceId: 'app_default',
        targetPhrase: 'Hello, how can I help you?',
        hint: 'お客様への挨拶',
        example: 'Hello, how can I help you today?',
        tips: ['丁寧な挨拶を心がけましょう'],
      ));
    }
    
    return practices;
  }
  
  @override
  void dispose() {
    _recorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _startRecording() async {
    setState(() {
      _recordingState = RecordingState.recording;
      _assessmentResult = null;
      _pronunciationResult = null;
    });
    
    try {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _audioPath = '${tempDir.path}/application_practice_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: _audioPath!,
        );
        
        _recordingStartTime = DateTime.now();
        
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
  
  Future<void> _stopRecording() async {
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
    
    _audioPath = await _recorder.stop();
    if (_audioPath == null) {
      setState(() {
        _recordingState = RecordingState.error;
      });
      return;
    }
    
    // 評価処理
    await _performAssessment();
  }
  
  Future<void> _performAssessment() async {
    try {
      final audioFile = File(_audioPath!);
      
      // ファイルサイズ確認
      final fileSize = await audioFile.length();
      print('Audio file size: $fileSize bytes');
      
      if (fileSize < 10000) {
        throw Exception('録音が短すぎるか、音声が入っていない可能性があります。');
      }
      
      // Whisperで音声認識
      final transcription = await _openAIService.transcribeAudio(
        audioFile: audioFile,
        language: 'en',
        prompt: _currentPractice!.targetPhrase, // ヒントとして構文パターンを提供
      );
      
      if (transcription != null && transcription.isNotEmpty) {
        // 文法評価
        final grammarResult = _evaluateGrammar(
          transcription, 
          _currentPractice!.example,
        );
        
        // Azure発音評価（プロバイダー経由）- エラーが発生しても処理を継続
        Map<String, dynamic>? pronunciationData;
        try {
          final azureSpeechService = ref.read(azureSpeechServiceProvider);
          final pronunciationResult = await azureSpeechService.assessPronunciation(
            audioFile: audioFile,
            expectedText: transcription,
            language: 'en-US',
          );
          
          // PronunciationAssessmentResultをMapに変換
          if (pronunciationResult != null) {
            pronunciationData = {
              'recognizedText': pronunciationResult.recognizedText,
              'displayText': pronunciationResult.displayText,
              'overallScore': pronunciationResult.overallScore,
              'accuracyScore': pronunciationResult.accuracyScore,
              'fluencyScore': pronunciationResult.fluencyScore,
              'completenessScore': pronunciationResult.completenessScore,
              'pronunciationScore': pronunciationResult.pronunciationScore,
              'confidence': pronunciationResult.confidence,
              'wordScores': pronunciationResult.wordScores?.map((ws) => {
                'word': ws.word,
                'errorType': ws.errorType,
                'accuracyScore': ws.accuracyScore,
              }).toList(),
            };
          }
        } catch (e) {
          print('発音評価エラー: $e');
          // 発音評価が失敗してもダミーデータを設定して続行
          pronunciationData = {
            'overallScore': 0.0,
            'accuracyScore': 0.0,
            'fluencyScore': 0.0,
            'completenessScore': 0.0,
            'pronunciationScore': 0.0,
            'confidence': 0.0,
            'error': '発音評価を取得できませんでした',
          };
        }
        
        if (mounted) {
          setState(() {
            _assessmentResult = grammarResult;
            _pronunciationResult = pronunciationData;
            _recordingState = RecordingState.success;
          });
          _showFeedbackDialog();
        }
      } else {
        throw Exception('音声認識に失敗しました');
      }
      
      // 録音ファイルを削除
      try {
        await audioFile.delete();
      } catch (_) {}
    } catch (e) {
      print('Error in assessment: $e');
      setState(() {
        _recordingState = RecordingState.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('発音評価に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
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
  
  Map<String, dynamic> _evaluateGrammar(String userInput, String targetPattern) {
    final userWords = userInput.toLowerCase().split(' ');
    final targetWords = targetPattern.toLowerCase().split(' ');
    
    // 基本的な文法スコア計算
    int matchCount = 0;
    final List<String> missingWords = [];
    final List<String> extraWords = [...userWords];
    
    for (final targetWord in targetWords) {
      if (userWords.contains(targetWord)) {
        matchCount++;
        extraWords.remove(targetWord);
      } else {
        missingWords.add(targetWord);
      }
    }
    
    // スコア計算（doubleに変換）
    final grammarScore = ((matchCount / targetWords.length) * 100).toDouble();
    final completenessScore = ((targetWords.length - missingWords.length) / targetWords.length * 100).toDouble();
    
    return {
      'grammarScore': grammarScore,
      'completenessScore': completenessScore,
      'missingWords': missingWords,
      'extraWords': extraWords,
      'recognizedText': userInput,
    };
  }
  
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showFeedbackDialog() {
    if (_assessmentResult == null) return;
    
    final grammarScore = (_assessmentResult!['grammarScore'] as double?) ?? 0.0;
    final completenessScore = (_assessmentResult!['completenessScore'] as double?) ?? 0.0;
    final missingWords = _assessmentResult!['missingWords'] as List<String>? ?? [];
    final extraWords = _assessmentResult!['extraWords'] as List<String>? ?? [];
    final recognizedText = _assessmentResult!['recognizedText'] as String? ?? '';
    
    // 発音評価スコア
    final hasError = _pronunciationResult?['error'] != null;
    final overallPronunciationScore = (_pronunciationResult?['overallScore'] as num?)?.toDouble() ?? 0.0;
    final accuracyScore = (_pronunciationResult?['accuracyScore'] as num?)?.toDouble() ?? 0.0;
    final fluencyScore = (_pronunciationResult?['fluencyScore'] as num?)?.toDouble() ?? 0.0;
    
    // 総合スコアを計算
    final totalScore = (grammarScore + completenessScore + overallPronunciationScore) / 3;
    
    // スコアに基づく色を決定
    final scoreColor = totalScore >= 80
        ? Colors.green
        : totalScore >= 60
            ? Colors.orange
            : Colors.red;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: scoreColor.withOpacity(0.3), width: 2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                totalScore >= 80 ? Icons.star : Icons.check_circle,
                color: scoreColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '総合スコア: ${totalScore.toStringAsFixed(0)}点',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // エラーメッセージまたはスコアバー
              if (hasError) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '発音評価サービスが一時的に利用できません。文法評価のみ表示しています。',
                          style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // スコアバー
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreRow('文法', grammarScore, scoreColor),
                    _buildScoreRow('完全性', completenessScore, scoreColor),
                    if (!hasError) ...[
                      _buildScoreRow('発音', overallPronunciationScore, scoreColor),
                      _buildScoreRow('正確さ', accuracyScore, scoreColor),
                      _buildScoreRow('流暢さ', fluencyScore, scoreColor),
                    ],
                  ],
                ),
              ),
              
              // 認識されたテキスト
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '認識されたテキスト:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recognizedText,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 単語ごとの評価（発音スコアがある場合）
              if (_pronunciationResult != null && _pronunciationResult!['wordScores'] != null && _pronunciationResult!['wordScores']!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '単語ごとの発音評価',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _pronunciationResult!['wordScores']!.map((wordScore) {
                          final score = wordScore['accuracyScore'];
                          Color scoreColor;
                          if (score >= 80) {
                            scoreColor = Colors.green;
                          } else if (score >= 60) {
                            scoreColor = Colors.orange;
                          } else {
                            scoreColor = Colors.red;
                          }
                          
                          return Container(
                            margin: const EdgeInsets.only(right: 8, bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: scoreColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: scoreColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  wordScore['word'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: scoreColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: scoreColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${score.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: scoreColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
              
              // フィードバック
              if (missingWords.isNotEmpty || extraWords.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (missingWords.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '不足している単語:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          missingWords.join(', '),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                      
                      if (missingWords.isNotEmpty && extraWords.isNotEmpty) 
                        const SizedBox(height: 8),
                      
                      if (extraWords.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '余分な単語:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          extraWords.join(', '),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // アドバイステキスト
              Text(
                grammarScore >= 80
                    ? '構文パターンを正しく使えています！自然な英語表現ができました。'
                    : grammarScore >= 60
                        ? 'もう少しで完璧です！構文パターンを意識して練習を続けましょう。'
                        : '構文パターンを使って文章を作る練習を続けましょう。ヒントを参考にしてください。',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextPractice();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text(
              _currentPracticeIndex < _practices.length - 1 ? '次へ' : '完了',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreRow(String label, double score, Color baseColor) {
    // MaterialColorに変換するか、固定の色を使用
    final MaterialColor materialColor = 
        baseColor == Colors.green ? Colors.green :
        baseColor == Colors.orange ? Colors.orange :
        Colors.red;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: score / 100,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          materialColor.shade400,
                          materialColor.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${score.toInt()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: materialColor.shade900,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
  void _nextPractice() {
    if (_currentPracticeIndex < _practices.length - 1) {
      setState(() {
        _currentPracticeIndex++;
        _assessmentResult = null;
        _pronunciationResult = null;
        _showHint = false;
      });
    } else {
      // 練習完了
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_currentPractice == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('応用練習 ${_currentPracticeIndex + 1}/${_practices.length}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 進捗インジケーター
              LinearProgressIndicator(
                value: (_currentPracticeIndex + 1) / _practices.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                minHeight: 6,
              ),
              const SizedBox(height: 24),
              
              // 構文パターン
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.purple.shade200,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'このフレーズを使いましょう',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentPractice!.targetPhrase,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ヒント表示
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    Text(
                      _currentPractice!.hint,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_showExample) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentPractice!.example,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextButton.icon(
                      icon: Icon(
                        _showExample ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                      ),
                      label: Text(_showExample ? '答えを隠す' : '答えのヒントを見る'),
                      onPressed: () {
                        setState(() {
                          _showExample = !_showExample;
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              // キャラクターアバター
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedAvatar(
                        isPlaying: _recordingState == RecordingState.recording,
                        size: 150,
                        fallbackAvatarPath: CharacterService.getAvatarImagePath(widget.lesson.characterId),
                      ),
                      if (_currentPractice!.tips.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ...(_currentPractice!.tips.map((tip) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '💡 $tip',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ))),
                      ],
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // 録音ボタン
              Column(
                children: [
                  // マイクボタン
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
                        onTapDown: (_) {
                          if (_recordingState == RecordingState.idle) {
                            _startRecording();
                          }
                        },
                        onTapUp: (_) {
                          if (_recordingState == RecordingState.recording) {
                            _stopRecording();
                          }
                        },
                        onTapCancel: () async {
                          if (_recordingState == RecordingState.recording) {
                            await _recorder.stop();
                            _recordingTimer?.cancel();
                            _recordingTimer = null;
                            setState(() {
                              _recordingState = RecordingState.idle;
                              _recordingStartTime = null;
                            });
                          }
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
                  
                  // ステータステキスト
                  Text(
                    _getRecordingStatusText(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _recordingState == RecordingState.error 
                          ? Colors.red.shade700 
                          : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRecordingButtonColor() {
    switch (_recordingState) {
      case RecordingState.idle:
        return Colors.blue.shade600;
      case RecordingState.recording:
        return Colors.red;
      case RecordingState.processing:
        return Colors.orange;
      case RecordingState.success:
        return Colors.green;
      case RecordingState.error:
        return Colors.red.shade700;
    }
  }
  
  String _getRecordingStatusText() {
    switch (_recordingState) {
      case RecordingState.idle:
        return 'マイクを長押しして話してください';
      case RecordingState.recording:
        final duration = _recordingStartTime != null 
            ? DateTime.now().difference(_recordingStartTime!).inSeconds 
            : 0;
        return '録音中... ${duration}秒';
      case RecordingState.processing:
        return '評価中...';
      case RecordingState.success:
        return '成功！';
      case RecordingState.error:
        return 'エラー';
    }
  }
} 