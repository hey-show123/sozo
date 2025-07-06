import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class AIConversationService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  late final Dio _dio;
  
  AIConversationService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  /// AI会話セッションのためのシステムプロンプトを生成
  String generateSystemPrompt({
    required List<String> targetPhrases,
    required String lessonContext,
    required int sessionNumber,
    required String userLevel,
  }) {
    return '''
You are a helpful English conversation partner in a beauty salon setting. 
Your role is to naturally guide the user to practice these key phrases:
${targetPhrases.map((p) => '- "$p"').join('\n')}

Context: $lessonContext

This is conversation session #$sessionNumber out of 5. 
User level: $userLevel

Guidelines:
1. Create natural situations where the user would use these phrases
2. Be encouraging and patient
3. Provide gentle corrections when needed
4. Keep the conversation flowing naturally
5. Adjust difficulty based on session number (easier for session 1, harder for session 5)
6. Use simple English appropriate for the user's level
7. If the user struggles, provide hints or simpler alternatives
8. Praise the user when they use the target phrases correctly

Start with a greeting and a situation that would naturally lead to using one of the target phrases.
''';
  }

  /// AI会話の応答を生成
  Future<String> generateResponse({
    required List<Map<String, String>> conversationHistory,
    required List<String> targetPhrases,
    required String lessonContext,
    required int sessionNumber,
    required String userLevel,
    String model = 'gpt-4o-mini', // デフォルトモデル
  }) async {
    try {
      final systemPrompt = generateSystemPrompt(
        targetPhrases: targetPhrases,
        lessonContext: lessonContext,
        sessionNumber: sessionNumber,
        userLevel: userLevel,
      );

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...conversationHistory,
      ];

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model, // 指定されたモデルを使用
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate AI response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating AI response: $e');
      // フォールバック応答
      return _getFallbackResponse(sessionNumber);
    }
  }

  /// セッション開始時のAIメッセージを生成
  String getSessionStartMessage(int sessionNumber) {
    final starters = [
      "Hi! Welcome to our salon. I heard you're interested in our services. How can I help you today?",
      "Good morning! I see you're back. Are you thinking about trying something new with your hair today?",
      "Hello again! Last time you mentioned your hair felt a bit damaged. How has it been since then?",
      "Hi there! We have some new treatment options available. Would you like to hear about them?",
      "Welcome back! I remember you were considering some additional services. Have you made a decision?",
    ];
    
    return starters[sessionNumber - 1];
  }

  /// エラー時のフォールバック応答
  String _getFallbackResponse(int sessionNumber) {
    final responses = [
      "That's interesting! Would you like to know more about our treatment options?",
      "I understand. Our treatments can really help with that. Shall I explain the benefits?",
      "Great choice! Many of our customers love that service. Is there anything else you'd like to add?",
      "I see what you mean. Based on what you've told me, I think a treatment would be perfect for you.",
      "Excellent! You're really getting comfortable with these conversations. How do you feel about the services we discussed?",
    ];
    
    return responses[(sessionNumber - 1) % responses.length];
  }

  /// 会話の評価とフィードバックを生成
  Future<ConversationFeedback> evaluateConversation({
    required List<Map<String, String>> conversationHistory,
    required List<String> targetPhrases,
    required int sessionNumber,
  }) async {
    // ターゲットフレーズの使用をチェック
    int phrasesUsed = 0;
    final userMessages = conversationHistory
        .where((msg) => msg['role'] == 'user')
        .map((msg) => msg['content']?.toLowerCase() ?? '')
        .toList();

    for (final phrase in targetPhrases) {
      if (userMessages.any((msg) => msg.contains(phrase.toLowerCase()))) {
        phrasesUsed++;
      }
    }

    // スコア計算
    final phraseScore = (phrasesUsed / targetPhrases.length) * 100;
    final fluencyScore = _calculateFluencyScore(conversationHistory);
    final overallScore = (phraseScore + fluencyScore) / 2;

    // フィードバック生成
    String feedback;
    if (overallScore >= 80) {
      feedback = "Excellent work! You used the target phrases naturally and maintained good conversation flow.";
    } else if (overallScore >= 60) {
      feedback = "Good job! Try to use more of the target phrases in your next conversation.";
    } else {
      feedback = "Keep practicing! Focus on using the key phrases we learned in the lesson.";
    }

    return ConversationFeedback(
      overallScore: overallScore,
      phraseUsageScore: phraseScore,
      fluencyScore: fluencyScore,
      phrasesUsed: phrasesUsed,
      totalPhrases: targetPhrases.length,
      feedback: feedback,
      suggestions: _generateSuggestions(phrasesUsed, targetPhrases.length),
    );
  }

  double _calculateFluencyScore(List<Map<String, String>> history) {
    // 簡単な流暢さスコア計算（実際の実装ではより高度な分析を行う）
    final userMessages = history.where((msg) => msg['role'] == 'user').length;
    if (userMessages >= 5) return 90;
    if (userMessages >= 3) return 70;
    return 50;
  }

  List<String> _generateSuggestions(int phrasesUsed, int totalPhrases) {
    final suggestions = <String>[];
    
    if (phrasesUsed < totalPhrases) {
      suggestions.add("Try to use all the target phrases in your conversation");
    }
    
    suggestions.add("Practice pronunciation of difficult words");
    suggestions.add("Focus on natural conversation flow");
    
    return suggestions;
  }

  /// フィードバック付きの応答を生成
  Future<ConversationResponse> generateResponseWithFeedback({
    required String userInput,
    required List<Map<String, String>> conversationHistory,
    required List<String> targetPhrases,
    required int sessionNumber,
    required String userLevel,
    String model = 'gpt-4.1-mini',
  }) async {
    final systemPrompt = generateSystemPromptWithFeedback(
      targetPhrases: targetPhrases,
      sessionNumber: sessionNumber,
      userLevel: userLevel,
    );

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...conversationHistory,
      {'role': 'user', 'content': userInput},
    ];

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        print('AI Response: $content');
        
        // JSONレスポンスを解析
        try {
          final jsonResponse = json.decode(content);
          
          // フィードバックデータを作成
          final feedback = FeedbackData(
            grammarErrors: List<String>.from(jsonResponse['feedback']['grammar_errors'] ?? []),
            suggestions: List<String>.from(jsonResponse['feedback']['suggestions'] ?? []),
            isOffTopic: jsonResponse['feedback']['is_off_topic'] ?? false,
            severity: jsonResponse['feedback']['severity'] ?? 'none',
          );
          
          // 翻訳がない場合はデフォルトメッセージ
          final translation = jsonResponse['translation'] ?? 
                              '（翻訳: ${jsonResponse['response'] ?? content}）';
          
          return ConversationResponse(
            aiResponse: jsonResponse['response'] ?? content,
            feedback: feedback,
            translation: translation,
          );
        } catch (e) {
          print('Error parsing JSON response: $e');
          print('Raw content: $content');
          
          // JSONパースに失敗した場合のフォールバック
          return ConversationResponse(
            aiResponse: content,
            feedback: FeedbackData(
              grammarErrors: [],
              suggestions: [],
              isOffTopic: false,
              severity: 'none',
            ),
            translation: '（翻訳: $content）',
          );
        }
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating response: $e');
      rethrow;
    }
  }

  /// システムプロンプトを生成（フィードバック付き）
  String generateSystemPromptWithFeedback({
    required List<String> targetPhrases,
    required int sessionNumber,
    required String userLevel,
  }) {
    return '''
You are a customer visiting a beauty salon. You are here to practice English conversation with the salon staff (the user).
Your role is to act as a realistic customer who needs various beauty services.

Target phrases the user (salon staff) should practice:
${targetPhrases.map((p) => '- "$p"').join('\n')}

This is conversation session #$sessionNumber out of 5.
User (staff) level: $userLevel

Guidelines:
1. Act as a real customer with specific needs and preferences
2. Create situations where the staff would naturally use the target phrases
3. Show interest in treatments, ask about prices, express concerns about your hair/skin
4. React naturally to the staff's suggestions (sometimes accept, sometimes ask for more information)
5. Keep your responses short and natural (1-2 sentences)
6. Gradually increase complexity as sessions progress
7. If the staff struggles, give hints through your questions
8. Always respond in JSON format

Customer personality for this session:
- Session 1: First-time customer, curious but cautious
- Session 2: Regular customer with specific preferences
- Session 3: Customer with hair damage concerns
- Session 4: Customer interested in trying new services
- Session 5: Demanding customer with specific requests

Always respond in JSON format:
{
  "response": "Your response as a customer",
  "feedback": {
    "grammar_errors": ["error1", "error2"],
    "suggestions": ["suggestion1", "suggestion2"],
    "is_off_topic": false,
    "severity": "none" // none, minor, major
  },
  "translation": "お客様としてのあなたの返答の日本語訳"
}

Start by entering the salon and greeting the staff naturally.
''';
  }

  /// フォールバック翻訳
  String _getFallbackTranslation(int sessionNumber) {
    final translations = [
      "それは興味深いですね！トリートメントのオプションについてもっと知りたいですか？",
      "分かりました。私たちのトリートメントは本当に役立ちます。利点を説明しましょうか？",
      "素晴らしい選択です！多くのお客様がそのサービスを気に入っています。他に何か追加したいものはありますか？",
      "おっしゃることがよくわかります。お話しいただいたことから、トリートメントがぴったりだと思います。",
      "素晴らしい！これらの会話にとても慣れてきましたね。私たちが話し合ったサービスについてどう感じますか？",
    ];
    
    return translations[(sessionNumber - 1) % translations.length];
  }

  /// ユーザー入力の詳細なフィードバックを生成
  Future<DetailedFeedback> generateDetailedFeedback({
    required String userInput,
    required List<String> targetPhrases,
    required String expectedContext,
    String model = 'gpt-4o-mini', // デフォルトモデル
  }) async {
    try {
      final prompt = '''
Analyze the following user input in the context of an English conversation practice:

User input: "$userInput"
Target phrases to practice: ${targetPhrases.join(', ')}
Expected context: $expectedContext

Provide detailed feedback in JSON format:
{
  "grammar_analysis": {
    "errors": [
      {"error": "error description", "correction": "corrected version", "explanation": "why it's wrong"}
    ],
    "score": 0-100
  },
  "pronunciation_hints": ["hint1", "hint2"],
  "vocabulary_feedback": {
    "good_usage": ["word1", "word2"],
    "suggestions": ["better word choice 1", "better word choice 2"]
  },
  "fluency_score": 0-100,
  "relevance_score": 0-100,
  "overall_feedback": "Detailed feedback message",
  "encouragement": "Positive message"
}
''';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model, // 指定されたモデルを使用
          'messages': [
            {'role': 'system', 'content': 'You are an expert English teacher providing detailed feedback.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
          'max_tokens': 500,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = jsonDecode(data['choices'][0]['message']['content']);
        return DetailedFeedback.fromJson(content);
      } else {
        throw Exception('Failed to generate feedback');
      }
    } catch (e) {
      print('Error generating detailed feedback: $e');
      return DetailedFeedback.empty();
    }
  }

  /// セッション全体の評価を生成
  Future<SessionFeedback> evaluateSession({
    required List<Map<String, String>> conversationHistory,
    required List<String> targetPhrases,
    required int sessionNumber,
    required int timeSpent,
    required int userResponses,
    required int targetPhrasesUsed,
    String model = 'gpt-4.1-mini',
  }) async {
    final prompt = '''
Evaluate this English conversation practice session at a beauty salon.

Session #$sessionNumber
Time spent: ${timeSpent ~/ 60} minutes ${timeSpent % 60} seconds
User responses: $userResponses
Target phrases used: $targetPhrasesUsed out of ${targetPhrases.length}

Target phrases:
${targetPhrases.map((p) => '- "$p"').join('\n')}

Conversation history:
${conversationHistory.map((msg) => '${msg['role']}: ${msg['content']}').join('\n')}

Provide evaluation in JSON format:
{
  "overallScore": 0-100,
  "grammarScore": 0-100,
  "fluencyScore": 0-100,
  "relevanceScore": 0-100,
  "feedback": "Detailed feedback in Japanese about the session performance, what went well, what to improve"
}
''';

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model,
          'messages': [
            {'role': 'system', 'content': 'You are an English teacher evaluating a practice session.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        print('Session evaluation: $content');
        
        try {
          final jsonResponse = json.decode(content);
          
          return SessionFeedback(
            overallScore: (jsonResponse['overallScore'] ?? 70).toDouble(),
            grammarScore: (jsonResponse['grammarScore'] ?? 70).toDouble(),
            fluencyScore: (jsonResponse['fluencyScore'] ?? 70).toDouble(),
            relevanceScore: (jsonResponse['relevanceScore'] ?? 70).toDouble(),
            feedback: jsonResponse['feedback'] ?? 'よく頑張りました！次回も練習を続けましょう。',
          );
        } catch (e) {
          print('Error parsing session evaluation: $e');
          // フォールバック
          return SessionFeedback(
            overallScore: 75,
            grammarScore: 75,
            fluencyScore: 70,
            relevanceScore: 80,
            feedback: 'セッション$sessionNumberお疲れ様でした。ターゲットフレーズを$targetPhrasesUsed回使用できました。引き続き練習を頑張りましょう！',
          );
        }
      } else {
        throw Exception('Failed to evaluate session');
      }
    } catch (e) {
      print('Error evaluating session: $e');
      // エラー時のフォールバック
      return SessionFeedback(
        overallScore: 70,
        grammarScore: 70,
        fluencyScore: 70,
        relevanceScore: 70,
        feedback: 'セッションお疲れ様でした。次回も頑張りましょう！',
      );
    }
  }
}

