import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
      print('Environment loaded: ${dotenv.env.keys.length} keys found');
      print('Azure Speech Key exists: ${dotenv.env.containsKey('AZURE_SPEECH_KEY')}');
      print('Azure Speech Region exists: ${dotenv.env.containsKey('AZURE_SPEECH_REGION')}');
    } catch (e) {
      print('Environment file not found, using fallback values');
      // フォールバック値を設定
      dotenv.env['AZURE_SPEECH_KEY'] = '4f5c86fa8c1b4f1cbbddf8ba1e7b89a0';
      dotenv.env['AZURE_SPEECH_REGION'] = 'japaneast';
    }
  }
  
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get azureSpeechKey => dotenv.env['AZURE_SPEECH_KEY'] ?? '';
  static String get azureSpeechRegion => dotenv.env['AZURE_SPEECH_REGION'] ?? '';
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
} 