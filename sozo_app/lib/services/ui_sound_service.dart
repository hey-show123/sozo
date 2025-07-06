import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// プロバイダー
final uiSoundServiceProvider = Provider<UISoundService>((ref) {
  return UISoundService();
});

class UISoundService {
  static const String _scissorsSound = 'assets/sounds/scissors1.mp3';
  
  // 効果音用の専用プレーヤー（複数の音を重ねて再生できるように）
  final Map<String, AudioPlayer> _soundPlayers = {};
  bool _isSoundEnabled = true;
  
  UISoundService() {
    // よく使う効果音は事前にロード
    _preloadSound(_scissorsSound);
  }
  
  // 効果音の事前ロード
  Future<void> _preloadSound(String assetPath) async {
    try {
      final player = AudioPlayer();
      await player.setAsset(assetPath);
      _soundPlayers[assetPath] = player;
    } catch (e) {
      print('Error preloading sound $assetPath: $e');
    }
  }
  
  // ボタンタップ音（ハサミの音）を再生
  Future<void> playButtonTap() async {
    if (!_isSoundEnabled) return;
    
    try {
      await _playSound(_scissorsSound);
    } catch (e) {
      // Web環境などで初回再生に失敗する場合があるため、エラーは静かに処理
      print('Sound playback failed (this is normal on first interaction): $e');
    }
  }
  
  // 成功音を再生（将来的に追加予定）
  Future<void> playSuccess() async {
    if (!_isSoundEnabled) return;
    // TODO: 成功音のアセットを追加したら実装
  }
  
  // エラー音を再生（将来的に追加予定）
  Future<void> playError() async {
    if (!_isSoundEnabled) return;
    // TODO: エラー音のアセットを追加したら実装
  }
  
  // 汎用的な効果音再生メソッド
  Future<void> _playSound(String assetPath) async {
    try {
      AudioPlayer? player = _soundPlayers[assetPath];
      
      if (player == null) {
        // まだロードされていない場合は新しいプレーヤーを作成
        player = AudioPlayer();
        await player.setAsset(assetPath);
        await player.setVolume(0.5); // 音量を50%に設定
        _soundPlayers[assetPath] = player;
      }
      
      // 再生位置をリセット
      await player.seek(Duration.zero);
      
      // プレーヤーの状態を確認してから再生
      final playerState = player.playerState;
      if (playerState.processingState != ProcessingState.idle) {
        await player.stop();
      }
      
      await player.play();
    } catch (e) {
      print('Error playing sound $assetPath: $e');
    }
  }
  
  // 効果音のON/OFF切り替え
  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }
  
  bool get isSoundEnabled => _isSoundEnabled;
  
  // リソースの解放
  void dispose() {
    for (final player in _soundPlayers.values) {
      player.dispose();
    }
    _soundPlayers.clear();
  }
} 