class ConversationFeedback {
  final double overallScore;
  final double phraseUsageScore;
  final double fluencyScore;
  final int phrasesUsed;
  final int totalPhrases;
  final String feedback;
  final List<String> suggestions;

  ConversationFeedback({
    required this.overallScore,
    required this.phraseUsageScore,
    required this.fluencyScore,
    required this.phrasesUsed,
    required this.totalPhrases,
    required this.feedback,
    required this.suggestions,
  });
}

// データモデル
class ConversationResponse {
  final String aiResponse;
  final FeedbackData feedback;
  final String translation;

  ConversationResponse({
    required this.aiResponse,
    required this.feedback,
    required this.translation,
  });
}

class FeedbackData {
  final List<String> grammarErrors;
  final List<String> suggestions;
  final bool isOffTopic;
  final String severity;

  FeedbackData({
    required this.grammarErrors,
    required this.suggestions,
    required this.isOffTopic,
    required this.severity,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      grammarErrors: List<String>.from(json['grammar_errors'] ?? []),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      isOffTopic: json['is_off_topic'] ?? false,
      severity: json['severity'] ?? 'none',
    );
  }
}

class DetailedFeedback {
  final GrammarAnalysis grammarAnalysis;
  final List<String> pronunciationHints;
  final VocabularyFeedback vocabularyFeedback;
  final double fluencyScore;
  final double relevanceScore;
  final String overallFeedback;
  final String encouragement;

