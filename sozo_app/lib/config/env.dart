import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
    print('Environment loaded: ${dotenv.env.keys.length} keys found');
    print('Azure Speech Key exists: ${dotenv.env.containsKey('AZURE_SPEECH_KEY')}');
    print('Azure Speech Key 1 exists: ${dotenv.env.containsKey('AZURE_SPEECH_KEY_1')}');
    print('Azure Speech Key 2 exists: ${dotenv.env.containsKey('AZURE_SPEECH_KEY_2')}');
    print('Azure Speech Region exists: ${dotenv.env.containsKey('AZURE_SPEECH_REGION')}');
    
    // APIキーの長さを確認（デバッグ用）
    final azureKey = dotenv.env['AZURE_SPEECH_KEY'] ?? '';
    final azureKey1 = dotenv.env['AZURE_SPEECH_KEY_1'] ?? '';
    final azureKey2 = dotenv.env['AZURE_SPEECH_KEY_2'] ?? '';
    
    if (azureKey.isNotEmpty) {
      print('Azure Speech Key loaded: ${azureKey.substring(0, 8)}...');
      print('Azure Speech Key length: ${azureKey.length}');
      // 余分な文字がないか確認
      if (azureKey != azureKey.trim()) {
        print('Warning: Azure Speech Key contains whitespace characters');
      }
    }
    
    if (azureKey1.isNotEmpty) {
      print('Azure Speech Key 1 loaded: ${azureKey1.substring(0, 8)}...');
      print('Azure Speech Key 1 length: ${azureKey1.length}');
    }
    
    if (azureKey2.isNotEmpty) {
      print('Azure Speech Key 2 loaded: ${azureKey2.substring(0, 8)}...');
      print('Azure Speech Key 2 length: ${azureKey2.length}');
    }
    
    if (azureKey.isEmpty && azureKey1.isEmpty && azureKey2.isEmpty) {
      // .envファイルが必須であることを明確にする
      throw Exception('Failed to load .env file. Please ensure .env file exists in the project root.');
    }
  }
  
  static String get supabaseUrl => (dotenv.env['SUPABASE_URL'] ?? '').trim();
  static String get supabaseAnonKey => (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();
  static String get azureSpeechKey => (dotenv.env['AZURE_SPEECH_KEY'] ?? '').trim();
  static String get azureSpeechKey1 => (dotenv.env['AZURE_SPEECH_KEY_1'] ?? '').trim();
  static String get azureSpeechKey2 => (dotenv.env['AZURE_SPEECH_KEY_2'] ?? '').trim();
  static String get azureSpeechRegion => (dotenv.env['AZURE_SPEECH_REGION'] ?? '').trim();
  static String get openAiApiKey => (dotenv.env['OPENAI_API_KEY'] ?? '').trim();
} 