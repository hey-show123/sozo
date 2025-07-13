import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sozo_app/data/models/lesson_model.dart' as lesson_model;
import 'package:sozo_app/services/audio_player_service.dart';
import 'package:sozo_app/services/audio_storage_service.dart';
import 'package:sozo_app/services/whisper_service.dart';
import 'package:sozo_app/services/ai_conversation_service.dart';
import 'package:sozo_app/services/openai_service.dart';
import 'package:sozo_app/services/progress_service.dart';
import 'package:sozo_app/presentation/providers/auth_provider.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'dart:io';

// 利用可能なOpenAIモデル
enum OpenAIModel {
  o3('o3', 'OpenAI o3 - 最先端の推論モデル'),
  o3Mini('o3-mini', 'OpenAI o3-mini - 効率的な推論モデル'),
  gpt45('gpt-4.5-preview', 'GPT-4.5 - 最新の大規模言語モデル'),
  gpt41('gpt-4.1', 'GPT-4.1 - 高性能コーディング特化'),
  gpt41Mini('gpt-4.1-mini', 'GPT-4.1-mini - 効率的な中型モデル'),
  gpt41Nano('gpt-4.1-nano', 'GPT-4.1-nano - 軽量・高速'),
  o4Mini('o4-mini', 'OpenAI o4-mini - 次世代推論モデル'),
  gpt4o('gpt-4o', 'GPT-4o - マルチモーダル対応'),
  gpt4oMini('gpt-4o-mini', 'GPT-4o-mini - 軽量版'),
  gpt35Turbo('gpt-3.5-turbo', 'GPT-3.5 Turbo - 高速応答');

  final String value;
  final String displayName;
  
  const OpenAIModel(this.value, this.displayName);
}

// AI思考中インジケーターウィジェット
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) => AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    ));
    
    _animations = _controllers.map((controller) => Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ))).toList();
    
    // 各ドットのアニメーションを少しずつ遅らせて開始
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.smart_toy,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'AIが考えています',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Row(
            children: List.generate(3, (index) => AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: 0.5 + (_animations[index].value * 0.5),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade400.withOpacity(_animations[index].value),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}

// アニメーションテキストウィジェット（タイプライター効果）
class AnimatedTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration animationDuration;

  const AnimatedTextWidget({
    Key? key,
    required this.text,
    this.style,
    this.animationDuration = const Duration(milliseconds: 50),
  }) : super(key: key);

  @override
  _AnimatedTextWidgetState createState() => _AnimatedTextWidgetState();
}

