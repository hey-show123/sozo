import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import '../../../services/openai_service.dart';
import '../../../services/azure_speech_service.dart';
import '../../../services/progress_service.dart';
import '../../../data/models/lesson_model.dart';
import '../../widgets/xp_animation.dart';
import '../../widgets/achievement_notification.dart';
import '../../widgets/level_up_notification.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// AIパートナー選択状態
final selectedAIPartnerProvider = StateProvider<AIPersonality>((ref) {
  return AIPersonality(
    id: 'maya',
    displayName: 'Maya',
    description: 'フレンドリーで励まし上手なアメリカ人女性',
    personalityTraits: {
      'friendliness': 9,
      'patience': 8,
      'humor': 7,
      'formality': 5,
      'encouragement': 10,
    },
    conversationStyle: {
      'question_frequency': 7,
      'topic_diversity': 8,
      'correction_approach': 'gentle',
      'complexity_adaptation': true,
    },
    voiceId: 'nova',
  );
});

// 会話履歴を管理
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }
}

class AiBuddyScreen extends ConsumerStatefulWidget {
  final LessonModel? lesson;
  final String? lessonId;
  
  const AiBuddyScreen({
    super.key,
    this.lesson,
    this.lessonId,
  });

  @override
  ConsumerState<AiBuddyScreen> createState() => _AiBuddyScreenState();
}

class _AiBuddyScreenState extends ConsumerState<AiBuddyScreen> {
  final ScrollController _scrollController = ScrollController();
  late OpenAIService _openAIService;
  late AzureSpeechService _speechService;
  late AudioPlayer _audioPlayer;
  late AudioRecorder _audioRecorder;
  
  bool _isTyping = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _showKeyPhrases = false;
  bool _isLoading = false;
  bool _isSimulator = false;
  
  DateTime? _sessionStartTime;
  int _messageCount = 0;
  int _userSpeakingTime = 0; // 秒数
  final List<double> _pronunciationScores = [];
  
  LessonModel? _currentLesson;

  @override
  void initState() {
    super.initState();
    _openAIService = OpenAIService();
    _speechService = AzureSpeechService();
    _audioPlayer = AudioPlayer();
    _audioRecorder = AudioRecorder();
    _sessionStartTime = DateTime.now();
    
    _currentLesson = widget.lesson;
    
    // シミュレーター検出
    _checkIfSimulator();
    
    // lessonIdが渡された場合はレッスンデータを読み込む
    if (widget.lessonId != null && widget.lesson == null) {
      _loadLessonData();
    } else {
      _initializeSession();
    }
  }
  
