import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/services/ai_conversation_service.dart';
import 'package:sozo_app/services/azure_speech_service.dart';
import 'package:sozo_app/services/audio_player_service.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AiConversationStep extends ConsumerStatefulWidget {
  const AiConversationStep({super.key});

  @override
  ConsumerState<AiConversationStep> createState() => _AiConversationStepState();
}

class _AiConversationStepState extends ConsumerState<AiConversationStep> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  final List<Map<String, dynamic>> _messages = [];
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _hasStarted = false;
  
  @override
  void initState() {
    super.initState();
    // 初期メッセージを追加
    _messages.add({
      'role': 'assistant',
      'content': "Hi! I'm your AI buddy. Let's have a short conversation. Tell me, what's your favorite color?",
      'timestamp': DateTime.now(),
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _hasStarted = true;
    });

    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/tutorial_conversation_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 128000,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: path,
        );
      } else {
        setState(() => _isRecording = false);
        _showError('マイクへのアクセス許可が必要です');
      }
    } catch (e) {
      print('Error starting recording: $e');
      setState(() => _isRecording = false);
      _showError('録音開始に失敗しました');
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    try {
      final audioPath = await _audioRecorder.stop();
      if (audioPath == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final audioFile = File(audioPath);
      
      // 音声をテキストに変換
      final speechService = ref.read(azureSpeechServiceProvider);
      final transcription = await speechService.recognizeSpeech(
        audioFile: audioFile,
      );
      
      if (transcription != null && transcription.isNotEmpty) {
        // ユーザーメッセージを追加
        setState(() {
          _messages.add({
            'role': 'user',
            'content': transcription,
            'timestamp': DateTime.now(),
          });
        });

        // AIとの会話を処理
        final conversationService = AIConversationService();
        final response = await conversationService.generateResponse(
          conversationHistory: _messages.map((msg) => {
            'role': (msg['role'] ?? '').toString(),
            'content': (msg['content'] ?? '').toString(),
          }).toList(),
          targetPhrases: ['How are you?', 'Nice to meet you'],
          lessonContext: 'Tutorial conversation practice',
          sessionNumber: 1,
          userLevel: 'Beginner',
        );
        
        _addAiMessage(response);
      }
      
      // 録音ファイルを削除
      try {
        await audioFile.delete();
      } catch (_) {}
    } catch (e) {
      print('Error in conversation: $e');
      _showError('エラーが発生しました');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addAiMessage(String message) {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': message,
        'timestamp': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.chat,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'AI会話を体験',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'AIと簡単な会話をしてみましょう',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          // 会話履歴
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: _messages.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser = message['role'] == 'user';
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isUser) ...[
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: const Icon(
                                    Icons.smart_toy,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Theme.of(context).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    message['content'],
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                              if (isUser) ...[
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 録音ボタン
          GestureDetector(
            onTap: _isProcessing
                ? null
                : _isRecording
                    ? _stopRecording
                    : _startRecording,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : Theme.of(context).colorScheme.primary)
                        .withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: _isProcessing
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                    : Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 32,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isRecording
                ? '話し終わったらタップ'
                : _isProcessing
                    ? '処理中...'
                    : 'タップして話す',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          
          // ヒント
          if (!_hasStarted)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '好きな色を英語で答えてみましょう\n例: "My favorite color is blue"',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
} 