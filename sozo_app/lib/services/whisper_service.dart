import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WhisperService {
  late final Dio _dio;
  late final String _apiKey;

  WhisperService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  /// 音声ファイルをWhisperで文字起こし
  Future<String?> transcribeAudio({
    required File audioFile,
    String? language,
    String? prompt,
  }) async {
    try {
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

      // 25MB以下であることを確認（Whisper APIの制限）
      if (fileSize > 25 * 1024 * 1024) {
        print('Audio file is too large (max 25MB)');
        return null;
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: 'audio.wav',
        ),
        'model': 'whisper-1',
        if (language != null) 'language': language,
        if (prompt != null) 'prompt': prompt,
      });

      print('Sending transcription request to OpenAI Whisper...');
      
      final response = await _dio.post(
        '/audio/transcriptions',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
          },
        ),
      );

      print('Transcription response: ${response.data}');
      
      if (response.statusCode == 200) {
        final text = response.data['text'] as String?;
        return text?.trim();
      } else {
        print('Transcription failed: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio error during transcription: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
      }
      return null;
    } catch (e) {
      print('Error during audio transcription: $e');
      return null;
    }
  }

  /// 音声ファイルを翻訳（英語へ）
  Future<String> translateAudio({
    required File audioFile,
    String? prompt,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: 'audio.wav',
        ),
        'model': 'whisper-1',
        if (prompt != null) 'prompt': prompt,
      });

      final response = await _dio.post(
        '/audio/translations',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['text'] ?? '';
      } else {
        throw Exception('Whisper API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error translating audio: $e');
      rethrow;
    }
  }
} 