  DetailedFeedback({
    required this.grammarAnalysis,
    required this.pronunciationHints,
    required this.vocabularyFeedback,
    required this.fluencyScore,
    required this.relevanceScore,
    required this.overallFeedback,
    required this.encouragement,
  });

  factory DetailedFeedback.fromJson(Map<String, dynamic> json) {
    return DetailedFeedback(
      grammarAnalysis: GrammarAnalysis.fromJson(json['grammar_analysis']),
      pronunciationHints: List<String>.from(json['pronunciation_hints'] ?? []),
      vocabularyFeedback: VocabularyFeedback.fromJson(json['vocabulary_feedback']),
      fluencyScore: (json['fluency_score'] ?? 0).toDouble(),
      relevanceScore: (json['relevance_score'] ?? 0).toDouble(),
      overallFeedback: json['overall_feedback'] ?? '',
      encouragement: json['encouragement'] ?? '',
    );
  }

  factory DetailedFeedback.empty() {
    return DetailedFeedback(
      grammarAnalysis: GrammarAnalysis(errors: [], score: 70),
      pronunciationHints: [],
      vocabularyFeedback: VocabularyFeedback(goodUsage: [], suggestions: []),
      fluencyScore: 70,
      relevanceScore: 70,
      overallFeedback: 'Keep practicing!',
      encouragement: 'You\'re doing great!',
    );
  }
}

