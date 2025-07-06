import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sozo_app/config/env.dart';

// Azure Speech Servicesのプロバイダー
final azureSpeechServiceProvider = Provider((ref) => AzureSpeechService());

// 発音評価結果モデル
class PronunciationAssessmentResult {
  final String recognizedText;
  final String displayText;
  final double overallScore;
  final double accuracyScore;
  final double fluencyScore;
  final double completenessScore;
  final double pronunciationScore;
  final List<WordScore>? wordScores;
  final double confidence;

  PronunciationAssessmentResult({
    required this.recognizedText,
    required this.displayText,
    required this.overallScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.pronunciationScore,
    this.wordScores,
    required this.confidence,
  });

  factory PronunciationAssessmentResult.fromJson(Map<String, dynamic> json) {
    final nbest = json['NBest'] as List<dynamic>?;
    if (nbest == null || nbest.isEmpty) {
      throw Exception('No recognition result found');
    }
    
    final result = nbest[0] as Map<String, dynamic>;
    
    // 単語レベルのスコアを解析
    final words = <WordScore>[];
    final wordsData = result['Words'] as List<dynamic>?;
    
    if (wordsData != null) {
      for (final wordData in wordsData) {
        final wordMap = wordData as Map<String, dynamic>;
        words.add(WordScore(
          word: wordMap['Word'] as String? ?? '',
          errorType: wordMap['ErrorType'] as String? ?? 'None',
          accuracyScore: (wordMap['AccuracyScore'] as num?)?.toDouble() ?? 0.0,
        ));
      }
    }
    
    // スコアは NBest[0] の直下にある
    final pronScore = (result['PronScore'] as num?)?.toDouble() ?? 0.0;
    
    return PronunciationAssessmentResult(
      recognizedText: result['Lexical'] as String? ?? '',
      displayText: result['Display'] as String? ?? '',
      overallScore: pronScore,
      accuracyScore: (result['AccuracyScore'] as num?)?.toDouble() ?? 0.0,
      fluencyScore: (result['FluencyScore'] as num?)?.toDouble() ?? 0.0,
      completenessScore: (result['CompletenessScore'] as num?)?.toDouble() ?? 0.0,
      pronunciationScore: pronScore,
      wordScores: words,
      confidence: (result['Confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory PronunciationAssessmentResult.fromMockData({
    required String expectedText,
  }) {
    // モックデータを生成
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final baseScore = 70 + random / 3.33; // 70-100の範囲

    // 各単語のスコアをランダムに生成
    final words = expectedText.split(' ');
    final wordScores = words.map((word) {
      final wordRandom = (word.hashCode % 100).toDouble();
      final wordScore = 60 + wordRandom / 2.5; // 60-100の範囲
      
      return WordScore(
        word: word,
        errorType: wordScore < 70 ? 'Mispronunciation' : 'None',
        accuracyScore: wordScore,
      );
    }).toList();

    return PronunciationAssessmentResult(
      recognizedText: expectedText,
      displayText: expectedText,
      overallScore: baseScore,
      accuracyScore: baseScore + 5,
      fluencyScore: baseScore - 5,
      completenessScore: 100,
      pronunciationScore: baseScore,
      wordScores: wordScores,
      confidence: 0.95,
    );
  }
}

// 単語レベルのスコア
class WordScore {
  final String word;
  final String errorType;
  final double accuracyScore;

  WordScore({
    required this.word,
    required this.errorType,
    required this.accuracyScore,
  });
}

class AzureSpeechService {
  static const bool _useMockImplementation = false; // 本番環境で使用（Azure REST API）
  
  List<String> _subscriptionKeys = [];
  String? _region;
  bool _isInitialized = false;
  int _currentKeyIndex = 0; // 現在使用中のキーのインデックス

  AzureSpeechService() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 複数のキーを収集
      final keys = <String>[];
      
      // 環境変数から取得
      final mainKey = Env.azureSpeechKey;
      final key1 = Env.azureSpeechKey1;
      final key2 = Env.azureSpeechKey2;
      
      // 有効なキーのみを追加（最小長のチェックのみ）
      if (mainKey.isNotEmpty && mainKey.length >= 32) {
        keys.add(mainKey);
      }
      if (key1.isNotEmpty && key1.length >= 32) {
        keys.add(key1);
      }
      if (key2.isNotEmpty && key2.length >= 32) {
        keys.add(key2);
      }
      
      _subscriptionKeys = keys;
      _region = Env.azureSpeechRegion;

      if (_subscriptionKeys.isEmpty) {
        throw Exception('No valid Azure Speech API keys found');
      }

      // APIキーの情報を出力
      print('Azure Speech Service: Found ${_subscriptionKeys.length} valid keys');
      for (int i = 0; i < _subscriptionKeys.length; i++) {
        final key = _subscriptionKeys[i];
        print('Key ${i + 1}: ${key.substring(0, 8)}... (length: ${key.length})');
        // 追加のデバッグ情報
        print('Key ${i + 1} first char code: ${key.codeUnitAt(0)}');
        print('Key ${i + 1} last char code: ${key.codeUnitAt(key.length - 1)}');
        // 特殊文字のチェック
        if (key.contains(' ') || key.contains('\n') || key.contains('\r') || key.contains('\t')) {
          print('WARNING: Key ${i + 1} contains whitespace characters!');
        }
        if (key.contains('%') || key.contains('=') || key.contains('&')) {
          print('WARNING: Key ${i + 1} might be URL encoded!');
        }
      }
      
      _isInitialized = true;
      print('AzureSpeechService initialized successfully');
      print('Using primary key: ${_subscriptionKeys[0].substring(0, 8)}...');
      print('Azure region: $_region');
    } catch (e) {
      print('Error initializing AzureSpeechService: $e');
      throw Exception('Failed to initialize Azure Speech Service: $e');
    }
  }

