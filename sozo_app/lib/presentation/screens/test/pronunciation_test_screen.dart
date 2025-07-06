import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../services/azure_speech_service.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import '../../../services/openai_service.dart';
import '../../../data/models/lesson_model.dart';
import '../../../services/audio_player_service.dart';
import '../../../services/progress_service.dart';
import '../../widgets/xp_animation.dart';
import '../../widgets/achievement_notification.dart';
import '../../widgets/level_up_notification.dart';

// 発音テストの状態管理
final pronunciationTestProvider = StateNotifierProvider<PronunciationTestNotifier, PronunciationTestState>((ref) {
  return PronunciationTestNotifier();
});

class PronunciationTestState {
  final int currentIndex;
  final Map<String, PronunciationResult> results;
  final bool isRecording;
  final bool isProcessing;
  
  PronunciationTestState({
    this.currentIndex = 0,
    this.results = const {},
    this.isRecording = false,
    this.isProcessing = false,
  });
  
  PronunciationTestState copyWith({
    int? currentIndex,
    Map<String, PronunciationResult>? results,
    bool? isRecording,
    bool? isProcessing,
  }) {
    return PronunciationTestState(
      currentIndex: currentIndex ?? this.currentIndex,
      results: results ?? this.results,
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class PronunciationResult {
  final String text;
  final double accuracyScore;
  final double fluencyScore;
  final double completenessScore;
  final double pronunciationScore;
  final List<WordDetail> wordDetails;
  
  PronunciationResult({
    required this.text,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.pronunciationScore,
    required this.wordDetails,
  });
  
  double get overallScore => (accuracyScore + fluencyScore + completenessScore + pronunciationScore) / 4;
}

class WordDetail {
  final String word;
  final double score;
  final String? errorType;
  
  WordDetail({
    required this.word,
    required this.score,
    this.errorType,
  });
}

class PronunciationTestNotifier extends StateNotifier<PronunciationTestState> {
  PronunciationTestNotifier() : super(PronunciationTestState());
  
  void nextWord() {
    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }
  
  void previousWord() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }
  
  void setRecording(bool isRecording) {
    state = state.copyWith(isRecording: isRecording);
  }
  
  void setProcessing(bool isProcessing) {
    state = state.copyWith(isProcessing: isProcessing);
  }
  
  void addResult(String text, PronunciationResult result) {
    final newResults = Map<String, PronunciationResult>.from(state.results);
    newResults[text] = result;
    state = state.copyWith(results: newResults);
  }
}

class PronunciationTestScreen extends ConsumerStatefulWidget {
  final LessonModel? lesson;
  
  const PronunciationTestScreen({
    super.key,
    this.lesson,
  });

  @override
  ConsumerState<PronunciationTestScreen> createState() => _PronunciationTestScreenState();
}

class _PronunciationTestScreenState extends ConsumerState<PronunciationTestScreen> {
  late AudioRecorder _audioRecorder;
  late AudioPlayer _audioPlayer;
  late OpenAIService _openAIService;
  
  List<String> testItems = [];
  DateTime? _startTime;
  int _elapsedSeconds = 0;
  
  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _openAIService = OpenAIService();
    _startTime = DateTime.now();
    
    // テスト項目を準備
    _prepareTestItems();
    
    // レッスンがある場合は開始を記録
    if (widget.lesson != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(progressServiceProvider).startLesson(widget.lesson!.id);
      });
    }
  }
  
  void _prepareTestItems() {
    if (widget.lesson?.pronunciationFocus != null) {
      // レッスンの発音フォーカスから
      final focus = widget.lesson!.pronunciationFocus!;
      testItems = [
        ...focus.words,
        ...focus.sentences,
      ];
    } else if (widget.lesson?.keyPhrases.isNotEmpty ?? false) {
      // キーフレーズから
      testItems = widget.lesson!.keyPhrases.map((p) => p.phrase).toList();
    } else {
      // デフォルトの発音練習
      testItems = [
        'Hello, nice to meet you.',
        'How are you today?',
        'Thank you very much.',
        'I would like to practice English.',
        'Could you help me with this?',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(pronunciationTestProvider);
    
    if (testState.currentIndex >= testItems.length) {
      return _buildResultsScreen(testState);
    }
    
    final currentItem = testItems[testState.currentIndex];
    final result = testState.results[currentItem];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson?.title ?? '発音テスト'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: (testState.currentIndex + 1) / testItems.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 進捗表示
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${testState.currentIndex + 1} / ${testItems.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // テスト項目表示
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ヒント（レッスンがある場合）
                    if (widget.lesson?.pronunciationFocus?.tips != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: widget.lesson!.pronunciationFocus!.tips!.entries
                              .where((e) => currentItem.contains(e.key))
                              .map((e) => Text(
                                    '${e.key}: ${e.value}',
                                    style: const TextStyle(fontSize: 14),
                                  ))
                              .toList(),
                        ),
                      ),
                    
                    // テキスト表示
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Text(
                              currentItem,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            // お手本を聞くボタン
                            OutlinedButton.icon(
                              onPressed: () => _playExample(currentItem),
                              icon: const Icon(Icons.volume_up),
                              label: const Text('お手本を聞く'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 結果表示
                    if (result != null) ...[
                      const SizedBox(height: 24),
                      _buildResultCard(result),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // 録音ボタン
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 録音ボタン
                GestureDetector(
                  onTapDown: (_) => _startRecording(),
                  onTapUp: (_) => _stopRecording(),
                  onTapCancel: () => _cancelRecording(),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: testState.isRecording ? Colors.red : Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: (testState.isRecording ? Colors.red : Theme.of(context).primaryColor)
                              .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        testState.isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  testState.isRecording
                      ? '録音中... 離すと停止します'
                      : testState.isProcessing
                          ? '評価中...'
                          : 'ボタンを押し続けて録音',
                  style: TextStyle(
                    fontSize: 16,
                    color: testState.isRecording ? Colors.red : Colors.grey[600],
                  ),
                ),
                
                // ナビゲーションボタン
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: testState.currentIndex > 0
                          ? () => ref.read(pronunciationTestProvider.notifier).previousWord()
                          : null,
                      child: const Text('前へ'),
                    ),
                    ElevatedButton(
                      onPressed: result != null
                          ? () => ref.read(pronunciationTestProvider.notifier).nextWord()
                          : null,
                      child: Text(
                        testState.currentIndex < testItems.length - 1 ? '次へ' : '結果を見る',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultCard(PronunciationResult result) {
    final score = result.overallScore;
    final color = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.orange
            : Colors.red;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 総合スコア
            CircularProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${score.toStringAsFixed(0)}点',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            
            // 詳細スコア
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreItem('正確さ', result.accuracyScore),
                _buildScoreItem('流暢さ', result.fluencyScore),
                _buildScoreItem('完全性', result.completenessScore),
              ],
            ),
            
            // 単語ごとの結果
            if (result.wordDetails.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                '単語ごとの評価:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildWordScoreDisplay(result.wordDetails),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildWordScoreDisplay(List<WordDetail> wordDetails) {
    // 重複する単語を除去
    final uniqueWords = <String, WordDetail>{};
    for (final word in wordDetails) {
      if (!uniqueWords.containsKey(word.word.toLowerCase())) {
        uniqueWords[word.word.toLowerCase()] = word;
      }
    }
    final filteredWords = uniqueWords.values.toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 8,
        children: filteredWords.map((word) {
          return RichText(
            text: TextSpan(
              text: word.word,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getWordColor(word.score),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Color _getWordColor(double score) {
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
  
  Widget _buildScoreItem(String label, double score) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${score.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildResultsScreen(PronunciationTestState testState) {
    final totalScore = testState.results.values.isEmpty
        ? 0.0
        : testState.results.values.map((r) => r.overallScore).reduce((a, b) => a + b) /
            testState.results.length;
    
    // 経過時間を計算
    if (_startTime != null) {
      _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('テスト結果'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 総合結果
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      '総合スコア',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: totalScore / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              totalScore >= 80
                                  ? Colors.green
                                  : totalScore >= 60
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                            strokeWidth: 12,
                          ),
                        ),
                        Text(
                          '${totalScore.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getScoreMessage(totalScore),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 項目ごとの結果
            ...testItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final result = testState.results[item];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: result != null
                        ? (result.overallScore >= 80
                            ? Colors.green
                            : result.overallScore >= 60
                                ? Colors.orange
                                : Colors.red)
                        : Colors.grey,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(item),
                  subtitle: result != null
                      ? Text('スコア: ${result.overallScore.toStringAsFixed(0)}点')
                      : const Text('未実施'),
                  trailing: result != null
                      ? Icon(
                          result.overallScore >= 80
                              ? Icons.check_circle
                              : result.overallScore >= 60
                                  ? Icons.warning
                                  : Icons.error,
                          color: result.overallScore >= 80
                              ? Colors.green
                              : result.overallScore >= 60
                                  ? Colors.orange
                                  : Colors.red,
                        )
                      : null,
                ),
              );
            }).toList(),
            
            const SizedBox(height: 24),
            
            // アクションボタン
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // テストをリセット
                      ref.invalidate(pronunciationTestProvider);
                      setState(() {
                        _startTime = DateTime.now();
                      });
                    },
                    child: const Text('もう一度'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // レッスンがある場合は進捗を記録
                      if (widget.lesson != null && totalScore > 0) {
                        await _completeTest(totalScore);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('終了'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _getScoreMessage(double score) {
    if (score >= 90) {
      return '素晴らしい！ネイティブレベルの発音です！';
    } else if (score >= 80) {
      return 'とても良い発音です！もう少しで完璧です。';
    } else if (score >= 70) {
      return '良い発音です。練習を続けましょう！';
    } else if (score >= 60) {
      return 'まずまずです。もう少し練習が必要です。';
    } else {
      return '頑張りましょう！練習あるのみです。';
    }
  }
  
  Future<void> _playExample(String text) async {
    try {
      final audioPlayer = ref.read(audioPlayerServiceProvider);
      
      // レッスンがある場合は、キーフレーズの音声URLを探す
      String? audioUrl;
      if (widget.lesson != null) {
        final keyPhrase = widget.lesson!.keyPhrases
            .firstWhere((p) => p.phrase == text, orElse: () => const KeyPhrase(
              phrase: '',
              meaning: '',
            ));
        audioUrl = keyPhrase.audioUrl;
      }
      
      await audioPlayer.playKeyPhrase(
        phrase: text,
        lessonId: widget.lesson?.id ?? 'default',
        audioUrl: audioUrl,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音声を再生中...'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('音声再生エラー: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/temp_recording.wav';
      
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );
      ref.read(pronunciationTestProvider.notifier).setRecording(true);
    }
  }
  
  Future<void> _stopRecording() async {
    if (!ref.read(pronunciationTestProvider).isRecording) return;
    
    try {
      ref.read(pronunciationTestProvider.notifier).setRecording(false);
      ref.read(pronunciationTestProvider.notifier).setProcessing(true);
      
      final path = await _audioRecorder.stop();
      if (path == null) {
        throw Exception('録音ファイルが見つかりません');
      }
      
      // 発音評価
      final currentItem = testItems[ref.read(pronunciationTestProvider).currentIndex];
      final speechService = ref.read(azureSpeechServiceProvider);
      final result = await speechService.assessPronunciation(
        audioFile: File(path),
        expectedText: currentItem,
      );
      
      if (result == null) {
        throw Exception('発音評価に失敗しました');
      }
      
      // 結果を保存
      ref.read(pronunciationTestProvider.notifier).addResult(
        currentItem,
        PronunciationResult(
          text: currentItem,
          accuracyScore: result.accuracyScore,
          fluencyScore: result.fluencyScore,
          completenessScore: result.completenessScore,
          pronunciationScore: result.pronunciationScore,
          wordDetails: result.wordScores?.map((w) => WordDetail(
            word: w.word,
            score: w.accuracyScore,
            errorType: w.errorType,
          )).toList() ?? [],
        ),
      );
      
      // ファイルを削除
      try {
        await File(path).delete();
      } catch (_) {}
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('評価エラー: $e')),
      );
    } finally {
      ref.read(pronunciationTestProvider.notifier).setProcessing(false);
    }
  }
  
  void _cancelRecording() {
    if (ref.read(pronunciationTestProvider).isRecording) {
      _audioRecorder.stop();
      ref.read(pronunciationTestProvider.notifier).setRecording(false);
    }
  }
  
  Future<void> _completeTest(double totalScore) async {
    final progressService = ref.read(progressServiceProvider);
    final (xpEarned, levelUpInfo) = await progressService.completeActivity(
      lessonId: widget.lesson!.id,
      activityType: 'pronunciation_test',
      score: totalScore,
      timeSpent: _elapsedSeconds,
    );
    
    // 実績チェック
    final newAchievements = await progressService.checkAchievements();
    
    if (!mounted) return;
    
    // XPアニメーションを表示
    if (xpEarned > 0) {
      XPAnimationOverlay.show(context, xpEarned);
    }
    
    // レベルアップ通知を表示（XPアニメーションの後）
    if (levelUpInfo.hasLeveledUp) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          LevelUpNotificationOverlay.show(
            context,
            oldLevel: levelUpInfo.oldLevel,
            newLevel: levelUpInfo.newLevel,
            totalXP: levelUpInfo.totalXP,
          );
        }
      });
    }
    
    // 実績通知を表示（レベルアップ通知の後、またはXPアニメーションの後）
    if (newAchievements.isNotEmpty) {
      final delay = levelUpInfo.hasLeveledUp ? 6000 : 1000;
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          AchievementNotificationOverlay.showMultiple(context, newAchievements);
        }
      });
    }
    
    // 完了ダイアログを表示
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('発音テスト完了！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (xpEarned > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber[600],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+$xpEarned XP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              '総合スコア: ${totalScore.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'テスト時間: ${(_elapsedSeconds / 60).toStringAsFixed(1)}分',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreMessage(totalScore),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
  
  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
} 