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
    "grammar_errors": ["日本語での文法エラー説明1", "日本語での文法エラー説明2"],
    "suggestions": ["日本語での改善提案1", "日本語での改善提案2"],
    "is_off_topic": false,
    "severity": "none" // none, minor, major
  },
  "translation": "お客様としてのあなたの返答の日本語訳"
}

重要：feedback内のgrammar_errorsとsuggestionsは必ず日本語で記述してください。

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
美容室での英会話練習セッションを評価してください。

セッション番号: $sessionNumber
練習時間: ${timeSpent ~/ 60}分${timeSpent % 60}秒
ユーザーの応答回数: $userResponses回
使用されたターゲットフレーズ: $targetPhrasesUsed個（全${targetPhrases.length}個中）

ターゲットフレーズ:
${targetPhrases.map((p) => '- "$p"').join('\n')}

会話履歴:
${conversationHistory.map((msg) => '${msg['role']}: ${msg['content']}').join('\n')}

以下のJSON形式で詳細な評価を提供してください：
{
  "overallScore": 0-100（総合スコア）,
  "grammarScore": 0-100（文法スコア）,
  "fluencyScore": 0-100（流暢さスコア）,
  "relevanceScore": 0-100（関連性スコア）,
  "feedback": "日本語での詳細なフィードバック。必ず以下の要素を含めてください：
    1. 良かった点（具体的な例を挙げて）
    2. 改善が必要な点（具体的な例と改善方法）
    3. ターゲットフレーズの使用状況の評価
    4. 会話の自然さについてのコメント
    5. 次回の練習へのアドバイス
    
    フィードバックは建設的で励みになるようなトーンで、最低200文字以上で書いてください。"
}

重要：feedbackは必ず日本語で書いてください。
''';

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model,
          'messages': [
            {
              'role': 'system', 
              'content': '''あなたは優秀な英語教師です。生徒の英会話練習を評価し、
