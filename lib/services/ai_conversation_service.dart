import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIConversationService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

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
  }) async {
    try {
      final systemPrompt = generateSystemPrompt(
        targetPhrases: targetPhrases,
        lessonContext: lessonContext,
        sessionNumber: sessionNumber,
        userLevel: userLevel,
      );

      // メッセージ履歴を構築
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
          'model': 'gpt-4o-mini',
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