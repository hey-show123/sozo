import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'openai_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AudioStorageService {
  final SupabaseClient _supabase;
  final OpenAIService _openAIService;
  static const String _bucketName = 'audio-files';
  static const String _keyPhrasesFolder = 'key-phrases';
  
  AudioStorageService({
    required SupabaseClient supabase,
    required OpenAIService openAIService,
  }) : _supabase = supabase,
       _openAIService = openAIService;

  // キーフレーズの音声URLを取得（なければ生成してアップロード）
  Future<String> getOrCreateKeyPhraseAudio({
    required String phrase,
    required String lessonId,
    String voice = 'fable', // 温かみのあるプロフェッショナルな声
    double speed = 0.95, // 少し速めでテンポよく
  }) async {
    try {
      // まずデータベースから既存のファイルをチェック
      final existingRecord = await _supabase
          .from('audio_files')
          .select()
          .eq('text', phrase)
          .eq('lesson_id', lessonId)
          .eq('voice', voice)
          .maybeSingle();
      
      if (existingRecord != null) {
        // 既存のファイルのURLを返す
        final url = _supabase.storage
            .from(_bucketName)
            .getPublicUrl(existingRecord['file_path']);
        return url;
      }
      
      // フレーズのハッシュを生成（ファイル名として使用）
      // モデル名も含めてハッシュを生成（異なるモデルで生成した音声を区別するため）
      final hashInput = '${phrase}_gpt4o_mini_tts_${voice}_${speed}';
      final phraseHash = _generateHash(hashInput);
      final fileName = '$_keyPhrasesFolder/$lessonId/${phraseHash}_${voice}_gpt4omini.mp3';
      
      // 音声を生成
      print('Generating speech for: $phrase');
      print('Model: gpt-4o-mini-tts, Voice: $voice, Speed: $speed');
      final audioData = await _openAIService.generateSpeech(
        text: phrase,
        voice: voice,
        speed: speed,
      );
      
      // Supabase Storageにアップロード
      print('Uploading audio file: $fileName');
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            fileName,
            audioData,
            fileOptions: const FileOptions(
              contentType: 'audio/mpeg',
              upsert: true,
            ),
          );
      
      // データベースにレコードを作成
      print('Creating database record');
      await _supabase.from('audio_files').insert({
        'text': phrase,
        'lesson_id': lessonId,
        'voice': voice,
        'file_path': fileName,
        'duration_seconds': null, // TODO: 音声の長さを計算
      });
      
      // 公開URLを取得
      final url = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fileName);
      
      print('Audio file created successfully: $url');
      return url;
    } catch (e) {
      print('Error creating audio file: $e');
      throw Exception('Failed to create audio file: $e');
    }
  }

  // ローカルキャッシュから音声を取得
  Future<File?> getCachedAudio(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _generateHash(url);
      final file = File('${directory.path}/audio_cache/$fileName.mp3');
      
      if (await file.exists()) {
        return file;
      }
      
      // キャッシュになければダウンロード
      final response = await _supabase.storage
          .from(_bucketName)
          .download(_getPathFromUrl(url));
      
      // ディレクトリを作成
      await file.parent.create(recursive: true);
      
      // ファイルに保存
      await file.writeAsBytes(response);
      
      return file;
    } catch (e) {
      print('Error getting cached audio: $e');
      return null;
    }
  }

  // バッチで複数の音声ファイルを事前生成
  Future<Map<String, String>> generateBatchAudio({
    required List<String> phrases,
    required String lessonId,
    String voice = 'nova',
    double speed = 0.9,
  }) async {
    final results = <String, String>{};
    
    for (final phrase in phrases) {
      try {
        final url = await getOrCreateKeyPhraseAudio(
          phrase: phrase,
          lessonId: lessonId,
          voice: voice,
          speed: speed,
        );
        results[phrase] = url;
      } catch (e) {
        print('Failed to generate audio for "$phrase": $e');
      }
    }
    
    return results;
  }

  // URLからパスを抽出
  String _getPathFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    // /storage/v1/object/public/audio-files/... から audio-files/... を取得
    final bucketIndex = segments.indexOf(_bucketName);
    if (bucketIndex >= 0 && bucketIndex < segments.length - 1) {
      return segments.sublist(bucketIndex + 1).join('/');
    }
    return segments.last;
  }

  // ハッシュ生成
  String _generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // 16文字に短縮
  }

  // キャッシュをクリア
  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/audio_cache');
      
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
} 