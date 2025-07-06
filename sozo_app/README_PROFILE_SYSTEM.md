# プロフィールシステム実装ドキュメント

## 概要
SOZOアプリのプロフィールシステムについて説明します。

## 機能
1. **アバター画像管理**
   - チュートリアル画面でカメラ撮影またはギャラリーから写真を選択
   - Supabase Storageの`avatars`バケットに保存
   - プロフィール編集画面でも変更可能

2. **表示名管理**
   - ユーザーが自由に設定できるニックネーム
   - 優先順位: display_name → username → email

3. **レベル進捗表示**
   - 円形プログレスバー付きアバター（LevelProgressAvatar）
   - 現在のレベルと次のレベルまでの残りXP表示

## 実装詳細

### データベース（Supabase）
- `profiles`テーブル
  - `avatar_url`: アバター画像のURL（Supabase StorageのパブリックURL）
  - `display_name`: 表示名
  - `current_level`: 現在のレベル
  - `total_xp`: 総XP
  - `streak_count`: 連続学習日数

### アバター画像の仕様
- 保存先: Supabase Storage `avatars`バケット
- ファイル名形式: `{user_id}/avatar_{timestamp}.jpg`
- 画像サイズ: 最大512x512ピクセル
- 画像品質: 70%
- キャッシュコントロール: 3600秒

### 主要コンポーネント

#### 1. ProfileProvider (`profile_provider.dart`)
- `UserProfile`モデル: ユーザープロフィール情報
- `ProfileNotifier`: プロフィールの取得・更新管理
- レベル進捗計算機能

#### 2. LevelProgressAvatar (`level_progress_avatar.dart`)
- 円形プログレスバー付きアバター表示
- ネットワーク画像（Supabase）とローカル画像の両方に対応
- アニメーション付き進捗表示

#### 3. プロフィール編集画面 (`profile_edit_screen.dart`)
- カメラ撮影/ギャラリーから画像選択
- 画像の削除機能
- 表示名の編集

### 画像アップロードフロー
1. ユーザーがカメラ/ギャラリーから画像を選択
2. ImagePickerで画像をリサイズ（最大512x512）
3. Supabase Storageにアップロード
4. パブリックURLを取得
5. `profiles`テーブルの`avatar_url`を更新

### セキュリティ
- Supabase Storageのバケットポリシーで適切なアクセス制御
- ユーザーは自分のディレクトリ（`{user_id}/`）のみアクセス可能

## 今後の拡張案
- 画像のクロップ機能
- プロフィール背景画像
- バッジシステムとの連携 