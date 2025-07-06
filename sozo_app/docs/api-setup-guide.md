# SOZO API設定ガイド

## 1. 必要なAPIキー

### Supabase
- **SUPABASE_URL**: `https://uwgxkekvpchqzvnylszl.supabase.co`
- **SUPABASE_ANON_KEY**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3Z3hrZWt2cGNocXp2bnlsc3psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4NDkyNzMsImV4cCI6MjA2NjQyNTI3M30.vjf738gcyGxL6iwq2oc0gREtEFlgnRylaxnuY-7FRH4`

### OpenAI
- **OPENAI_API_KEY**: OpenAIのダッシュボードから取得
  - https://platform.openai.com/api-keys
  - `sk-` で始まるキー

### Azure Speech Service
- **AZURE_SPEECH_KEY**: Azureポータルから取得
  - 32文字の16進数文字列
- **AZURE_SPEECH_REGION**: リソースのリージョン
  - 例: `japaneast`, `westus`, `eastus`

## 2. .envファイルの作成

プロジェクトルート（`/Users/yamazakishohei/Documents/SOZO/sozo_app/`）に`.env`ファイルを作成：

```bash
cd /Users/yamazakishohei/Documents/SOZO/sozo_app/
touch .env
```

## 3. .envファイルの内容

```
# Supabase設定
SUPABASE_URL=https://uwgxkekvpchqzvnylszl.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3Z3hrZWt2cGNocXp2bnlsc3psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4NDkyNzMsImV4cCI6MjA2NjQyNTI3M30.vjf738gcyGxL6iwq2oc0gREtEFlgnRylaxnuY-7FRH4

# OpenAI API設定
OPENAI_API_KEY=あなたのOpenAIキーをここに入力

# Azure Speech Service設定
AZURE_SPEECH_KEY=あなたのAzureキーをここに入力
AZURE_SPEECH_REGION=japaneast
```

## 4. データベースの問題修正

現在のエラーは、チュートリアル用のレッスンIDがデータベースに存在しないために発生しています。

### 一時的な解決策

1. チュートリアルではオーディオファイルの保存をスキップ
2. 発音評価の結果保存もスキップ

### 恒久的な解決策

Supabaseのデータベースに以下のSQLを実行：

```sql
-- チュートリアル用の特別なレッスンを作成
INSERT INTO lessons (
  id,
  curriculum_id,
  title,
  description,
  type,
  difficulty,
  estimated_minutes,
  order_index,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'Tutorial: Welcome to SOZO',
  'Introduction conversation with SOZO instructor',
  'conversation',
  'beginner',
  5,
  0,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- profilesテーブルにonboarding_completedカラムを追加
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT FALSE;
```

## 5. 環境変数の確認

アプリ起動時のログで確認：
- `Environment loaded: 5 keys found` ✓
- `Azure Speech Key exists: true` ✓
- `Azure Speech Region exists: true` ✓

## 6. トラブルシューティング

### APIキーが読み込まれない場合
1. `.env`ファイルの場所を確認（プロジェクトルート）
2. `pubspec.yaml`の`assets`に`.env`が含まれているか確認
3. `flutter clean && flutter pub get`を実行

### Supabaseエラーの場合
1. URLが正しいか確認
2. Anon Keyが正しいか確認
3. ネットワーク接続を確認

### Azure/OpenAIエラーの場合
1. APIキーの有効性を確認
2. クォータ制限を確認
3. リージョン設定を確認 