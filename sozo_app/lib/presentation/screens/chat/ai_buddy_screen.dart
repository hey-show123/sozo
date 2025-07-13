import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

// AI思考中インジケーターウィジェット（改善版）
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
    this.animationDuration = const Duration(milliseconds: 30),
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

class AiBuddyScreen extends ConsumerStatefulWidget {
  const AiBuddyScreen({
    super.key,
  });

  @override
  ConsumerState<AiBuddyScreen> createState() => _AiBuddyScreenState();
}

class _AiBuddyScreenState extends ConsumerState<AiBuddyScreen>
    with TickerProviderStateMixin {
  // 録音関連
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isAIThinking = false;
  bool _isSessionEnded = false;
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
  
  // 各メッセージの翻訳表示状態
  final Map<int, bool> _messageTranslationStates = {};
  
  // セッション管理
  Timer? _timer;
  int _elapsedSeconds = 0;
  final int _sessionTimeLimit = 3 * 60; // 3分
  final Map<String, dynamic> _evaluationResults = {
    'responseCount': 0,
    'targetPhrasesUsed': 0,
  };
  
  @override
  void initState() {
    super.initState();
    _openAIService = OpenAIService();
    _audioRecorder = AudioRecorder();
    _whisperService = WhisperService();
    _aiService = AIConversationService();
    _progressService = ProgressService();
    
    _startSessionTimer();
    
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

  // AI会話の初期化
  Future<void> _initializeConversation() async {
    try {
      // AIお客様として最初のメッセージを生成
      final response = await _aiService.generateResponseWithFeedback(
        userInput: '[System: A customer is entering your salon. They seem to be a new customer looking for a haircut service. Please greet them naturally as a customer would.]',
        conversationHistory: [],
        targetPhrases: [], // 一般会話なのでターゲットフレーズは不要
        sessionNumber: 1,
        userLevel: 'intermediate',
        model: 'gpt-4o-mini',
      );

      if (mounted) {
        setState(() {
          // AIのお客様の最初の発言を追加
          _messages.add(ConversationMessage(
            text: response.aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
            translation: response.translation,
            feedback: null,
            severity: 'none',
            isTemporary: false,
            isAnimating: true,
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
            text: 'Hello! I\'ve heard good things about this salon. Do you have time for a walk-in?',
            isUser: false,
            timestamp: DateTime.now(),
            translation: 'こんにちは！このサロンの評判を聞いてきました。予約なしでも大丈夫ですか？',
            feedback: null,
            severity: 'none',
            isTemporary: false,
            isAnimating: true,
          ));
        });
        _scrollToBottom();
      }
    }
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
        isTemporary: true,
      ));
    });
    
    _scrollToBottom();
    _evaluationResults['responseCount'] = (_evaluationResults['responseCount'] ?? 0) + 1;

    try {
      // 会話履歴を準備
      final conversationHistory = _messages
          .where((msg) => !msg.text.startsWith('[System:') && !msg.isTemporary)
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();
      
      // カスタムプロンプトで一般的な美容院会話を促す
      final customPrompt = '''
You are a customer at a beauty salon. Continue the natural conversation based on typical salon scenarios.

Current context: The user (salon staff) just said: "$userMessage"

Guidelines:
1. Respond as a realistic customer with genuine needs and concerns
2. You might ask about services, prices, availability, or recommendations
3. Express typical customer concerns (damage, style changes, maintenance, etc.)
4. React naturally to staff suggestions - sometimes interested, sometimes hesitant
5. Keep responses short and conversational (1-3 sentences)
6. Create opportunities for the staff to practice professional English
7. Be polite but natural, not overly formal

Always respond in JSON format:
{
  "response": "Your response as a customer",
  "feedback": {
    "grammar_errors": ["日本語での文法エラー説明"],
    "suggestions": ["日本語での改善提案"],
    "is_off_topic": false,
    "severity": "none"
  },
  "translation": "お客様としてのあなたの返答の日本語訳"
}

Important: All feedback must be in Japanese.
''';
      
      // AIの応答を取得（お客様として）
      final response = await _aiService.generateResponseWithFeedback(
        userInput: userMessage,
        conversationHistory: conversationHistory,
        targetPhrases: [],
        sessionNumber: 1,
        userLevel: 'intermediate',
        model: 'gpt-4o-mini',
        customPrompt: customPrompt,
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
            feedback: null,
            severity: 'none',
            isTemporary: false,
            isAnimating: true,
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
    }
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
          // タイマー表示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isTimeWarning ? Colors.orange.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer, 
                  size: 18,
                  color: isTimeWarning ? Colors.orange : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(remainingTime),
                  style: TextStyle(
                    color: isTimeWarning ? Colors.orange : Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // リセットボタン
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messageTranslationStates.clear();
                _evaluationResults['responseCount'] = 0;
                _evaluationResults['targetPhrasesUsed'] = 0;
                _isSessionEnded = false;
              });
              _startSessionTimer();
              _initializeConversation();
            },
            tooltip: '会話をリセット',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
      // セッション終了ボタン
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton.extended(
          onPressed: _elapsedSeconds < 10 
              ? null 
              : () => _endSession(),
          icon: const Icon(Icons.check),
          label: const Text(
            'セッション終了',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: _elapsedSeconds < 10
              ? Colors.grey.shade400
              : Colors.green,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }

  // メッセージバブルを構築
  Widget _buildMessageBubble(ConversationMessage message, int index) {
    final isUser = message.isUser;
    final hasFeedback = message.feedback != null && 
                        (message.feedback!.grammarErrors.isNotEmpty || 
                         message.feedback!.suggestions.isNotEmpty);
    final showTranslation = _messageTranslationStates[index] ?? false;
    
    return GestureDetector(
      onLongPress: isUser ? () => _showMessageOptions(index) : null,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // メッセージバブル
              Container(
                padding: const EdgeInsets.all(12),
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
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
                    if (!isUser && showTranslation && message.translation != null && message.translation!.isNotEmpty) ...[
                      const SizedBox(height: 8),
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
                    ],
                  ],
                ),
              ),
              
              // アクションボタン（AIメッセージのみ）
              if (!isUser) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 翻訳ボタン
                    if (message.translation != null && message.translation!.isNotEmpty)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _messageTranslationStates[index] = !showTranslation;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                showTranslation ? Icons.translate : Icons.translate_outlined,
                                size: 16,
                                color: showTranslation ? Colors.blue : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                showTranslation ? '翻訳を隠す' : '翻訳を表示',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: showTranslation ? Colors.blue : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              
              // フィードバックボタン（ユーザーメッセージのみ）
              if (isUser && hasFeedback) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _showFeedbackDialog(message),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.feedback, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        const Text(
                          'フィードバックを見る',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('メッセージを削除'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _messages.removeAt(index);
                  // 翻訳状態もクリア
                  _messageTranslationStates.remove(index);
                  // インデックスを調整
                  final newStates = <int, bool>{};
                  _messageTranslationStates.forEach((key, value) {
                    if (key > index) {
                      newStates[key - 1] = value;
                    } else if (key < index) {
                      newStates[key] = value;
                    }
                  });
                  _messageTranslationStates.clear();
                  _messageTranslationStates.addAll(newStates);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // フィードバックダイアログを表示
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
          const SizedBox(height: 8),
          
          // テキスト入力とボタン
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  enabled: !_isSessionEnded,
                  decoration: InputDecoration(
                    hintText: _isSessionEnded ? 'セッション終了' : '英語でメッセージを入力...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_isSessionEnded) ? null : (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              // 録音ボタン
              IconButton(
                onPressed: _isProcessing || _isAIThinking || _isSessionEnded
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
                onPressed: _isProcessing || _isAIThinking || _isSessionEnded ? null : _sendMessage,
                icon: const Icon(Icons.send),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
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
            _isSessionEnded = true;
          });
          // 強制的にセッション終了処理を実行
          _endSession();
        }
      }
    });
  }
  
  // 残り時間を計算
  int _getRemainingSeconds() {
    return (_sessionTimeLimit - _elapsedSeconds).clamp(0, _sessionTimeLimit);
  }
  
  // 時間をフォーマット
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  // セッション終了処理
  Future<void> _endSession() async {
    print('=== _endSession() called ===');
    
    // 既に処理中または終了済みの場合は何もしない
    if (_isProcessing || _isSessionEnded) {
      print('Session already ended or processing');
      return;
    }
    
    try {
      _timer?.cancel();
      
      setState(() {
        _isProcessing = true;
        _isSessionEnded = true;
      });
      
      // UIの更新を確実に反映させるために少し待機
      await Future.delayed(const Duration(milliseconds: 100));
      
      print('Preparing conversation history...');
      // 会話履歴を準備
      final conversationHistory = _messages
          .where((msg) => !msg.text.startsWith('[System:') && !msg.isTemporary)
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();
      
      print('Conversation history length: ${conversationHistory.length}');
      
      if (conversationHistory.isEmpty) {
        print('No conversation history, showing default feedback');
        await _showDefaultFeedback();
        return;
      }
      
      print('Generating session evaluation...');
      // 評価処理を別の isolate で実行するのではなく、compute を使用
      final SessionFeedback evaluation;
      try {
        evaluation = await _aiService.evaluateSession(
          conversationHistory: conversationHistory,
          targetPhrases: [], // 一般会話なのでターゲットフレーズなし
          sessionNumber: 1,
          timeSpent: _elapsedSeconds,
          userResponses: _evaluationResults['responseCount'] ?? 0,
          targetPhrasesUsed: 0,
        );
        
        print('Evaluation generated successfully');
        print('Overall score: ${evaluation.overallScore}');
      } catch (evaluationError) {
        print('Error during evaluation: $evaluationError');
        await _showDefaultFeedback();
        return;
      }
      
      // 処理完了後にUIを更新
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        // UIの更新を確実に反映させるために少し待機
        await Future.delayed(const Duration(milliseconds: 50));
        
        print('Showing session feedback dialog');
        await _showSessionFeedback(evaluation);
      } else {
        print('Widget not mounted, cannot show feedback');
      }
      
    } catch (e) {
      print('Error ending session: $e');
      print('Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        await _showDefaultFeedback();
      }
    }
  }
  
  // デフォルトフィードバックを表示
  Future<void> _showDefaultFeedback() async {
    print('Showing default feedback');
    final defaultFeedback = SessionFeedback(
      overallScore: 70,
      grammarScore: 70,
      fluencyScore: 70,
      relevanceScore: 70,
      feedback: 'お疲れ様でした！\n\n練習時間: ${_formatTime(_elapsedSeconds)}\n応答回数: ${_evaluationResults['responseCount'] ?? 0}回\n\n美容院での接客英語の練習を頑張りましたね。引き続き練習を続けて、より自然な会話ができるようになりましょう！',
    );
    
    if (mounted) {
      // 次のフレームで実行
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await _showSessionFeedback(defaultFeedback);
        }
      });
    }
  }
  
  // セッションフィードバックダイアログを表示
  Future<void> _showSessionFeedback(SessionFeedback feedback) async {
    print('=== _showSessionFeedback() called ===');
    print('Feedback text: ${feedback.feedback}');
    
    // ダイアログ表示前に少し待機してUIの安定化を図る
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) {
      print('Widget not mounted, cannot show dialog');
      return;
    }
    
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          print('Building feedback dialog');
          return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AI会話練習 完了！',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // スコア表示
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreItem('総合', feedback.overallScore),
                    _buildScoreItem('文法', feedback.grammarScore),
                    _buildScoreItem('流暢さ', feedback.fluencyScore),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 統計情報
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow('練習時間', _formatTime(_elapsedSeconds)),
                      _buildStatRow('応答回数', '${_evaluationResults['responseCount']}回'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // AIからのフィードバック
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.feedback, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'AIからのフィードバック',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          feedback.feedback,
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // アクションボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        if (mounted) {
                          setState(() {
                            _messages.clear();
                            _messageTranslationStates.clear();
                            _evaluationResults['responseCount'] = 0;
                            _evaluationResults['targetPhrasesUsed'] = 0;
                            _isSessionEnded = false;
                          });
                          _startSessionTimer();
                          _initializeConversation();
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('新しい会話を始める'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        print('Home button pressed');
                        Navigator.pop(dialogContext); // ダイアログを閉じる
                        Navigator.pop(context); // 会話画面を閉じる
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('ホームに戻る'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    } catch (e) {
      print('Error showing session feedback dialog: $e');
      // ダイアログ表示に失敗した場合、コンソールにフィードバックを出力
      print('Feedback would have been: ${feedback.feedback}');
      
      // フォールバック: シンプルなアラートダイアログを表示
      if (mounted) {
        try {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('セッション完了'),
              content: Text('練習時間: ${_formatTime(_elapsedSeconds)}\n\nお疲れ様でした！'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) {
                      setState(() {
                        _messages.clear();
                        _messageTranslationStates.clear();
                        _evaluationResults['responseCount'] = 0;
                        _evaluationResults['targetPhrasesUsed'] = 0;
                        _isSessionEnded = false;
                      });
                      _startSessionTimer();
                      _initializeConversation();
                    }
                  },
                  child: const Text('新しい会話'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('戻る'),
                ),
              ],
            ),
          );
        } catch (fallbackError) {
          print('Even fallback dialog failed: $fallbackError');
        }
      }
    }
  }
  
  Widget _buildScoreItem(String label, double score) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: score >= 80
                  ? [Colors.green.shade300, Colors.green.shade600]
                  : score >= 60
                      ? [Colors.orange.shade300, Colors.orange.shade600]
                      : [Colors.red.shade300, Colors.red.shade600],
            ),
          ),
          child: Center(
            child: Text(
              '${score.round()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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