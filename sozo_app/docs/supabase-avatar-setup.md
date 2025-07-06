# Supabase Avatar Management Setup Guide

## 概要
このドキュメントでは、Supabaseを使用してキャラクターアバター画像を動的に管理するためのセットアップ方法を説明します。

## データベース構造

### avatarsテーブル
```sql
CREATE TABLE avatars (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  character_id TEXT NOT NULL UNIQUE, -- 'sarah', 'emily', 'john' など
  display_name TEXT NOT NULL,
  mouth_closed_path TEXT NOT NULL, -- 口を閉じた状態の画像パス
  mouth_open_path TEXT NOT NULL,   -- 口を開いた状態の画像パス
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 更新時にupdated_atを自動更新するトリガー
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_avatars_updated_at BEFORE UPDATE
  ON avatars FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### 初期データ
```sql
-- デフォルトアバターの登録
INSERT INTO avatars (character_id, display_name, mouth_closed_path, mouth_open_path) VALUES
('sarah', 'Sarah', 'avatars/sarah/mouth_closed.png', 'avatars/sarah/mouth_open.png'),
('emily', 'Emily', 'avatars/emily/mouth_closed.png', 'avatars/emily/mouth_open.png'),
('john', 'John', 'avatars/john/mouth_closed.png', 'avatars/john/mouth_open.png');
```

## ストレージ設定

### バケット作成
1. Supabaseダッシュボードでストレージセクションに移動
2. 新しいバケット「avatars」を作成（パブリックアクセスを有効化）

### フォルダ構造
```
avatars/
├── sarah/
│   ├── mouth_closed.png
│   └── mouth_open.png
├── emily/
│   ├── mouth_closed.png
│   └── mouth_open.png
└── john/
    ├── mouth_closed.png
    └── mouth_open.png
```

## 実装例

### アバター情報の取得
```dart
Future<Map<String, String>?> getAvatarPaths(String characterId) async {
  try {
    final response = await Supabase.instance.client
        .from('avatars')
        .select('mouth_closed_path, mouth_open_path')
        .eq('character_id', characterId)
        .single();
    
    if (response != null) {
      final baseUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl('');
      
      return {
        'mouth_closed': baseUrl + response['mouth_closed_path'],
        'mouth_open': baseUrl + response['mouth_open_path'],
      };
    }
  } catch (e) {
    print('Error fetching avatar paths: $e');
  }
  return null;
}
```

### AnimatedAvatarウィジェットでの使用
```dart
// 将来的な実装例
AnimatedAvatar(
  isPlaying: _isPlayingAudio,
  size: 120,
  avatarId: 'sarah',
  isCustomAvatar: true, // Supabaseからアバターを取得
  fallbackAvatarPath: 'assets/images/avatars/default_avatar.png',
)
```

## ポリシー設定（RLS）

```sql
-- アバター情報は全ユーザーが読み取り可能
CREATE POLICY "Allow public read access" ON avatars
  FOR SELECT
  USING (true);

-- 管理者のみ更新・削除可能
CREATE POLICY "Allow admin update" ON avatars
  FOR UPDATE
  USING (auth.uid() IN (
    SELECT user_id FROM user_roles WHERE role = 'admin'
  ));

CREATE POLICY "Allow admin delete" ON avatars
  FOR DELETE
  USING (auth.uid() IN (
    SELECT user_id FROM user_roles WHERE role = 'admin'
  ));
```

## 注意事項

1. **画像サイズ**: アバター画像は正方形（推奨: 512x512px）で用意する
2. **ファイル形式**: PNG形式を推奨（透過背景対応）
3. **命名規則**: `character_id/mouth_[closed|open].png`の形式を維持
4. **キャッシュ**: 画像URLは適切にキャッシュして、過度なリクエストを避ける

## 今後の拡張

- カスタムアバターのアップロード機能
- アニメーションフレームの追加（口の動きをより自然に）
- 表情バリエーションの追加（笑顔、驚きなど）
- アバターのカスタマイズ機能（髪色、服装など） 