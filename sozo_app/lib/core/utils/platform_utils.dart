import 'package:flutter/foundation.dart';

class PlatformUtils {
  /// Webプラットフォームかどうかを判定
  static bool get isWeb => kIsWeb;
  
  /// モバイルプラットフォーム（iOS/Android）かどうかを判定
  static bool get isMobile => !kIsWeb;
  
  /// 録音機能が利用可能かどうかを判定
  static bool get isRecordingSupported => !kIsWeb;
  
  /// ファイルシステムアクセスが利用可能かどうかを判定
  static bool get isFileSystemSupported => !kIsWeb;
} 