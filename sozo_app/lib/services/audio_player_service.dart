import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'dart:typed_data';
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
  
  // 音声URLを再生して完了を待つ
  Future<void> playAudioFromUrlAndWait(String url) async {
    try {
      print('Playing audio from URL and waiting: $url');
      
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
      
      // 再生完了を待つ
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
      
      print('Audio playback completed');
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

  // アセットから音声を再生
  Future<void> playAssetAudio(String assetPath) async {
    try {
      print('Playing audio from asset: $assetPath');
      
      // アセットから音声を再生
      await _audioPlayer.setAsset('assets/$assetPath');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing asset audio: $e');
      throw Exception('Failed to play asset audio: $e');
    }
  }

  // 一時的な音声データを再生（会話応答など）
  Future<void> playAudioData(List<int> audioData) async {
    File? tempFile;
    Directory? tempDir;
    
    try {
      // メモリから直接再生する方法を実装
      // just_audioパッケージの制限により、一時ファイルを作成
      tempDir = await Directory.systemTemp.createTemp('audio');
      tempFile = File('${tempDir.path}/temp_audio.mp3');
      await tempFile.writeAsBytes(audioData);
      
      await _audioPlayer.setFilePath(tempFile.path);
      await _audioPlayer.play();
      
      // 再生完了を待つ
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
    } catch (e) {
      print('Error playing audio data: $e');
    } finally {
      // 一時ファイルをクリーンアップ
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
        if (tempDir != null && await tempDir.exists()) {
          await tempDir.delete();
        }
      } catch (e) {
        // クリーンアップエラーは無視（ファイルが既に削除されている場合など）
        print('Cleanup error (ignored): $e');
      }
    }
  }

  // バイトデータから音声を再生（Uint8List版）
  Future<void> playFromBytes(Uint8List audioData) async {
    try {
      // playAudioDataに委譲
      await playAudioData(audioData.toList());
    } catch (e) {
      print('Error playing audio from bytes: $e');
      throw Exception('Failed to play audio from bytes: $e');
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