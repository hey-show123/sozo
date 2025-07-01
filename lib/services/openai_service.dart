import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sozo_app/config/env.dart';

class OpenAIService {
  late final Dio _dio;
  late final String _apiKey;

  OpenAIService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  // 会話生成（GPT-4）
  Future<ConversationResponse> generateConversation({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
    required AIPersonality aiPersonality,
    List<String>? targetPhrases,
    String? lessonContext,
  }) async {
    try {
      // システムプロンプトの構築
      final systemPrompt = _buildSystemPrompt(aiPersonality, targetPhrases, lessonContext);
      
      // メッセージ履歴の構築
      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...conversationHistory.map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        }),
        {'role': 'user', 'content': userMessage},
      ];

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-4o', // 要件定義書ではGPT-4.1 nanoとなっていますが、現在利用可能なモデルを使用
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      
      return ConversationResponse(
        aiResponse: content,
        conversationFlowSuggestions: _extractSuggestions(content),
        difficultyAdjustment: _calculateDifficultyAdjustment(userMessage, content),
        topicsToExplore: _identifyTopics(content),
      );
    } catch (e) {
      print('OpenAI API error: $e');
      throw Exception('Failed to generate conversation: $e');
    }
  }

  // 音声合成（TTS）
  Future<Uint8List> generateSpeech({
    required String text,
    required String voice,
    double speed = 1.0,
    String model = 'tts-1', // デフォルトでTTS-1を使用
  }) async {
    try {
      // 感情表現を高めるためにテキストを調整
      String emotionalText = text;
      // 疑問文の場合は好奇心を込めた感じに
      if (text.contains('?')) {
        emotionalText = text;
      } 
      // 挨拶や提案の場合は元気よく
      else if (text.toLowerCase().contains('would you like') || 
               text.toLowerCase().contains('welcome') ||
               text.toLowerCase().contains('hello')) {
        emotionalText = text.replaceAll('.', '!');
      }
      // その他の文も少しテンション高めに
      else if (!text.endsWith('!')) {
        emotionalText = text.replaceAll('.', '!');
      }
      
      print('Generating speech with model: $model');
      print('Voice: $voice, Speed: $speed');
      print('Original text: $text');
      print('Emotional text: $emotionalText');
      
      final response = await _dio.post(
        '/audio/speech',
        data: {
          'model': model, // 引数で指定されたモデルを使用
          'input': emotionalText,
          'voice': voice,
          'speed': speed,
        },
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      return Uint8List.fromList(response.data);
    } catch (e) {
      print('OpenAI TTS error: $e');
      throw Exception('Failed to generate speech: $e');
    }
  }

  // プロンプト構築（AIパーソナリティに基づく）
  String _buildSystemPrompt(
    AIPersonality personality,
    List<String>? targetPhrases,
    String? lessonContext,
  ) {
    final traits = personality.personalityTraits;
    final style = personality.conversationStyle;
    
    String prompt = '''
You are ${personality.displayName}, ${personality.description}.

Your personality traits:
- Friendliness: ${traits['friendliness']}/10
- Patience: ${traits['patience']}/10
- Humor: ${traits['humor']}/10
- Formality: ${traits['formality']}/10
- Encouragement: ${traits['encouragement']}/10

Conversation style:
- Question frequency: ${style['question_frequency']}/10
- Topic diversity: ${style['topic_diversity']}/10
- Correction approach: ${style['correction_approach']}
- Adapt complexity to user level: ${style['complexity_adaptation']}

You are helping a Japanese learner practice English conversation.
''';

    if (targetPhrases != null && targetPhrases.isNotEmpty) {
      prompt += '\n\nTarget phrases to naturally incorporate:\n';
      for (final phrase in targetPhrases) {
        prompt += '- "$phrase"\n';
      }
      prompt += '\nGuide the conversation to create opportunities for the learner to use these phrases naturally.';
    }

    if (lessonContext != null) {
      prompt += '\n\nLesson context: $lessonContext';
    }

    prompt += '''

Guidelines:
1. Speak naturally but clearly
2. ${style['correction_approach'] == 'gentle' ? 'Gently correct mistakes after the learner finishes speaking' : style['correction_approach'] == 'direct' ? 'Directly correct mistakes as they occur' : 'Note mistakes but correct them later in the conversation'}
3. Encourage the learner with positive feedback
4. Ask follow-up questions to keep the conversation flowing
5. Adjust your language complexity based on the learner's responses
''';

    return prompt;
  }

  // 会話提案の抽出
  List<String> _extractSuggestions(String aiResponse) {
    // AI応答から質問や話題転換ポイントを抽出
    final suggestions = <String>[];
    
    if (aiResponse.contains('?')) {
      suggestions.add('Answer the question asked');
    }
    
    if (aiResponse.toLowerCase().contains('tell me') || 
        aiResponse.toLowerCase().contains('how about')) {
      suggestions.add('Share your experience or opinion');
    }
    
    return suggestions;
  }

  // 難易度調整の計算
  double _calculateDifficultyAdjustment(String userMessage, String aiResponse) {
    // ユーザーの発話の複雑さに基づいて難易度を調整
    final userWordCount = userMessage.split(' ').length;
    final aiWordCount = aiResponse.split(' ').length;
    
    if (userWordCount < 5) {
      return -0.1; // 簡単にする
    } else if (userWordCount > 20) {
      return 0.1; // 難しくする
    }
    
    return 0.0;
  }

  // 話題の特定
  List<String> _identifyTopics(String content) {
    final topics = <String>[];
    final contentLower = content.toLowerCase();
    
    // ヘアケア関連
    if (contentLower.contains('cut') || contentLower.contains('hair') || 
        contentLower.contains('treatment') || contentLower.contains('shampoo')) {
      topics.add('haircare');
    }
    
    // メイクアップ関連
    if (contentLower.contains('makeup') || contentLower.contains('cosmetic') ||
        contentLower.contains('skin') || contentLower.contains('foundation')) {
      topics.add('makeup');
    }
    
    // ネイル関連
    if (contentLower.contains('nail') || contentLower.contains('manicure') ||
        contentLower.contains('polish')) {
      topics.add('nail');
    }
    
    // エステ関連
    if (contentLower.contains('facial') || contentLower.contains('massage') ||
        contentLower.contains('spa') || contentLower.contains('relaxation')) {
      topics.add('esthetics');
    }
    
    // カラーリング関連
    if (contentLower.contains('color') || contentLower.contains('dye') ||
        contentLower.contains('bleach') || contentLower.contains('highlight')) {
      topics.add('coloring');
    }
    
    return topics;
  }

  // チャット応答を生成
  Future<String> generateChatResponse({
    required List<Map<String, String>> messages,
    required String systemPrompt,
  }) async {
    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Env.openAiApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4-turbo-preview',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...messages,
          ],
          'temperature': 0.8,
          'max_tokens': 500,
        },
      );

      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      throw Exception('Failed to generate chat response: $e');
    }
  }
}

// データモデル
class ConversationResponse {
  final String aiResponse;
  final List<String> conversationFlowSuggestions;
  final double difficultyAdjustment;
  final List<String> topicsToExplore;
  final List<String>? educationalNotes;

  ConversationResponse({
    required this.aiResponse,
    required this.conversationFlowSuggestions,
    required this.difficultyAdjustment,
    required this.topicsToExplore,
    this.educationalNotes,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AIPersonality {
  final String id;
  final String displayName;
  final String description;
  final Map<String, dynamic> personalityTraits;
  final Map<String, dynamic> conversationStyle;
  final String voiceId;

  AIPersonality({
    required this.id,
    required this.displayName,
    required this.description,
    required this.personalityTraits,
    required this.conversationStyle,
    required this.voiceId,
  });
} 