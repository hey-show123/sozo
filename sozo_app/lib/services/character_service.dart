import '../data/models/character_model.dart';

class CharacterService {
  // キャラクターIDからキャラクター情報を取得
  static CharacterModel? getCharacter(String characterId) {
    return AvailableCharacters.getCharacterById(characterId);
  }

  // キャラクターIDからアバター画像パスを取得
  static String getAvatarImagePath(String characterId) {
    final character = getCharacter(characterId);
    return character?.avatarImagePath ?? AvailableCharacters.defaultCharacter.avatarImagePath;
  }

  // キャラクターIDから音声モデルを取得
  static String getVoiceModel(String characterId) {
    final character = getCharacter(characterId);
    return character?.voiceModel ?? AvailableCharacters.defaultCharacter.voiceModel;
  }

  // キャラクターIDから表示名を取得
  static String getDisplayName(String characterId) {
    final character = getCharacter(characterId);
    return character?.displayName ?? AvailableCharacters.defaultCharacter.displayName;
  }

  // キャラクターIDから説明を取得
  static String getDescription(String characterId) {
    final character = getCharacter(characterId);
    return character?.description ?? AvailableCharacters.defaultCharacter.description;
  }

  // 利用可能な全キャラクターを取得
  static List<CharacterModel> getAllCharacters() {
    return AvailableCharacters.characters;
  }

  // デフォルトキャラクターを取得
  static CharacterModel getDefaultCharacter() {
    return AvailableCharacters.defaultCharacter;
  }
} 