import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sozo_app/data/models/lesson_model.dart' as lesson_model;
import 'package:sozo_app/services/audio_player_service.dart';
import 'package:sozo_app/services/audio_storage_service.dart';
import 'package:sozo_app/services/azure_speech_service.dart';
import 'package:sozo_app/services/ai_conversation_service.dart';
import 'package:sozo_app/services/openai_service.dart';
import 'package:sozo_app/services/progress_service.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'dart:io';

class AIConversationPracticeScreen extends ConsumerStatefulWidget {
  final lesson_model.LessonModel lesson;

  const AIConversationPracticeScreen({
    super.key,
    required this.lesson,
  });

  @override
  ConsumerState<AIConversationPracticeScreen> createState() =>
      _AIConversationPracticeScreenState();
}

class _AIConversationPracticeScreenState
    extends ConsumerState<AIConversationPracticeScreen> {
  final _audioRecorder = AudioRecorder();
  late final AudioPlayerService _audioPlayer;
  final _speechService = AzureSpeechService();
  final _openAIService = OpenAIService();
  final _aiService = AIConversationService();

  int _currentSession = 1;
  final int _totalSessions = 5;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isAISpeaking = false;
  
  List<Map<String, String>> _conversationHistory = [];
  final List<double> _sessionScores = [];
  
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    // セッション開始時のAIメッセージを追加
    final startMessage = _aiService.getSessionStartMessage(_currentSession);
    setState(() {
      _conversationHistory = [
        {'role': 'assistant', 'content': startMessage}
      ];
    });
    
    // AIの音声を再生
    _speakAIMessage(startMessage);
  }

  Future<void> _speakAIMessage(String message) async {
    setState(() {
      _isAISpeaking = true;
    });
    
    try {
      // OpenAI APIを使用してTTS（未実装の場合はスキップ）
      // TODO: OpenAI TTSまたはAzure TTSを実装
      print('TTS not implemented yet for message: $message');
    } catch (e) {
      print('Error playing AI speech: $e');
    } finally {
      setState(() {
        _isAISpeaking = false;
      });
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('マイクの権限が必要です')),
      );
      return;
    }

    try {
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: 'conversation_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      // 録音時間カウンター
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
        });
      });
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('録音を開始できませんでした')),
      );
    }
  }

  Future<void> _stopRecordingAndProcess() async {
    if (!_isRecording) return;

    _recordingTimer?.cancel();
    final path = await _audioRecorder.stop();
    
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    if (path == null) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      // 音声認識
      final transcription = await _speechService.recognizeSpeech(
        audioFile: File(path),
      ) ?? '';
      
      // ユーザーメッセージを追加
      setState(() {
        _conversationHistory.add({
          'role': 'user',
          'content': transcription,
        });
      });

      // 発音評価
      final targetPhrases = widget.lesson.keyPhrases.map((p) => p.phrase).toList();
      final pronunciationScore = await _evaluateUserPronunciation(
        audioPath: path,
        transcript: transcription,
        targetPhrases: targetPhrases,
      );

      // AI応答を生成
      final aiResponse = await _aiService.generateResponse(
        conversationHistory: _conversationHistory,
        targetPhrases: targetPhrases,
        lessonContext: widget.lesson.description,
        sessionNumber: _currentSession,
        userLevel: 'intermediate',
      );

      // AI応答を追加
      setState(() {
        _conversationHistory.add({
          'role': 'assistant',
          'content': aiResponse,
        });
      });

      // AIの音声を再生
      await _speakAIMessage(aiResponse);
      
    } catch (e) {
      print('Error processing conversation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('処理中にエラーが発生しました')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<double> _evaluateUserPronunciation({
    required String audioPath,
    required String transcript,
    required List<String> targetPhrases,
  }) async {
    // ターゲットフレーズが含まれているかチェック
    for (final phrase in targetPhrases) {
      if (transcript.toLowerCase().contains(phrase.toLowerCase())) {
        // その部分の発音を評価
        final result = await _speechService.assessPronunciation(
          audioFile: File(audioPath),
          expectedText: phrase,
        );
        
        if (result != null) {
          return result.overallScore;
        }
      }
    }
    
    // フレーズが見つからない場合は全体を評価
    final result = await _speechService.assessPronunciation(
      audioFile: File(audioPath),
      expectedText: transcript,
    );
    
    return result?.overallScore ?? 70.0;
  }

  Future<void> _completeSession() async {
    // セッションの評価
    final targetPhrases = widget.lesson.keyPhrases.map((p) => p.phrase).toList();
    final feedback = await _aiService.evaluateConversation(
      conversationHistory: _conversationHistory,
      targetPhrases: targetPhrases,
      sessionNumber: _currentSession,
    );

    // スコアを記録
    _sessionScores.add(feedback.overallScore);

    // フィードバックダイアログを表示
    if (!mounted) return;
    
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('セッション $_currentSession 完了！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: feedback.overallScore / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                feedback.overallScore >= 80 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'スコア: ${feedback.overallScore.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('使用フレーズ: ${feedback.phrasesUsed}/${feedback.totalPhrases}'),
            const SizedBox(height: 16),
            Text(feedback.feedback),
            const SizedBox(height: 16),
            if (feedback.suggestions.isNotEmpty) ...[
              const Text('改善ポイント:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...feedback.suggestions.map((s) => Text('• $s')),
            ],
          ],
        ),
        actions: [
          if (_currentSession < _totalSessions)
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('次のセッション'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_currentSession < _totalSessions ? '終了' : '完了'),
          ),
        ],
      ),
    );

    if (shouldContinue == true && _currentSession < _totalSessions) {
      // 次のセッションへ
      setState(() {
        _currentSession++;
        _conversationHistory.clear();
      });
      _initializeSession();
    } else {
      // 全セッション完了または中断
      _completeAllSessions();
    }
  }

  void _completeAllSessions() async {
    // 進捗を記録
    final progressService = ref.read(progressServiceProvider);
    final avgScore = _sessionScores.isEmpty 
        ? 0.0 
        : _sessionScores.reduce((a, b) => a + b) / _sessionScores.length;
    
    await progressService.completeActivity(
      lessonId: widget.lesson.id,
      activityType: 'ai_conversation',
      score: avgScore,
      timeSpent: _currentSession * 180, // 各セッション約3分として計算
    );

    if (!mounted) return;
    
    // 完了画面へ遷移
    context.go('/lesson/${widget.lesson.id}/complete', extra: {
      'score': avgScore,
      'sessionCount': _sessionScores.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI会話練習'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'セッション $_currentSession/$_totalSessions',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // プログレスバー
          LinearProgressIndicator(
            value: (_currentSession - 1) / _totalSessions,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          
          // キーフレーズリマインダー
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日のキーフレーズ:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.lesson.keyPhrases.map((phrase) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• ${phrase.phrase}'),
                )),
              ],
            ),
          ),
          
          // 会話履歴
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _conversationHistory.length,
              itemBuilder: (context, index) {
                final reversedIndex = _conversationHistory.length - 1 - index;
                final message = _conversationHistory[reversedIndex];
                final isUser = message['role'] == 'user';
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUser ? 'You' : 'AI',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(message['content'] ?? ''),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 録音コントロール
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_isRecording)
                  Text(
                    '録音中... ${_recordingSeconds}秒',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (_isProcessing)
                  const Text('処理中...'),
                if (_isAISpeaking)
                  const Text('AI応答中...'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 録音ボタン
                    ElevatedButton.icon(
                      onPressed: (_isProcessing || _isAISpeaking)
                          ? null
                          : (_isRecording
                              ? _stopRecordingAndProcess
                              : _startRecording),
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                      label: Text(_isRecording ? '停止' : '話す'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                    
                    // セッション完了ボタン
                    ElevatedButton.icon(
                      onPressed: _conversationHistory.length > 3
                          ? _completeSession
                          : null,
                      icon: const Icon(Icons.check),
                      label: const Text('セッション完了'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
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



  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }
} 