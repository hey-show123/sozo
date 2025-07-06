// キャラクターモデル - OpenAI TTSの音声モデルに対応
class CharacterModel {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final String voiceModel; // OpenAI TTSの音声モデル
  final String avatarImagePath;
  final String role;
  final Map<String, dynamic> personality;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.voiceModel,
    required this.avatarImagePath,
    required this.role,
    required this.personality,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String,
      voiceModel: json['voice_model'] as String,
      avatarImagePath: json['avatar_image_path'] as String,
      role: json['role'] as String,
      personality: json['personality'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'voice_model': voiceModel,
      'avatar_image_path': avatarImagePath,
      'role': role,
      'personality': personality,
    };
  }
}

// 利用可能なキャラクター一覧
class AvailableCharacters {
  static const List<CharacterModel> characters = [
    CharacterModel(
      id: 'sarah',
      name: 'Sarah',
      displayName: 'Sarah',
      description: '英語学習コーディネーター。温かみがあり、丁寧で親しみやすい。生徒一人ひとりに寄り添った指導を心がけています。',
      voiceModel: 'fable', // 温かみのあるプロフェッショナルな声
      avatarImagePath: 'assets/images/avatars/sarah.png',
      role: 'English Learning Coordinator',
      personality: {
        'friendliness': 9,
        'patience': 10,
        'professionalism': 9,
        'encouragement': 10,
        'warmth': 9,
      },
    ),
    CharacterModel(
      id: 'maya',
      name: 'Maya',
      displayName: 'Maya',
      description: 'フレンドリーで明るいアメリカ人女性。楽しく学習できる雰囲気を作るのが得意です。',
      voiceModel: 'nova', // 明るく親しみやすい声
      avatarImagePath: 'assets/images/avatars/maya.png',
      role: 'Conversation Partner',
      personality: {
        'friendliness': 10,
        'energy': 9,
        'humor': 8,
        'casualness': 8,
        'encouragement': 9,
      },
    ),
    CharacterModel(
      id: 'alex',
      name: 'Alex',
      displayName: 'Alex',
      description: '落ち着いた男性講師。論理的で分かりやすい説明が得意です。ビジネス英語も教えています。',
      voiceModel: 'echo', // 落ち着いた男性の声
      avatarImagePath: 'assets/images/avatars/alex.png',
      role: 'Business English Instructor',
      personality: {
        'professionalism': 10,
        'logic': 9,
        'patience': 8,
        'formality': 7,
        'reliability': 10,
      },
    ),
    CharacterModel(
      id: 'emma',
      name: 'Emma',
      displayName: 'Emma',
      description: '上品で丁寧なイギリス人女性。正確な発音と美しい英語を教えてくれます。',
      voiceModel: 'shimmer', // 上品で丁寧な女性の声
      avatarImagePath: 'assets/images/avatars/emma.png',
      role: 'Pronunciation Specialist',
      personality: {
        'elegance': 10,
        'precision': 9,
        'politeness': 10,
        'sophistication': 9,
        'attention_to_detail': 10,
      },
    ),
  ];

  // IDでキャラクターを取得
  static CharacterModel? getCharacterById(String id) {
    try {
      return characters.firstWhere((character) => character.id == id);
    } catch (e) {
      return null;
    }
  }

  // デフォルトキャラクター（Sarah）
  static CharacterModel get defaultCharacter => characters.first;
} 