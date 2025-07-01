# Azure Speech Services 設定手順

SOZOアプリで発音評価機能を使用するには、Azure Speech Servicesの設定が必要です。

## 1. Azure Speech Servicesリソースの作成

1. [Azure Portal](https://portal.azure.com/)にログイン
2. 「リソースの作成」をクリック
3. 「Speech Services」を検索して選択
4. 以下の設定でリソースを作成：
   - **サブスクリプション**: 使用するサブスクリプションを選択
   - **リソースグループ**: 新規作成または既存を選択
   - **リージョン**: 最寄りのリージョンを選択（例: Japan East）
   - **名前**: 任意の名前（例: sozo-speech）
   - **価格レベル**: F0（無料）またはS0（標準）

## 2. APIキーとリージョンの取得

1. 作成したSpeech Servicesリソースを開く
2. 左側メニューの「キーとエンドポイント」をクリック
3. 「キー1」または「キー2」をコピー
4. 「場所/リージョン」をメモ（例: japaneast）

## 3. アプリケーションへの設定

1. `sozo_app`ディレクトリに`.env`ファイルを作成
2. 以下の内容を記載：

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# Azure Speech Services Configuration
AZURE_SPEECH_KEY=取得したAPIキー
AZURE_SPEECH_REGION=取得したリージョン（例: japaneast）

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here
```

3. `.gitignore`に`.env`が含まれていることを確認（セキュリティのため）

## 4. 動作確認

1. アプリケーションを再起動
2. レッスン画面でキーフレーズ練習を開く
3. マイクボタンを長押しして録音
4. 発音評価結果が表示されることを確認

## トラブルシューティング

### エラー: "Azure Speech Service credentials not found"
- `.env`ファイルが正しく作成されているか確認
- APIキーとリージョンが正しく設定されているか確認

### エラー: "Failed to assess pronunciation"
- Azureサブスクリプションが有効か確認
- APIキーが正しいか確認
- リージョンが正しいか確認
- ネットワーク接続を確認

## 無料枠の制限

Azure Speech Services F0（無料）プランの制限：
- 音声認識: 5時間/月
- 音声合成: 50万文字/月
- 同時接続数: 1

開発・テスト用途には十分ですが、本番環境ではS0（標準）プランの使用を推奨します。 