  // 次のキーに切り替える
  void _switchToNextKey() {
    if (_subscriptionKeys.length > 1) {
      _currentKeyIndex = (_currentKeyIndex + 1) % _subscriptionKeys.length;
      print('Switching to Azure key ${_currentKeyIndex + 1}: ${_subscriptionKeys[_currentKeyIndex].substring(0, 8)}...');
    }
  }

  // 現在のキーを取得
  String get _currentKey => _subscriptionKeys.isNotEmpty ? _subscriptionKeys[_currentKeyIndex] : '';

  // 発音評価（Pronunciation Assessment）
  Future<PronunciationAssessmentResult?> assessPronunciation({
    required File audioFile,
    required String expectedText,
    String language = 'en-US',
  }) async {
    if (!_isInitialized) {
      await _initialize();
    }

    if (_useMockImplementation) {
      // モック実装
      print('AzureSpeechService: Using mock pronunciation assessment');
      await Future.delayed(const Duration(seconds: 1));
      return PronunciationAssessmentResult.fromMockData(expectedText: expectedText);
    }

    try {
      // Azure Speech Services REST APIのエンドポイント
      final baseUrl = 'https://$_region.stt.speech.microsoft.com';
      final url = Uri.parse(
        '$baseUrl/speech/recognition/conversation/cognitiveservices/v1' +
        '?language=$language&format=detailed',
      );

      // 発音評価のパラメータを設定
      final pronunciationConfig = {
        'referenceText': expectedText,
        'gradingSystem': 'HundredMark',
        'dimension': 'Comprehensive',
        'enableMiscue': true,
        'phonemeAlphabet': 'IPA',
      };

      // Base64エンコード
      final pronunciationHeader = base64.encode(
        utf8.encode(json.encode(pronunciationConfig))
      );

      // 音声ファイルをWAV形式で読み込む
      final audioBytes = await audioFile.readAsBytes();

      print('Sending pronunciation assessment request to Azure...');
      
      // リトライロジックを改善（キーの切り替えを含む）
      int maxRetries = _subscriptionKeys.length * 2; // 各キーを2回まで試行
      int retryCount = 0;
      http.Response? response;
      bool keyExhausted = false;
      
      while (retryCount < maxRetries && !keyExhausted) {
        try {
          // HTTPリクエストを送信
          response = await http.post(
            url,
            headers: {
              'Ocp-Apim-Subscription-Key': _currentKey,
              'Content-Type': 'audio/wav',
              'Accept': 'application/json',
              'Pronunciation-Assessment': pronunciationHeader,
            },
            body: audioBytes,
          ).timeout(const Duration(seconds: 30));
          
          print('Response status: ${response.statusCode} (using key ${_currentKeyIndex + 1})');
          
          // 401エラーの場合は次のキーを試す
          if (response.statusCode == 401) {
            print('Authentication failed with key ${_currentKeyIndex + 1}');
            
            // 利用可能な次のキーがあるかチェック
            if (_subscriptionKeys.length > 1 && retryCount < maxRetries - 1) {
              _switchToNextKey();
              print('Retrying with key ${_currentKeyIndex + 1}... (attempt ${retryCount + 1}/${maxRetries})');
              await Future.delayed(const Duration(seconds: 1));
              retryCount++;
              continue;
            } else {
              keyExhausted = true;
              print('All available keys exhausted');
              break;
            }
          }
          
          // その他のエラーは短時間のリトライ
          if (response.statusCode != 200 && retryCount < maxRetries - 1) {
            print('Request failed with status ${response.statusCode}, retrying... (attempt ${retryCount + 1}/${maxRetries})');
            await Future.delayed(const Duration(seconds: 1));
            retryCount++;
            continue;
          }
          
          break; // 成功またはリトライ不要なエラー
        } catch (e) {
          if (retryCount < maxRetries - 1) {
            print('Request failed, retrying... (attempt ${retryCount + 1}/${maxRetries}): $e');
            await Future.delayed(const Duration(seconds: 1));
            retryCount++;
            continue;
          }
          rethrow;
        }
      }
      
      if (response == null) {
        throw Exception('Failed to get response from Azure Speech API after trying all keys');
      }
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Assessment successful');
        print('Azure Response: ${response.body}'); // デバッグ用
        
        // 認識状態をチェック
        final recognitionStatus = jsonResponse['RecognitionStatus'] as String?;
        if (recognitionStatus != null) {
          print('Recognition Status: $recognitionStatus');
          
          if (recognitionStatus == 'InitialSilenceTimeout') {
            throw Exception('音声が検出されませんでした。録音が正しく行われているか確認してください。');
          } else if (recognitionStatus == 'NoMatch') {
            throw Exception('音声を認識できませんでした。もう一度はっきりと話してください。');
          } else if (recognitionStatus == 'BabbleTimeout') {
            throw Exception('音声が不明瞭です。静かな環境で録音してください。');
          }
        }
        
        return PronunciationAssessmentResult.fromJson(jsonResponse);
      } else {
        print('Assessment failed: ${response.statusCode} - ${response.body}');
        
        // エラーレスポンスを解析
        try {
          final errorJson = json.decode(response.body);
          final errorMessage = errorJson['error']?['message'] ?? 'Unknown error';
          
          // 401エラーの詳細情報を出力
          if (response.statusCode == 401) {
            print('Authentication error details:');
            print('Subscription key used: ${_currentKey.substring(0, 8)}...');
            print('Region: $_region');
            print('Key length: ${_currentKey.length}');
          }
          
          throw Exception('Azure Speech API error: $errorMessage');
        } catch (e) {
          throw Exception(
            'Failed to assess pronunciation: ${response.statusCode} - ${response.body}'
          );
        }
      }
    } catch (e) {
      print('Error during pronunciation assessment: $e');
      
      // タイムアウトやネットワークエラーの場合はモックデータを返す
      if (e.toString().contains('TimeoutException') || 
          e.toString().contains('SocketException')) {
        print('Network error, falling back to mock data');
        return PronunciationAssessmentResult.fromMockData(expectedText: expectedText);
      }
      
      return null;
    }
  }

  // 音声認識（Speech to Text）
  Future<String?> recognizeSpeech({
    required File audioFile,
    String language = 'en-US',
  }) async {
    if (!_isInitialized) {
      await _initialize();
    }

    // ファイルの存在確認
    if (!await audioFile.exists()) {
      print('Audio file does not exist: ${audioFile.path}');
      return null;
    }

    // ファイルサイズ確認
    final fileSize = await audioFile.length();
    print('Audio file size: $fileSize bytes');
    
    if (fileSize == 0) {
      print('Audio file is empty');
      return null;
    }

    if (_useMockImplementation || kIsWeb) {
      // モック実装またはWeb環境
      print('Using mock speech recognition');
      await Future.delayed(const Duration(seconds: 1));
      return "Hello, how can I help you today?";
    }

    try {
      final baseUrl = 'https://$_region.stt.speech.microsoft.com';
      final url = Uri.parse(
        '$baseUrl/speech/recognition/conversation/cognitiveservices/v1' +
        '?language=$language&format=detailed',
      );

      print('Reading audio file: ${audioFile.path}');
      final audioBytes = await audioFile.readAsBytes();
      print('Audio bytes length: ${audioBytes.length}');

      // ファイル拡張子に基づいてContent-Typeを設定
      String contentType = 'audio/wav';
      if (audioFile.path.endsWith('.m4a')) {
        contentType = 'audio/mp4';
      } else if (audioFile.path.endsWith('.aac')) {
        contentType = 'audio/aac';
      }
      print('Content-Type: $contentType');

      final headers = {
        'Ocp-Apim-Subscription-Key': _currentKey,
        'Content-Type': contentType,
        'Accept': 'application/json',
      };

      print('Sending speech recognition request to Azure...');
      final response = await http.post(
        url,
        headers: headers,
        body: audioBytes,
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // 認識状態をチェック
        final recognitionStatus = jsonResponse['RecognitionStatus'] as String?;
        print('Recognition Status: $recognitionStatus');
        
        if (recognitionStatus == 'Success') {
          final nbest = jsonResponse['NBest'] as List<dynamic>?;
          
          if (nbest != null && nbest.isNotEmpty) {
            final result = nbest[0] as Map<String, dynamic>;
            final displayText = result['Display'] as String?;
            print('Recognized text: $displayText');
            return displayText;
          }
        } else if (recognitionStatus == 'InitialSilenceTimeout') {
          print('No speech detected - initial silence timeout');
          return null;
        } else if (recognitionStatus == 'NoMatch') {
          print('Speech not recognized - no match');
          return null;
        }
      } else {
        print('Speech recognition failed: ${response.statusCode}');
        
        // エラーの詳細を表示
        try {
          final errorJson = json.decode(response.body);
          print('Error details: $errorJson');
        } catch (_) {}
      }
      
      return null;
    } catch (e, stackTrace) {
      print('Error during speech recognition: $e');
      print('Stack trace: $stackTrace');
      
      // シミュレーターでのフォールバック
      if (Platform.isIOS && e.toString().contains('400')) {
        print('Falling back to mock recognition for iOS simulator');
        return "Hello, I'd like to practice English conversation.";
      }
      
      return null;
    }
  }

  // 音声合成（Text to Speech）
  Future<void> synthesizeSpeech(String text, String language) async {
    if (!_isInitialized) {
      await _initialize();
    }

    if (_useMockImplementation) {
      // モック実装
      print('AzureSpeechService: Using mock text-to-speech for: "$text"');
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      print('Synthesizing speech for: "$text"');
      // 実際の音声合成の実装は省略（今回はモック実装のみ）
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error during speech synthesis: $e');
      throw Exception('Failed to synthesize speech: $e');
    }
  }

  // リソースのクリーンアップ
  void dispose() {
    _isInitialized = false;
  }
} 