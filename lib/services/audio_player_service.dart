import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'audio_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/auth_provider.dart';
import 'openai_service.dart';

// プロバイダー
final audioStorageServiceProvider = Provider<AudioStorageService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final openAIService = OpenAIService();
  return AudioStorageService(
    supabase: supabase,
    openAIService: openAIService,
  );
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final audioStorage = ref.watch(audioStorageServiceProvider);
  return AudioPlayerService(audioStorage: audioStorage);
});

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioStorageService _audioStorage;
  
  AudioPlayerService({required AudioStorageService audioStorage})
      : _audioStorage = audioStorage;

  // 音声URLを再生（キャッシュ機能付き）
  Future<void> playAudioFromUrl(String url) async {
    try {
      print('Playing audio from URL: $url');
      
      // ローカルキャッシュから取得
      final cachedFile = await _audioStorage.getCachedAudio(url);
      
      if (cachedFile != null && await cachedFile.exists()) {
        // キャッシュから再生
        print('Playing from cache: ${cachedFile.path}');
        await _audioPlayer.setFilePath(cachedFile.path);
      } else {
        // URLから直接再生
        print('Playing from URL (not cached)');
        await _audioPlayer.setUrl(url);
      }
      
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
      throw Exception('Failed to play audio: $e');
    }
  }

  // キーフレーズの音声を再生（自動生成・キャッシュ）
  Future<void> playKeyPhrase({
    required String phrase,
    required String lessonId,
    String? audioUrl,
  }) async {
    try {
      if (audioUrl != null && audioUrl.isNotEmpty) {
        // 既存の音声URLがある場合はそれを使用
        await playAudioFromUrl(audioUrl);
      } else {
        // なければ生成してから再生
        final url = await _audioStorage.getOrCreateKeyPhraseAudio(
          phrase: phrase,
          lessonId: lessonId,
        );
        await playAudioFromUrl(url);
      }
    } catch (e) {
      print('Error playing key phrase: $e');
      throw Exception('Failed to play key phrase: $e');
    }
  }

  // 一時的な音声データを再生（会話応答など）
  Future<void> playAudioData(List<int> audioData) async {
    try {
      // メモリから直接再生する方法を実装
      // just_audioパッケージの制限により、一時ファイルを作成
      final tempDir = await Directory.systemTemp.createTemp('audio');
      final tempFile = File('${tempDir.path}/temp_audio.mp3');
      await tempFile.writeAsBytes(audioData);
      
      await _audioPlayer.setFilePath(tempFile.path);
      await _audioPlayer.play();
      
      // 再生完了後に一時ファイルを削除
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          tempFile.delete();
          tempDir.delete();
        }
      });
    } catch (e) {
      print('Error playing audio data: $e');
      throw Exception('Failed to play audio data: $e');
    }
  }

  // 再生を停止
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // 一時停止
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // 再開
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  // 音量調整
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // リソースの解放
  void dispose() {
    _audioPlayer.dispose();
  }
} 