class GrammarAnalysis {
  final List<GrammarError> errors;
  final double score;

  GrammarAnalysis({required this.errors, required this.score});

  factory GrammarAnalysis.fromJson(Map<String, dynamic> json) {
    return GrammarAnalysis(
      errors: (json['errors'] as List)
          .map((e) => GrammarError.fromJson(e))
          .toList(),
      score: (json['score'] ?? 0).toDouble(),
    );
  }
}

class GrammarError {
  final String error;
  final String correction;
  final String explanation;

  GrammarError({
    required this.error,
    required this.correction,
    required this.explanation,
  });

  factory GrammarError.fromJson(Map<String, dynamic> json) {
    return GrammarError(
      error: json['error'] ?? '',
      correction: json['correction'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}

class VocabularyFeedback {
  final List<String> goodUsage;
  final List<String> suggestions;

  VocabularyFeedback({required this.goodUsage, required this.suggestions});

  factory VocabularyFeedback.fromJson(Map<String, dynamic> json) {
    return VocabularyFeedback(
      goodUsage: List<String>.from(json['good_usage'] ?? []),
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}

class SessionFeedback {
  final double overallScore;
  final double grammarScore;
  final double fluencyScore;
  final double relevanceScore;
  final String feedback;

  SessionFeedback({
    required this.overallScore,
    required this.grammarScore,
    required this.fluencyScore,
    required this.relevanceScore,
    required this.feedback,
  });
} 