詳細で建設的なフィードバックを日本語で提供します。
生徒のモチベーションを高めながら、具体的な改善点を示してください。'''
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 800,
          'response_format': {'type': 'json_object'},
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        print('Session evaluation: $content');
        
        try {
          final jsonResponse = json.decode(content);
          
          // スコアの検証と調整
          double overallScore = (jsonResponse['overallScore'] ?? 70).toDouble();
          double grammarScore = (jsonResponse['grammarScore'] ?? 70).toDouble();
          double fluencyScore = (jsonResponse['fluencyScore'] ?? 70).toDouble();
          double relevanceScore = (jsonResponse['relevanceScore'] ?? 70).toDouble();
          
          // フィードバックの検証
          String feedback = jsonResponse['feedback'] ?? '';
          
          // フィードバックが短すぎる場合は追加のフィードバックを生成
          if (feedback.length < 100) {
            feedback = _generateDetailedFeedback(
              sessionNumber: sessionNumber,
              targetPhrasesUsed: targetPhrasesUsed,
              totalPhrases: targetPhrases.length,
              timeSpent: timeSpent,
              overallScore: overallScore,
            );
          }
          
          return SessionFeedback(
            overallScore: overallScore,
            grammarScore: grammarScore,
            fluencyScore: fluencyScore,
            relevanceScore: relevanceScore,
            feedback: feedback,
          );
        } catch (e) {
          print('Error parsing session evaluation: $e');
          // フォールバック - より詳細なフィードバック
          return _generateFallbackFeedback(
            sessionNumber: sessionNumber,
            targetPhrasesUsed: targetPhrasesUsed,
            totalPhrases: targetPhrases.length,
            timeSpent: timeSpent,
          );
        }
      } else {
        throw Exception('Failed to evaluate session');
      }
    } catch (e) {
      print('Error evaluating session: $e');
      // エラー時の詳細なフォールバック
      return _generateFallbackFeedback(
        sessionNumber: sessionNumber,
        targetPhrasesUsed: targetPhrasesUsed,
        totalPhrases: targetPhrases.length,
        timeSpent: timeSpent,
      );
    }
  }
  
  /// 詳細なフィードバックを生成するヘルパーメソッド
  String _generateDetailedFeedback({
    required int sessionNumber,
    required int targetPhrasesUsed,
    required int totalPhrases,
    required int timeSpent,
    required double overallScore,
  }) {
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;
    final phraseUsageRate = (targetPhrasesUsed / totalPhrases * 100).round();
    
    String feedback = 'セッション${sessionNumber}お疲れ様でした！\n\n';
    
    // 良かった点
    feedback += '【良かった点】\n';
    if (overallScore >= 80) {
      feedback += '• 素晴らしいパフォーマンスでした！自然な会話ができています。\n';
    } else if (overallScore >= 60) {
      feedback += '• 基本的な会話の流れは良くできています。\n';
    }
    
    if (targetPhrasesUsed > 0) {
      feedback += '• ターゲットフレーズを${targetPhrasesUsed}回使用できました（使用率：${phraseUsageRate}%）。\n';
    }
    
    if (minutes >= 3) {
      feedback += '• ${minutes}分${seconds}秒間、しっかりと練習に取り組みました。\n';
    }
    
    feedback += '\n【改善点とアドバイス】\n';
    
    // ターゲットフレーズの使用について
    if (phraseUsageRate < 50) {
      feedback += '• ターゲットフレーズをもっと積極的に使ってみましょう。お客様の質問に対して、学習したフレーズを自然に組み込む練習をしてください。\n';
    } else if (phraseUsageRate < 80) {
      feedback += '• ターゲットフレーズの使用は良好ですが、まだ使っていないフレーズにも挑戦してみてください。\n';
    }
    
    // スコアに基づく具体的なアドバイス
    if (overallScore < 60) {
      feedback += '• 会話の流れをより自然にするため、相手の発言をよく聞いて適切に応答する練習をしましょう。\n';
      feedback += '• 基本的な接客フレーズを復習して、自信を持って使えるようにしましょう。\n';
    } else if (overallScore < 80) {
      feedback += '• より流暢な会話を目指して、考えずに自然に返答できるよう練習を続けましょう。\n';
    }
    
    // 次回への励まし
    feedback += '\n【次回の練習へ向けて】\n';
    feedback += '• 今回学んだことを活かして、次のセッションではさらに自然な会話を目指しましょう。\n';
    feedback += '• 特に「Would you like...?」のパターンは接客でよく使うので、マスターすると大きな武器になります。\n';
    
    if (sessionNumber < 3) {
      feedback += '• まだ練習の序盤です。焦らず着実にスキルアップしていきましょう！';
    } else {
      feedback += '• 練習も後半に入りました。これまでの成長を実感しながら、さらなる向上を目指しましょう！';
    }
    
    return feedback;
  }
  
  /// フォールバック用の詳細なフィードバックを生成
  SessionFeedback _generateFallbackFeedback({
    required int sessionNumber,
    required int targetPhrasesUsed,
    required int totalPhrases,
    required int timeSpent,
  }) {
    // 基本的なスコア計算
    final phraseScore = targetPhrasesUsed > 0 ? (targetPhrasesUsed / totalPhrases * 100).clamp(0, 100).toDouble() : 40.0;
    final timeScore = timeSpent >= 180 ? 80.0 : (timeSpent / 180 * 80).clamp(0, 80).toDouble();
    final overallScore = ((phraseScore + timeScore) / 2).clamp(0, 100).toDouble();
    
    final feedback = _generateDetailedFeedback(
      sessionNumber: sessionNumber,
      targetPhrasesUsed: targetPhrasesUsed,
      totalPhrases: totalPhrases,
      timeSpent: timeSpent,
      overallScore: overallScore,
    );
    
    return SessionFeedback(
      overallScore: overallScore,
      grammarScore: overallScore * 0.9, // 推定値
      fluencyScore: overallScore * 0.85, // 推定値
      relevanceScore: overallScore * 0.95, // 推定値
      feedback: feedback,
    );
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