  Future<void> _checkIfSimulator() async {
    if (Platform.isIOS) {
      // iOSシミュレーターの検出 - 環境変数を使用
      try {
        // シミュレーターでは特定の環境変数が設定されている
        final environment = Platform.environment;
        _isSimulator = environment.containsKey('SIMULATOR_DEVICE_NAME') ||
                      environment['SIMULATOR_RUNTIME'] != null;
        
        if (_isSimulator && mounted) {
          // シミュレーターで実行中の警告を表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'シミュレーターでは音声録音が制限されています。\n実機でのテストをお勧めします。',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
          });
        }
      } catch (e) {
        print('Simulator detection error: $e');
        _isSimulator = false;
      }
    }
  }

  Future<void> _loadLessonData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('lessons')
          .select()
          .eq('id', widget.lessonId!)
          .single();
      
      final lessonData = response as Map<String, dynamic>;
      _currentLesson = LessonModel.fromJson(lessonData);
      
      _initializeSession();
    } catch (e) {
      print('Error loading lesson data: $e');
      // エラーの場合はフリートークモードで開始
      _initializeSession();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeSession() {
    // レッスンがある場合は開始を記録
    if (_currentLesson != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(progressServiceProvider).startLesson(_currentLesson!.id);
      });
    }
    
    // 初期メッセージを追加（メッセージリストが空の場合のみ）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messages = ref.read(chatMessagesProvider);
      if (messages.isEmpty) {
        _addInitialMessage();
      }
    });
  }

  void _addInitialMessage() {
    // 美容院のお客様として来店
    String initialMessage = "Hello! I'd like to get a haircut today. Do you have time for a walk-in?";
    
    // ランダムで異なる来店パターンを選択
    final random = DateTime.now().millisecondsSinceEpoch % 5;
    switch (random) {
      case 0:
        initialMessage = "Hi! I have an appointment at 3 o'clock under the name Johnson.";
        break;
      case 1:
        initialMessage = "Good afternoon! I'm looking for a new hair color. Can you help me?";
        break;
      case 2:
        initialMessage = "Hello! This is my first time here. I'd like to get a trim and maybe some styling advice.";
        break;
      case 3:
        initialMessage = "Hi there! I need to fix my hair color. It didn't turn out well at another salon...";
        break;
      case 4:
        initialMessage = "Hello! I'd like to get a haircut today. Do you have time for a walk-in?";
        break;
    }
    
    ref.read(chatMessagesProvider.notifier).addMessage(
      ChatMessage(
        text: initialMessage,
        isUser: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Buddy'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final messages = ref.watch(chatMessagesProvider);

    return WillPopScope(
      onWillPop: () async {
        // 戻る前にセッションを終了
        if (_currentLesson != null && _messageCount > 0) {
          await _endConversationSession();
          return false; // ダイアログで制御
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('接客中'),
              Text(
                'お客様対応',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_currentLesson != null && _messageCount > 0) {
                await _endConversationSession();
              } else {
                if (context.canPop()) {
                  context.pop();
                } else {
                  // ルートスタックが空の場合はホームへ
                  context.go('/');
                }
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startNewConversation,
              tooltip: '会話をリセット',
            ),
          ],
        ),
        body: Column(
          children: [
            // 店舗情報バー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.pink.shade50,
              child: Row(
                children: [
                  Icon(Icons.storefront, size: 18, color: Colors.pink.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Beauty Salon SOZO - 接客中',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.pink.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // メッセージリスト
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(messages[index]);
                },
              ),
            ),
            
            _buildInputArea(),
          ],
        ),
      ),
    );
  }



  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: isUser ? 64 : 0,
          right: isUser ? 0 : 64,
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20),
                      color: Colors.grey[600],
                      onPressed: () => _playMessageAudio(message.text),
                    ),
                    if (message.corrections != null && message.corrections!.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('訂正'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                        onPressed: () => _showCorrections(message.corrections!),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 64),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (mounted && _isTyping) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 録音中のインジケーター
          if (_isRecording)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '録音中...',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          // 大きなマイクボタン
          GestureDetector(
            onTap: _isProcessing ? null : _toggleRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isRecording ? 100 : 80,
              height: _isRecording ? 100 : 80,
              decoration: BoxDecoration(
                color: _isRecording 
                    ? Colors.red 
                    : (_isProcessing ? Colors.grey : Theme.of(context).primaryColor),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : Theme.of(context).primaryColor)
                        .withOpacity(0.3),
                    blurRadius: _isRecording ? 20 : 12,
                    spreadRadius: _isRecording ? 4 : 2,
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: _isRecording ? 48 : 40,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 状態テキスト
          Text(
            _isProcessing
                ? '処理中...'
                : (_isRecording ? 'タップして停止' : 'タップして話す'),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (_isProcessing) return;
    
    // メッセージカウントを増やす
    _messageCount++;
    
    // ユーザーメッセージを追加
    ref.read(chatMessagesProvider.notifier).addMessage(
      ChatMessage(text: text, isUser: true),
    );
    
    _scrollToBottom();
    
    setState(() {
      _isTyping = true;
      _isProcessing = true;
    });
    
    try {
      // AIの応答を生成
      final messages = ref.read(chatMessagesProvider);
      
      // システムプロンプトを構築
      String systemPrompt = '''You are playing the role of a customer at a hair salon/beauty salon. 

Your character:
- You are a foreign customer who speaks English
- You are visiting a hair salon in Japan
- You have various needs like haircut, coloring, styling, or treatments
- You should act like a real customer with preferences, questions, and sometimes concerns
- Be polite but natural, as a real customer would be

Your responses should:
1. Stay in character as a salon customer
2. Ask questions about services, prices, and time required
3. Express your preferences and concerns naturally
4. React appropriately to the staff's suggestions
5. Sometimes be unsure about what you want and ask for advice
6. Use common salon-related vocabulary

Common topics to discuss:
- Your desired hairstyle or color
- Previous experiences (good or bad)
- Hair concerns (damage, thinning, etc.)
- Time and budget constraints
- Maintenance and styling tips
- Product recommendations

Remember: You are the CUSTOMER, not the staff. The user is practicing being the salon staff member.''';
      
      final response = await _openAIService.generateChatResponse(
        messages: messages.map((m) => {
          'role': m.isUser ? 'user' : 'assistant',
          'content': m.text,
        }).toList(),
        systemPrompt: systemPrompt,
      );
      
      setState(() {
        _isTyping = false;
      });
      
      // AI応答を追加
      ref.read(chatMessagesProvider.notifier).addMessage(
        ChatMessage(
          text: response,
          isUser: false,
          corrections: _extractCorrections(text, response),
        ),
      );
      
      _scrollToBottom();
      
      // 自動的に音声を再生
      await _playMessageAudio(response);
      
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  List<String>? _extractCorrections(String userMessage, String aiResponse) {
    // 簡単な文法チェック（実際にはもっと高度な処理が必要）
    List<String> corrections = [];
    
    // TODO: より高度な文法チェックロジックを実装
    
    return corrections.isEmpty ? null : corrections;
  }

  Future<void> _playMessageAudio(String text) async {
    try {
      final audioData = await _openAIService.generateSpeech(
        text: text,
        voice: 'nova',
        speed: 1.0,
        model: 'tts-1', // TTS-1モデルを明示的に指定
      );
      
      // 音声データを一時ファイルに保存
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final audioFile = File('${tempDir.path}/tts_$timestamp.mp3');
      await audioFile.writeAsBytes(audioData);
      
      // 音声を再生
      await _audioPlayer.setFilePath(audioFile.path);
      await _audioPlayer.play();
      
      // 再生終了後にファイルを削除
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          audioFile.deleteSync();
        }
      });
    } catch (e) {
      print('Failed to play audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('音声再生エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // 録音停止
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });
      
      try {
        // 録音を停止
        print('Stopping recording...');
        final path = await _audioRecorder.stop();
        print('Recording stopped. Path: $path');
        
        if (path == null) {
          print('Recording path is null');
          setState(() {
            _isProcessing = false;
          });
          return;
        }
        
        // ファイルの存在とサイズを確認
        final audioFile = File(path);
        if (await audioFile.exists()) {
          final fileSize = await audioFile.length();
          print('Audio file exists. Size: $fileSize bytes');
          
          if (fileSize < 1000) {
            // ファイルが小さすぎる場合
            print('Audio file too small, likely no audio recorded');
            setState(() {
              _isProcessing = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('録音が短すぎます。もう少し長く話してください。'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
        } else {
          print('Audio file does not exist');
          setState(() {
            _isProcessing = false;
          });
          return;
        }
        
        // 音声認識
        print('Starting speech recognition...');
        final recognizedText = await _speechService.recognizeSpeech(
          audioFile: audioFile,
        );
        print('Recognition result: $recognizedText');
        
        if (recognizedText != null && recognizedText.isNotEmpty) {
          // 自動的にメッセージを送信
          await _sendMessage(recognizedText);
        } else {
          setState(() {
            _isProcessing = false;
          });
          
          // シミュレーターの場合は特別なメッセージ
          if (_isSimulator) {
            await _sendMessage("Hello, I'd like to practice English conversation.");
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('音声を認識できませんでした。もう一度お試しください。'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        
        // 一時ファイルを削除
        try {
          await audioFile.delete();
          print('Temporary audio file deleted');
        } catch (e) {
          print('Failed to delete audio file: $e');
        }
        
      } catch (e, stackTrace) {
        print('Error in _toggleRecording: $e');
        print('Stack trace: $stackTrace');
        
        setState(() {
          _isProcessing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('音声認識エラー: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } else {
      // 録音開始
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      // 録音権限をチェック
      final hasPermission = await _audioRecorder.hasPermission();
      print('Recording permission: $hasPermission');
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('マイクの使用許可が必要です。設定から許可してください。'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      // 録音の可否をチェック
      final canRecord = await _audioRecorder.isRecording();
      print('Is already recording: $canRecord');
      
      if (canRecord) {
        print('Already recording, stopping first...');
        await _audioRecorder.stop();
      }
      
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${tempDir.path}/recording_$timestamp.m4a';
      print('Recording path: $path');
      
      // iOS向けの設定
      final config = RecordConfig(
        encoder: AudioEncoder.aacLc, // iOSでより安定したエンコーダー
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      );
      
      await _audioRecorder.start(config, path: path);
      
      if (mounted) {
        setState(() {
          _isRecording = true;
        });
        print('Recording started successfully');
      }
    } catch (e, stackTrace) {
      print('録音開始エラー: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        String errorMessage = '録音の開始に失敗しました';
        
        if (e.toString().contains('permission')) {
          errorMessage = 'マイクの使用許可が必要です';
        } else if (e.toString().contains('simulator')) {
          errorMessage = 'シミュレーターでは録音機能が制限されています。実機でお試しください';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _startNewConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('会話をリセット'),
        content: const Text('現在の会話をクリアして、最初から始めますか？'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ref.read(chatMessagesProvider.notifier).clearMessages();
              _addInitialMessage();
            },
            child: const Text('リセット'),
          ),
        ],
      ),
    );
  }

  void _showCorrections(List<String> corrections) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('文法の訂正'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: corrections.map((correction) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(correction)),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _endConversationSession() async {
    // セッション時間を計算
    final sessionDuration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;
    
    // 平均発音スコアを計算（録音があった場合）
    final averageScore = _pronunciationScores.isNotEmpty
        ? _pronunciationScores.reduce((a, b) => a + b) / _pronunciationScores.length
        : 85.0; // デフォルトスコア
    
    // レッスンがある場合のみ進捗を記録
    if (_currentLesson != null) {
      final progressService = ref.read(progressServiceProvider);
      final (xpEarned, levelUpInfo) = await progressService.completeActivity(
        lessonId: _currentLesson!.id,
        activityType: 'ai_conversation',
        score: averageScore,
        timeSpent: sessionDuration,
      );
      
      // 実績チェック
      final newAchievements = await progressService.checkAchievements();
      
      if (!mounted) return;
      
      // XPアニメーションを表示
      if (xpEarned > 0) {
        XPAnimationOverlay.show(context, xpEarned);
      }
      
      // レベルアップ通知を表示
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
      
      // 実績通知を表示
      if (newAchievements.isNotEmpty) {
        final delay = levelUpInfo.hasLeveledUp ? 6000 : 1000;
        Future.delayed(Duration(milliseconds: delay), () {
          if (mounted) {
            AchievementNotificationOverlay.showMultiple(context, newAchievements);
          }
        });
      }
      
      // セッション完了ダイアログ
      _showSessionCompletionDialog(
        messageCount: _messageCount,
        duration: sessionDuration,
        averageScore: averageScore,
        xpEarned: xpEarned,
      );
    } else {
      // フリートークの場合は簡単な完了メッセージ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('会話練習お疲れさまでした！'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSessionCompletionDialog({
    required int messageCount,
    required int duration,
    required double averageScore,
    required int xpEarned,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.chat_bubble, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('AI会話セッション完了！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            _buildStatRow('メッセージ数', '$messageCount回'),
            const SizedBox(height: 8),
            _buildStatRow('会話時間', '${(duration / 60).toStringAsFixed(1)}分'),
            const SizedBox(height: 8),
            _buildStatRow('発音スコア', '${averageScore.toStringAsFixed(0)}%'),
            const SizedBox(height: 16),
            const Text(
              '素晴らしい会話練習でした！\n自然な英語でのコミュニケーションが上達しています。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '🎉 レッスンの全ステップが完了しました！',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              // 新しいセッションを開始
              setState(() {
                _messageCount = 0;
                _sessionStartTime = DateTime.now();
                _pronunciationScores.clear();
              });
              ref.read(chatMessagesProvider.notifier).clearMessages();
              _addInitialMessage();
            },
            child: const Text('新しい会話を始める'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: const Text('レッスンに戻る'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              // レッスン一覧に戻る
              context.go('/lessons');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('他のレッスンへ'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    // 画面を離れる時にメッセージをクリア
    ref.read(chatMessagesProvider.notifier).clearMessages();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? corrections;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    this.corrections,
  });
} 