class _AnimatedTextWidgetState extends State<AnimatedTextWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _displayedText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration * widget.text.length,
    );
    
    _controller.addListener(() {
      final newIndex = (_controller.value * widget.text.length).floor();
      if (newIndex != _currentIndex && newIndex <= widget.text.length) {
        setState(() {
          _currentIndex = newIndex;
          _displayedText = widget.text.substring(0, _currentIndex);
        });
      }
    });
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _currentIndex = 0;
      _displayedText = '';
      _controller.reset();
      _controller.duration = widget.animationDuration * widget.text.length;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}

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
    extends ConsumerState<AIConversationPracticeScreen>
    with TickerProviderStateMixin {
  // 録音関連
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isAIThinking = false;
  String? _recordingPath;
  
  // 音声関連サービス  
  late AudioPlayerService _audioPlayer;
  late AudioStorageService _audioStorage;
  late WhisperService _whisperService;
  late OpenAIService _openAIService;
  late AIConversationService _aiService;
  late ProgressService _progressService;
  
  // 会話管理
  final List<ConversationMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentSessionNumber = 1;
  final int _totalSessions = 3;
  Timer? _timer;
  int _elapsedSeconds = 0;
  final int _sessionTimeLimit = 180; // 3分
  final Map<String, int> _evaluationResults = {
    'responseCount': 0,
    'targetPhrasesUsed': 0,
  };
  
  // セッション評価データ
  final List<SessionEvaluation> _sessionEvaluations = [];
  
  // UI関連
  late AnimationController _feedbackController;
  DetailedFeedback? _currentFeedback;
  bool _showDetailedFeedback = false;
  
  // 各メッセージの翻訳表示状態
  final Map<int, bool> _messageTranslationStates = {};
  
  // モデル選択
  OpenAIModel _selectedModel = OpenAIModel.gpt41Mini;
  
  @override
  void initState() {
    super.initState();
    _openAIService = OpenAIService();
    _audioRecorder = AudioRecorder();
    _whisperService = WhisperService();
    _aiService = AIConversationService();
    _progressService = ProgressService();
    
    _startSessionTimer();
    
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // WidgetsBindingを使って初期化を遅延実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supabase = ref.read(supabaseProvider);
      
      _audioStorage = AudioStorageService(
        supabase: supabase,
        openAIService: _openAIService,
      );
      _audioPlayer = AudioPlayerService(audioStorage: _audioStorage);
      
      // 会話を初期化
      _initializeConversation();
    });
  }

  // セッションタイマーを開始
  void _startSessionTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
        
        // 1分経過したらセッション終了（setStateの外で実行）
        if (_elapsedSeconds >= _sessionTimeLimit) {
          _timer?.cancel();
          // 音声再生を停止
          _audioPlayer.stop();
          // 録音を停止
          if (_isRecording) {
            _audioRecorder.stop();
          }
          // AI処理を停止
          setState(() {
            _isAIThinking = false;
            _isProcessing = false;
            _isRecording = false;
          });
          // 自動的にセッション終了処理を実行
          _endSession();
        }
      }
    });
  }

  // AI会話の初期化
  Future<void> _initializeConversation() async {
    try {
      // タイマーが動いていることを確認
      if (_timer == null || !_timer!.isActive) {
        _startSessionTimer();
      }
      
      // 初期プロンプトを送信してAIとの会話を開始
      // AIはお客様として入店してくる
      final response = await _aiService.generateResponseWithFeedback(
        userInput: '[System: The customer is entering the salon. Please greet them.]',
        conversationHistory: [],
        targetPhrases: widget.lesson.keyPhrases.map((p) => p.phrase).toList(),
        sessionNumber: _currentSessionNumber,
        userLevel: 'intermediate',
        model: _selectedModel.value,
      );

      if (mounted) {
      setState(() {
          // AIのお客様の最初の発言を追加
          _messages.add(ConversationMessage(
            text: response.aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
            translation: response.translation,
            feedback: null, // AIの発言にはフィードバックなし
            severity: 'none',
            isTemporary: false,
            isAnimating: true, // タイプライター効果用フラグ
          ));
        });
        
        // AI音声を生成して再生
        _generateAndPlayAIVoice(response.aiResponse);
        
        _scrollToBottom();
      }
    } catch (e) {
      print('Error initializing conversation: $e');
      if (mounted) {
        // フォールバックメッセージ
        setState(() {
          _messages.add(ConversationMessage(
            text: 'Hello, I heard this salon is really good!',
            isUser: false,
            timestamp: DateTime.now(),
            translation: 'こんにちは、このサロンは評判がいいと聞きました！',
            feedback: null,
            severity: 'none',
            isTemporary: false,
            isAnimating: true, // タイプライター効果用フラグ
          ));
        });
        _scrollToBottom();
      }
    }
  }

  String _getSessionStartMessage() {
    const messages = [
      "Hello! Welcome to our beauty salon. How can I help you today?",
      "Good to see you again! What treatment are you interested in today?",
      "Hi there! I noticed you were looking at our treatment menu. Any questions?",
      "Welcome back! How did the last treatment work out for you?",
      "Hello! We have some special offers on treatments today. Would you like to hear about them?",
    ];
    
    return messages[(_currentSessionNumber - 1) % messages.length];
  }

  String _getSessionStartMessageTranslation() {
    const translations = [
      "こんにちは！私たちのビューティーサロンへようこそ。今日はどのようなご用件でしょうか？",
      "また会えて嬉しいです！今日はどんなトリートメントにご興味がありますか？",
      "こんにちは！トリートメントメニューをご覧になっていたようですが、何かご質問はありますか？",
      "おかえりなさい！前回のトリートメントはいかがでしたか？",
      "こんにちは！今日はトリートメントの特別オファーがあります。お聞きになりますか？",
    ];
    
    return translations[(_currentSessionNumber - 1) % translations.length];
  }

  // メッセージを送信
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    _textController.clear();
    await _sendMessageWithText(text);
  }
  
  // テキストでメッセージを送信
  Future<void> _sendMessageWithText(String userMessage) async {
    if (userMessage.trim().isEmpty) return;
    
    setState(() {
      _isAIThinking = true;
      // ユーザー（スタッフ）のメッセージを追加
      _messages.add(ConversationMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
        isTemporary: true, // 一時的なフラグ
      ));
    });
    
    _scrollToBottom();
    _evaluationResults['responseCount'] = (_evaluationResults['responseCount'] ?? 0) + 1;
    
    // ターゲットフレーズの使用をチェック
    for (final phrase in widget.lesson.keyPhrases) {
      if (userMessage.toLowerCase().contains(phrase.phrase.toLowerCase())) {
        _evaluationResults['targetPhrasesUsed'] = (_evaluationResults['targetPhrasesUsed'] ?? 0) + 1;
        break;
      }
    }

    try {
      // 会話履歴を準備（システムメッセージは除外）
      final conversationHistory = _messages
          .where((msg) => !msg.text.startsWith('[System:'))
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();
      
      // AIの応答を取得（お客様として）
      final response = await _aiService.generateResponseWithFeedback(
        userInput: userMessage,
        conversationHistory: conversationHistory,
        targetPhrases: widget.lesson.keyPhrases.map((p) => p.phrase).toList(),
        sessionNumber: _currentSessionNumber,
        userLevel: 'intermediate',
        model: _selectedModel.value,
      );

      // 一時的なメッセージを正式なメッセージに更新
      final tempIndex = _messages.indexWhere((msg) => msg.isTemporary);
      if (tempIndex != -1) {
        setState(() {
          _messages[tempIndex] = ConversationMessage(
            text: userMessage,
            isUser: true,
            timestamp: DateTime.now(),
            feedback: response.feedback,
            severity: response.feedback.severity,
            isTemporary: false,
          );
          
          // AIの応答を追加（お客様として）
          _messages.add(ConversationMessage(
            text: response.aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
            translation: response.translation,
            feedback: null, // お客様の発言にはフィードバックなし
            severity: 'none',
            isTemporary: false,
            isAnimating: true, // タイプライター効果用フラグ
          ));
          
          _isAIThinking = false;
        });
      }
      
      // AI音声を生成して再生
      _generateAndPlayAIVoice(response.aiResponse);
      
      _scrollToBottom();
      
    } catch (e) {
      print('Error sending message: $e');
      _showError('メッセージの送信に失敗しました');
      
      // エラー時は一時的なメッセージを削除
      setState(() {
        _messages.removeWhere((msg) => msg.isTemporary);
        _isAIThinking = false;
      });
    } finally {
      setState(() {
        _isAIThinking = false;
      });
    }
  }

  Future<void> _playAIResponse(String text) async {
    try {
      // AI応答を音声で再生
      final audioData = await _openAIService.generateSpeech(
        text: text,
        voice: 'fable',
        speed: 0.95,
      );
      
      await _audioPlayer.playAudioData(audioData);
    } catch (e) {
      print('Error playing AI response: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = _getRemainingSeconds();
    final isTimeWarning = remainingTime <= 60 && remainingTime > 0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI会話練習'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // モデル表示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.blue, size: 18),
                const SizedBox(width: 4),
                Text(
                  _selectedModel.displayName,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // セッション情報バー
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isTimeWarning ? Colors.orange.shade50 : Colors.grey.shade100,
                border: Border(
                  bottom: BorderSide(
                    color: isTimeWarning ? Colors.orange.shade200 : Colors.grey.shade300,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'セッション $_currentSessionNumber/$_totalSessions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.timer, 
                        size: 20,
                        color: isTimeWarning ? Colors.orange : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '残り時間 ${_formatTime(remainingTime)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isTimeWarning ? Colors.orange : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 会話表示エリア
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isAIThinking ? 1 : 0),
                      itemBuilder: (context, index) {
                        // AI思考中インジケーターを表示
                        if (_isAIThinking && index == _messages.length) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const TypingIndicator(),
                            ),
                          );
                        }
                        
                        final message = _messages[index];
                        return _buildMessageBubble(message, index);
                      },
                    ),
            ),
            
            // 入力エリア
            _buildInputArea(),
          ],
        ),
      ),
      // 次のセッションへのボタン
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton.extended(
          onPressed: _isProcessing || _elapsedSeconds < 10 
              ? null 
              : () => _endSession(),
          icon: _isProcessing 
              ? const SizedBox(
                  width: 20, 
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check),
          label: Text(
            _isProcessing 
                ? '評価中...' 
                : 'セッション終了',
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: _isProcessing 
              ? Colors.grey 
              : _elapsedSeconds < 10
                  ? Colors.grey.shade400
                  : Colors.green,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }

  Color _getFeedbackColor(FeedbackData? feedback) {
    if (feedback == null) return Colors.blue[100]!;
    
    switch (feedback.severity) {
      case 'major':
        return Colors.red[50]!;
      case 'minor':
        return Colors.orange[50]!;
      default:
        return Colors.blue[100]!;
    }
  }

  Widget _buildFeedbackIndicator(FeedbackData feedback) {
    Color color;
    IconData icon;
    
    switch (feedback.severity) {
      case 'major':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'minor':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        color = Colors.green;
        icon = Icons.check_circle;
    }
    
    return Icon(icon, color: color, size: 16);
  }

  void _showMessageOptions(int index) {
    showDialog(
      context: context,
      builder: (context) => _buildMessageOptions(index),
    );
  }

  Widget _buildDetailedFeedbackDialog() {
    if (_currentFeedback == null) return const SizedBox();
    
    return Dialog(
      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '詳細フィードバック',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showDetailedFeedback = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // スコア表示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreItem('文法', _currentFeedback!.grammarAnalysis.score),
                _buildScoreItem('流暢さ', _currentFeedback!.fluencyScore),
                _buildScoreItem('関連性', _currentFeedback!.relevanceScore),
              ],
            ),
            const SizedBox(height: 20),
            
            // 文法エラー
            if (_currentFeedback!.grammarAnalysis.errors.isNotEmpty) ...[
              const Text(
                '文法の改善点:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._currentFeedback!.grammarAnalysis.errors.map((error) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          error.error,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '→ ${error.correction}',
                          style: const TextStyle(color: Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          error.explanation,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
            
            // 発音のヒント
            if (_currentFeedback!.pronunciationHints.isNotEmpty) ...[
              const Text(
                '発音のヒント:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._currentFeedback!.pronunciationHints.map((hint) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(hint)),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
            
            // 語彙フィードバック
            if (_currentFeedback!.vocabularyFeedback.suggestions.isNotEmpty) ...[
              const Text(
                '語彙の改善:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._currentFeedback!.vocabularyFeedback.suggestions.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text(suggestion)),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
            
            // 総合フィードバック
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentFeedback!.overallFeedback,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentFeedback!.encouragement,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, double score) {
    print('Building score item: $label with score: $score');
    
    // NaNチェックとフォールバック
    double validScore = score;
    if (score.isNaN || score.isInfinite) {
      print('Warning: Invalid score detected for $label: $score, using default 70.0');
      validScore = 70.0;
    }
    
    // 0-100の範囲にクランプ
    final clampedScore = validScore.clamp(0.0, 100.0);
    print('Clamped score for $label: $clampedScore');
    
    // CircularProgressIndicatorのvalue計算
    double progressValue = clampedScore / 100.0;
    if (progressValue.isNaN || progressValue.isInfinite) {
      print('Warning: Invalid progress value for $label: $progressValue, using 0.7');
      progressValue = 0.7;
    }
    
    print('Progress value for $label: $progressValue');
    
    final color = clampedScore >= 80 ? Colors.green : clampedScore >= 60 ? Colors.orange : Colors.red;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.grey[300],
            color: color,
            strokeWidth: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${clampedScore.round()}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // 録音開始
  Future<void> _startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      _showError('マイクの権限が必要です');
      return;
    }

    try {
      // 一時ディレクトリに録音
      final tempDir = await Directory.systemTemp.createTemp('recording');
      _recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: _recordingPath!,
      );
      
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recording: $e');
      _showError('録音を開始できませんでした');
    }
  }

  // 録音停止と処理
  Future<void> _stopRecordingAndProcess() async {
    try {
      final path = await _audioRecorder.stop();
      
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });
      
      if (path == null || path.isEmpty) {
        _showError('録音に失敗しました');
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      
      final audioFile = File(path);
      
      // ファイルが存在し、サイズが適切か確認
      if (!await audioFile.exists()) {
        _showError('録音ファイルが見つかりません');
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      
      final fileSize = await audioFile.length();
      print('Recorded file size: $fileSize bytes');
      
      if (fileSize < 100) {
        _showError('録音が短すぎます');
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      
      // Whisperで音声認識
      final transcription = await _whisperService.transcribeAudio(
        audioFile: audioFile,
        language: 'en',
        prompt: 'Beauty salon conversation in English',
      );
      
      // 一時ファイルを削除
      try {
        await audioFile.delete();
      } catch (e) {
        print('Error deleting recording file: $e');
      }
      
      if (transcription == null || transcription.isEmpty) {
        _showError('音声を認識できませんでした。もう一度お試しください。');
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      
      print('Transcription: $transcription');
      
      // 認識されたテキストを送信
      await _sendMessageWithText(transcription);
      
    } catch (e) {
      print('Error processing recording: $e');
      _showError('録音の処理に失敗しました');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // メッセージ取り消し
  void _cancelMessage(int index) {
    if (index < 0 || index >= _messages.length) return;
    
    final message = _messages[index];
    if (!message.isUser) return;
    
    setState(() {
      // メッセージとその後のAI応答を削除
      _messages.removeAt(index);
      if (index < _messages.length && !_messages[index].isUser) {
        _messages.removeAt(index);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('メッセージを取り消しました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 詳細フィードバックを取得
  Future<void> _getDetailedFeedback(String userInput) async {
    try {
      setState(() {
        _isProcessing = true;
      });
      
      final feedback = await _aiService.generateDetailedFeedback(
        userInput: userInput,
        targetPhrases: widget.lesson.keyPhrases.map((p) => p.phrase).toList(),
        expectedContext: widget.lesson.description,
        model: _selectedModel.value,
      );
      
      setState(() {
        _currentFeedback = feedback;
        _showDetailedFeedback = true;
      });
    } catch (e) {
      print('Error getting detailed feedback: $e');
      _showError('フィードバックの取得に失敗しました');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // セッション完了
  Future<void> _completeSession() async {
    try {
      // 会話履歴を保存
      final conversationHistory = _messages.map((msg) => {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      }).toList();
      
      // フィードバックを生成
      final feedback = await _aiService.evaluateConversation(
        conversationHistory: conversationHistory,
        targetPhrases: widget.lesson.keyPhrases.map((p) => p.phrase).toList(),
        sessionNumber: _currentSessionNumber,
      );
      
      // 評価結果を更新
      _evaluationResults['overallScore'] = feedback.overallScore.round();
      _evaluationResults['phraseScore'] = feedback.phraseUsageScore.round();
      _evaluationResults['fluencyScore'] = feedback.fluencyScore.round();
      
      // 次のセッションへ
      if (_currentSessionNumber < _totalSessions) {
        _nextSession();
      } else {
        _showFinalResults();
      }
    } catch (e) {
      print('Error completing session: $e');
      _showError('セッションの完了に失敗しました');
    }
  }

  // 全セッション完了
  Future<void> _completeAllSessions(double score) async {
    try {
      // 進捗を記録
      await _progressService.completeActivity(
        lessonId: widget.lesson.id,
        activityType: 'ai_conversation',
        score: score,
        timeSpent: _elapsedSeconds,
      );
      
      if (!mounted) return;
      
      // 完了画面へ遷移
      context.go('/lesson/${widget.lesson.id}/complete', extra: {
        'score': score,
        'sessionCount': _currentSessionNumber,
      });
    } catch (e) {
      print('Error completing sessions: $e');
      _showError('進捗の保存に失敗しました');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _feedbackController.dispose();
    _textController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildModelSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.smart_toy, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<OpenAIModel>(
                value: _selectedModel,
                isExpanded: true,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items: OpenAIModel.values.map((model) {
                  return DropdownMenuItem(
                    value: model,
                    child: Text(model.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedModel = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('モデルを${value.displayName}に変更しました'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageOptions(int index) {
    return AlertDialog(
      title: const Text('メッセージオプション'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('詳細フィードバック'),
            onTap: () {
              Navigator.pop(context);
              _getDetailedFeedback(_messages[index].text);
            },
          ),
          if (index == _messages.length - 2) // 最新のユーザーメッセージ
            ListTile(
              leading: const Icon(Icons.undo),
              title: const Text('取り消し'),
              onTap: () {
                Navigator.pop(context);
                _cancelMessage(index);
              },
            ),
        ],
      ),
    );
  }

  // AI音声を生成して再生
  Future<void> _generateAndPlayAIVoice(String text) async {
    try {
      final audioData = await _openAIService.generateSpeech(
        text: text,
        voice: 'alloy',
        speed: 1.0,
      );
      
      if (mounted) {
        await _audioPlayer.playAudioData(audioData.toList());
      }
    } catch (e) {
      print('Error generating AI voice: $e');
    }
  }

  // 次のセッションへ移行
  void _nextSession() {
    if (_currentSessionNumber < _totalSessions) {
      setState(() {
        _currentSessionNumber++;
        _messages.clear();
        _elapsedSeconds = 0;
        // 評価結果をリセット
        _evaluationResults['responseCount'] = 0;
        _evaluationResults['targetPhrasesUsed'] = 0;
      });
      // タイマーを再開
      _startSessionTimer();
      // 新しいセッションの会話を初期化
      _initializeConversation();
    }
  }
  
  // 最終結果を表示
  void _showFinalResults() {
    // 全セッションの平均スコアを計算
    double totalScore = 0;
    double totalGrammar = 0;
    double totalFluency = 0;
    double totalRelevance = 0;
    int totalTime = 0;
    int totalPhraseUsage = 0;
    
    for (final eval in _sessionEvaluations) {
      totalScore += eval.score;
      totalGrammar += eval.grammarScore;
      totalFluency += eval.fluencyScore;
      totalRelevance += eval.relevanceScore;
      totalTime += eval.timeSpent;
      totalPhraseUsage += eval.phraseUsageCount;
    }
    
    final avgScore = totalScore / _sessionEvaluations.length;
    final avgGrammar = totalGrammar / _sessionEvaluations.length;
    final avgFluency = totalFluency / _sessionEvaluations.length;
    final avgRelevance = totalRelevance / _sessionEvaluations.length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            const Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 8),
            const Text(
              '全セッション完了！',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 総合スコア
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getScoreColor(avgScore).withOpacity(0.2),
                        _getScoreColor(avgScore).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getScoreColor(avgScore),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '総合スコア',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${avgScore.round()}点',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(avgScore),
                        ),
                      ),
                      Text(
                        _getScoreMessage(avgScore),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getScoreColor(avgScore),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // 詳細スコア
                Card(
                  elevation: 2,
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '詳細スコア',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSimpleScoreItem('文法', avgGrammar),
                            _buildSimpleScoreItem('流暢さ', avgFluency),
                            _buildSimpleScoreItem('関連性', avgRelevance),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // セッションごとの結果
                ExpansionTile(
                  title: const Text(
                    'セッション別スコア',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: _sessionEvaluations.map((eval) => Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: InkWell(
                      onTap: () => _showSessionDetail(eval),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  size: 20,
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text('セッション ${eval.sessionNumber}'),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(eval.score).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getScoreColor(eval.score),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${eval.score.round()}点',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getScoreColor(eval.score),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _completeAllSessions(avgScore);
            },
            icon: const Icon(Icons.home),
            label: const Text('ホームへ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // もう一度練習
              setState(() {
                _currentSessionNumber = 1;
                _messages.clear();
                _sessionEvaluations.clear();
                _evaluationResults['responseCount'] = 0;
                _evaluationResults['targetPhrasesUsed'] = 0;
              });
              _startSessionTimer();
              _initializeConversation();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('もう一度'),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
  
  // セッションの詳細を表示
  void _showSessionDetail(SessionEvaluation eval) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('セッション ${eval.sessionNumber} の詳細'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // スコア
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSimpleScoreItem('総合', eval.score),
                      _buildSimpleScoreItem('文法', eval.grammarScore),
                      _buildSimpleScoreItem('流暢さ', eval.fluencyScore),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // フィードバック
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'フィードバック',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eval.feedback,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
  
  // スコアに応じたメッセージを取得
  String _getScoreMessage(double score) {
    if (score >= 90) return '素晴らしい！エクセレント！';
    if (score >= 80) return 'とても良い成績です！';
    if (score >= 70) return '良い調子です！';
    if (score >= 60) return 'もう少し頑張りましょう！';
    return '練習を続けましょう！';
  }
  
  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
  
  // 時間をフォーマット
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  int _getRemainingSeconds() {
    return _sessionTimeLimit - _elapsedSeconds;
  }

  // 詳細フィードバックダイアログを表示
  void _showFeedbackDialog(ConversationMessage message) {
    if (message.feedback == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _buildFeedbackIndicator(message.feedback!),
            const SizedBox(width: 8),
            const Text('フィードバック'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.feedback!.grammarErrors.isNotEmpty) ...[
                const Text(
                  '文法エラー:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...message.feedback!.grammarErrors.map((error) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $error'),
                )),
                const SizedBox(height: 12),
              ],
              if (message.feedback!.suggestions.isNotEmpty) ...[
                const Text(
                  '改善提案:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...message.feedback!.suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $suggestion'),
                )),
              ],
              if (message.feedback!.isOffTopic) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚠️ トピックから外れています',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  // メッセージバブルを構築
  Widget _buildMessageBubble(ConversationMessage message, int index) {
    final isUser = message.isUser;
    final hasFeedback = message.feedback != null && 
                        (message.feedback!.grammarErrors.isNotEmpty || 
                         message.feedback!.suggestions.isNotEmpty);
    
    return GestureDetector(
      onLongPress: isUser ? () => _showMessageOptions(index) : null,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: isUser 
                ? _getFeedbackColor(message.feedback)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            border: hasFeedback 
                ? Border.all(
                    color: message.severity == 'major' 
                        ? Colors.red 
                        : message.severity == 'minor'
                            ? Colors.orange
                            : Colors.green,
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: message.isAnimating
                        ? AnimatedTextWidget(
                            text: message.text,
                            style: const TextStyle(fontSize: 16),
                          )
                        : Text(
                            message.text,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  if (hasFeedback) ...[
                    const SizedBox(width: 8),
                    _buildFeedbackIndicator(message.feedback!),
                  ],
                ],
              ),
              // AIメッセージの翻訳表示
              if (!isUser && message.translation != null && message.translation!.isNotEmpty) ...[
                const SizedBox(height: 8),
                if (_messageTranslationStates[index] == true) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message.translation!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _messageTranslationStates[index] = !(_messageTranslationStates[index] ?? false);
                    });
                  },
                  icon: Icon(
                    _messageTranslationStates[index] == true 
                        ? Icons.visibility_off 
                        : Icons.translate,
                    size: 16,
                  ),
                  label: Text(
                    _messageTranslationStates[index] == true 
                        ? '翻訳を隠す' 
                        : '翻訳を表示',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
              if (isUser && hasFeedback) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _showFeedbackDialog(message),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.feedback, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'フィードバックを見る',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  // 入力エリアを構築
  Widget _buildInputArea() {
    return Container(
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
            const Text(
              '録音中...',
              style: TextStyle(color: Colors.red),
            ),
          if (_isProcessing)
            const LinearProgressIndicator(),
          const SizedBox(height: 8),
          
          // テキスト入力とボタン
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: '英語でメッセージを入力...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              // 録音ボタン
              IconButton(
                onPressed: _isProcessing
                    ? null
                    : (_isRecording ? _stopRecordingAndProcess : _startRecording),
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
                iconSize: 32,
              ),
              // 送信ボタン
              IconButton(
                onPressed: _isProcessing ? null : _sendMessage,
                icon: const Icon(Icons.send),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
  


  // セッション終了処理
  Future<void> _endSession() async {
    try {
      // タイマーを停止
      _timer?.cancel();
      
      setState(() {
        _isProcessing = true;
      });
      
      // 会話履歴を準備
      final conversationHistory = _messages
          .where((msg) => !msg.text.startsWith('[System:'))
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();
      
      // 会話履歴が空の場合は早期リターン
      if (conversationHistory.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        _showError('会話履歴がありません。会話を始めてからセッションを終了してください。');
        return;
      }
      
      // セッション評価を生成
      final evaluation = await _aiService.evaluateSession(
        conversationHistory: conversationHistory,
        targetPhrases: widget.lesson.keyPhrases.map((p) => p.phrase).toList(),
        sessionNumber: _currentSessionNumber,
        timeSpent: _elapsedSeconds,
        userResponses: _evaluationResults['responseCount'] ?? 0,
        targetPhrasesUsed: _evaluationResults['targetPhrasesUsed'] ?? 0,
      );
      
      print('Session evaluation: {');
      print('  "overallScore": ${evaluation.overallScore},');
      print('  "grammarScore": ${evaluation.grammarScore},');
      print('  "fluencyScore": ${evaluation.fluencyScore},');
      print('  "relevanceScore": ${evaluation.relevanceScore},');
      print('  "feedback": "${evaluation.feedback}"');
      print('}');
      
      // 評価を保存
      _sessionEvaluations.add(SessionEvaluation(
        sessionNumber: _currentSessionNumber,
        score: evaluation.overallScore,
        feedback: evaluation.feedback,
        timeSpent: _elapsedSeconds,
        phraseUsageCount: _evaluationResults['targetPhrasesUsed'] ?? 0,
        grammarScore: evaluation.grammarScore,
        fluencyScore: evaluation.fluencyScore,
        relevanceScore: evaluation.relevanceScore,
      ));
      
      setState(() {
        _isProcessing = false;
      });
      
      // フィードバックダイアログを表示
      if (mounted) {
        print('Calling _showSessionFeedback...');
        _showSessionFeedback(evaluation);
      } else {
        print('Widget not mounted, cannot show feedback dialog');
      }
      
    } catch (e) {
      print('Error ending session: $e');
      setState(() {
        _isProcessing = false;
      });
      _showError('セッション終了処理に失敗しました: $e');
      
      // エラーが発生してもダイアログを表示（デフォルトのフィードバック）
      if (mounted) {
        final defaultFeedback = SessionFeedback(
          overallScore: 70,
          grammarScore: 70,
          fluencyScore: 70,
          relevanceScore: 70,
          feedback: 'セッション${_currentSessionNumber}お疲れ様でした！\n\n練習時間: ${_formatTime(_elapsedSeconds)}\n応答回数: ${_evaluationResults['responseCount'] ?? 0}回\n\n引き続き練習を頑張りましょう！',
        );
        _showSessionFeedback(defaultFeedback);
      }
    }
  }
  
  // セッションフィードバックダイアログを表示
  void _showSessionFeedback(SessionFeedback feedback) {
    print('_showSessionFeedback called with feedback: ${feedback.feedback}');
    
    // スコアのNaNチェック
    if (feedback.overallScore.isNaN || feedback.grammarScore.isNaN || 
        feedback.fluencyScore.isNaN || feedback.relevanceScore.isNaN) {
      print('Warning: NaN scores detected in feedback');
      print('Scores: overall=${feedback.overallScore}, grammar=${feedback.grammarScore}, fluency=${feedback.fluencyScore}, relevance=${feedback.relevanceScore}');
    }
    
    // UIの更新を確実に行うために、次のフレームで実行
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        print('Widget not mounted after frame callback');
        return;
      }
      
      // さらに少し待機してUIを安定させる
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) {
        print('Widget not mounted after delay');
        return;
      }
      
      try {
        print('Attempting to show dialog...');
        
        // ダイアログを表示する前に現在のコンテキストが有効か確認
        if (!context.mounted) {
          print('Context not mounted, cannot show dialog');
          return;
        }
        
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          builder: (BuildContext dialogContext) {
            print('Building dialog widget...');
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                children: [
                  const Icon(
                    Icons.celebration,
                    size: 48,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'セッション $_currentSessionNumber 完了！',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // スコア表示（カード形式）
                      Card(
                        elevation: 2,
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text(
                                'スコア',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildSimpleScoreItem('総合', feedback.overallScore),
                                  _buildSimpleScoreItem('文法', feedback.grammarScore),
                                  _buildSimpleScoreItem('流暢さ', feedback.fluencyScore),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // フィードバック
                      Container(
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(11),
                                  topRight: Radius.circular(11),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.feedback,
                                    size: 20,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AIからのフィードバック',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 200,
                              padding: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                child: Text(
                                  feedback.feedback,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (_currentSessionNumber < _totalSessions)
                  ElevatedButton.icon(
                    onPressed: () {
                      print('Next session button pressed');
                      Navigator.of(dialogContext).pop();
                      _nextSession();
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('次のセッションへ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      print('Complete button pressed');
                      Navigator.of(dialogContext).pop();
                      _showFinalResults();
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('練習完了'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () {
                    print('Close button pressed');
                    Navigator.of(dialogContext).pop();
                    context.go('/lesson/${widget.lesson.id}');
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('終了'),
                ),
              ],
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          },
        );
        print('Dialog closed');
      } catch (e, stackTrace) {
        print('Error showing dialog: $e');
        print('Stack trace: $stackTrace');
        
        // フォールバック: SnackBarで簡単なフィードバックを表示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'セッション完了！スコア: ${feedback.overallScore.toInt()}%',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: '詳細',
                textColor: Colors.white,
                onPressed: () {
                  // 再度ダイアログ表示を試みる
                  _showSessionFeedback(feedback);
                },
              ),
            ),
          );
        }
      }
    });
  }

  // シンプルなスコア表示ウィジェット（円形プログレスバー）
  Widget _buildSimpleScoreItem(String label, double score) {
    final validScore = score.isNaN || score.isInfinite ? 70.0 : score.clamp(0.0, 100.0);
    final color = validScore >= 80 ? Colors.green : validScore >= 60 ? Colors.orange : Colors.red;
    final progressValue = validScore / 100.0;
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey[300],
                color: color,
                strokeWidth: 6,
              ),
            ),
            Text(
              '${validScore.round()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// 会話メッセージモデル
class ConversationMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? translation;
  FeedbackData? feedback;
  String? severity;
  final bool isTemporary;
  final bool isAnimating;

  ConversationMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.translation,
    this.feedback,
    this.severity,
    this.isTemporary = false,
    this.isAnimating = false,
  });
}

// セッション評価モデル
class SessionEvaluation {
  final int sessionNumber;
  final double score;
  final String feedback;
  final int timeSpent;
  final int phraseUsageCount;
  final double grammarScore;
  final double fluencyScore;
  final double relevanceScore;

  SessionEvaluation({
    required this.sessionNumber,
    required this.score,
    required this.feedback,
    required this.timeSpent,
    required this.phraseUsageCount,
    required this.grammarScore,
    required this.fluencyScore,
    required this.relevanceScore,
  });
} 