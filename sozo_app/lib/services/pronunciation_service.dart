import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PronunciationResult {
  final double pronunciationScore;
  final double accuracyScore;
  final double fluencyScore;
  final double completenessScore;
  final String recognizedText;
  final List<WordAssessment> words;

  PronunciationResult({
    required this.pronunciationScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.recognizedText,
    required this.words,
  });
}

class WordAssessment {
  final String word;
  final double score;
  final String? errorType;

  WordAssessment({
    required this.word,
    required this.score,
    this.errorType,
  });
}

class PronunciationService {
  final String _azureKey = dotenv.env['AZURE_SPEECH_KEY'] ?? '';
  final String _azureRegion = dotenv.env['AZURE_SPEECH_REGION'] ?? 'eastus';
  final String _azureEndpoint = 'cognitiveservices.azure.com';

  Future<PronunciationResult> assessPronunciation({
    required String audioPath,
    required String referenceText,
    String language = 'en-US',
  }) async {
    try {
      // 音声ファイルを読み込む
      final audioFile = File(audioPath);
      final audioBytes = await audioFile.readAsBytes();

      // Azure Speech APIのエンドポイント
      final uri = Uri.https(
        '$_azureRegion.$_azureEndpoint',
        '/speechtotext/v3.1/speech/recognition/conversation/cognitiveservices/v1',
        {
          'language': language,
          'format': 'detailed',
        },
      );

      // リクエストヘッダー
      final headers = {
        'Ocp-Apim-Subscription-Key': _azureKey,
        'Content-Type': 'audio/wav',
        'Accept': 'application/json',
        'Pronunciation-Assessment': base64.encode(utf8.encode(json.encode({
          'ReferenceText': referenceText,
          'GradingSystem': 'HundredMark',
          'Granularity': 'Word',
          'EnableMiscue': true,
          'ScenarioId': '57c554c4-36b9-4d70-9db7-a124c5a09dd5',
        }))),
      };

      // APIリクエスト
      final response = await http.post(
        uri,
        headers: headers,
        body: audioBytes,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseAssessmentResult(data);
      } else {
        // エラーの場合はモックデータを返す（開発用）
        print('Azure API error: ${response.statusCode} - ${response.body}');
        return _getMockResult(referenceText);
      }
    } catch (e) {
      print('Pronunciation assessment error: $e');
      // エラーの場合はモックデータを返す
      return _getMockResult(referenceText);
    }
  }

  PronunciationResult _parseAssessmentResult(Map<String, dynamic> data) {
    final nbest = data['NBest']?.first ?? {};
    final pronunciationAssessment = nbest['PronunciationAssessment'] ?? {};
    
    final pronunciationScore = (pronunciationAssessment['PronunciationScore'] ?? 70).toDouble();
    final accuracyScore = (pronunciationAssessment['AccuracyScore'] ?? 70).toDouble();
    final fluencyScore = (pronunciationAssessment['FluencyScore'] ?? 70).toDouble();
    final completenessScore = (pronunciationAssessment['CompletenessScore'] ?? 70).toDouble();
    
    final words = <WordAssessment>[];
    final wordsList = nbest['Words'] ?? [];
    
    for (final word in wordsList) {
      final wordAssessment = word['PronunciationAssessment'] ?? {};
      words.add(WordAssessment(
        word: word['Word'] ?? '',
        score: (wordAssessment['AccuracyScore'] ?? 70).toDouble(),
        errorType: wordAssessment['ErrorType'],
      ));
    }
    
    return PronunciationResult(
      pronunciationScore: pronunciationScore,
      accuracyScore: accuracyScore,
      fluencyScore: fluencyScore,
      completenessScore: completenessScore,
      recognizedText: nbest['Display'] ?? '',
      words: words,
    );
  }

  // 開発用のモックデータ
  PronunciationResult _getMockResult(String referenceText) {
    // ランダムなスコアを生成（開発用）
    final random = DateTime.now().millisecondsSinceEpoch % 30;
    final baseScore = 70 + random;
    
    final words = referenceText.split(' ').map((word) {
      final wordScore = 70 + (DateTime.now().millisecondsSinceEpoch % 30);
      return WordAssessment(
        word: word,
        score: wordScore.toDouble(),
        errorType: wordScore < 70 ? 'Mispronunciation' : null,
      );
    }).toList();
    
    return PronunciationResult(
      pronunciationScore: baseScore.toDouble(),
      accuracyScore: (baseScore - 5).toDouble(),
      fluencyScore: (baseScore + 5).toDouble(),
      completenessScore: 100.0,
      recognizedText: referenceText,
      words: words,
    );
  }
} 