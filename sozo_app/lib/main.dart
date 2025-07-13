import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:sozo_app/config/env.dart';
import 'package:sozo_app/config/temp_config.dart';
import 'package:sozo_app/core/router/app_router.dart';
import 'package:sozo_app/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';
import 'package:app_links/app_links.dart';

// バックグラウンドメッセージハンドラー
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

// グローバルなAppLinksインスタンス
late AppLinks _appLinks;

// ディープリンク処理をルーターに通知するためのNotifier
final deepLinkNotifier = ValueNotifier<Uri?>(null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // デバッグモードでのセマンティクス警告を抑制（オプション）
  // debugPrintMarkNeedsSemanticsUpdateStacks = false;
  
  try {
    await Env.load();
    print('Main: Environment loaded successfully');
  } catch (e) {
    print('Main: Environment file not found, using default values: $e');
  }
  print('Main: App starting...');
  
  // Firebaseの初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Main: Firebase initialized');
  
  // 日本語ロケールの初期化
  await initializeDateFormatting('ja');
  
  // バックグラウンドメッセージハンドラーの設定
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Supabaseの設定を明示的に指定（.envファイルのURLが間違っているため）
  final supabaseUrl = 'https://uwgxkekvpchqzvnylszl.supabase.co';
  final supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3Z3hrZWt2cGNocXp2bnlsc3psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4NDkyNzMsImV4cCI6MjA2NjQyNTI3M30.vjf738gcyGxL6iwq2oc0gREtEFlgnRylaxnuY-7FRH4';
  
  print('Using Supabase URL: $supabaseUrl');
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
      // セッションを自動的に永続化
      localStorage: null, // null = デフォルトのSharedPreferencesを使用
    ),
  );
  print('Main: Supabase initialized');
  
  // セッション状態を確認
  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    print('Main: Existing session found - user: ${session.user.email}');
  } else {
    print('Main: No existing session found');
  }
  
  // ディープリンクの初期化
  _appLinks = AppLinks();
  
  // 初期リンクの確認（アプリが終了状態から起動された場合）
  final initialLink = await _appLinks.getInitialLink();
  if (initialLink != null) {
    print('Main: Initial deep link: $initialLink');
    deepLinkNotifier.value = initialLink;
  }
  
  // ディープリンクのリスナーを設定（アプリが起動中の場合）
  _appLinks.uriLinkStream.listen((uri) {
    print('Main: Deep link received: $uri');
    deepLinkNotifier.value = uri;
  });
  
  // 開発時のみ: 音声キャッシュをクリア（新しいTTSモデルを使用するため）
  if (!kReleaseMode) {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/audio_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        print('Audio cache cleared - gpt-4o-mini-tts will be used for new audio');
      }
    } catch (e) {
      print('Failed to clear audio cache: $e');
    }
  }
  
  // 通知サービス初期化
  await NotificationService().initialize();
  
  runApp(
    const ProviderScope(
      child: SozoApp(),
    ),
  );
}

class SozoApp extends ConsumerWidget {
  const SozoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'SOZO',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
