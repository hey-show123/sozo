# Supabase データベースマイグレーション

このディレクトリには、Supabaseデータベースのマイグレーションファイルが含まれています。

## マイグレーションの実行方法

### 1. Supabase SQL Editorから実行

1. [Supabase Dashboard](https://supabase.com/dashboard) にアクセス
2. プロジェクトを選択
3. 左メニューから「SQL Editor」を選択
4. 「New query」をクリック
5. マイグレーションファイルの内容をコピー＆ペースト
6. 「Run」をクリックして実行

### 2. 実行順序

以下の順序でマイグレーションを実行してください：

1. `create_user_settings_table.sql` - ユーザー設定テーブル
2. `create_ai_prompts_table.sql` - AIプロンプト管理テーブル

### 3. AIプロンプトテーブルについて

`ai_prompts`テーブルは、以下の3種類のプロンプトを管理します：

- **lesson_conversation**: レッスン中のAI会話用プロンプト
- **session_evaluation**: セッション評価用プロンプト  
- **general_conversation**: 一般会話（ホーム画面）用プロンプト

管理画面の「AIチューニング」タブから、これらのプロンプトを編集できます。

### 4. 権限について

- AIプロンプトの読み取りは全ユーザーが可能
- 編集・削除は`super_admin`権限を持つユーザーのみ可能

### 5. トラブルシューティング

エラーが発生した場合：

1. テーブルが既に存在する場合は、`DROP TABLE IF EXISTS テーブル名;`を実行してから再度マイグレーションを実行
2. 権限エラーの場合は、Supabaseの管理者アカウントでログインしているか確認
3. RLSポリシーエラーの場合は、テーブルのRLSが有効になっているか確認 