# Azure Speech Services セットアップガイド

このガイドでは、SOZO AppでAzure Speech Servicesを使用するための設定方法を説明します。

## 1. Azure Speech リソースの作成

1. [Azure Portal](https://portal.azure.com) にログイン
2. 「リソースの作成」をクリック
3. 「Speech」を検索して選択
4. 以下の設定でリソースを作成：
   - **サブスクリプション**: お使いのサブスクリプション
   - **リソースグループ**: 新規作成または既存を選択
   - **リージョン**: Japan East（推奨）または最寄りのリージョン
   - **名前**: 任意の名前（例: sozo-speech）
   - **価格レベル**: F0（無料）またはS0（標準）

5. 作成完了後、リソースに移動して「キーとエンドポイント」から以下を取得：
   - **キー1** と **キー2**（両方をコピー推奨）
   - **場所/地域**（例: japaneast）

## 2. 環境変数の設定

1. `sozo_app`ディレクトリに`.env`ファイルを作成

2. 以下の内容を記述（実際のキーと地域を使用）：

### 基本設定（どちらか一つのキーを使用）
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
AZURE_SPEECH_KEY=your_azure_speech_key_1
AZURE_SPEECH_REGION=japaneast
OPENAI_API_KEY=your_openai_api_key
```

### 推奨設定（フォールバック機能付き）
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
AZURE_SPEECH_KEY_1=your_azure_speech_key_1
AZURE_SPEECH_KEY_2=your_azure_speech_key_2
AZURE_SPEECH_REGION=japaneast
OPENAI_API_KEY=your_openai_api_key
```

## フォールバック機能について

### 自動キー切り替え
アプリは以下の順序でAPIキーを使用します：
1. `AZURE_SPEECH_KEY` (基本キー)
2. `AZURE_SPEECH_KEY_1` (キー1)
3. `AZURE_SPEECH_KEY_2` (キー2)

### メリット
- **信頼性向上**: 一つのキーが失敗しても自動的に他のキーを試行
- **レート制限対策**: 複数のキーで利用制限を分散
- **ダウンタイム削減**: 一つのキーに問題があっても継続利用可能

## 重要：APIキーの形式について

### 正しいAPIキーの形式
- **Azure Speech Key**: 32文字の英数字（例: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`）
- 余分な文字（スペース、改行、引用符など）を含まないこと
- 各キーは独立して設定（連結しない）

### よくある問題と解決方法

1. **401認証エラーが頻発する場合**
   - APIキーに余分な文字が含まれていないか確認
   - キーの長さが32文字であることを確認
   - .envファイルの各行の末尾に改行がないか確認
   - 引用符で囲まないこと（正: `AZURE_SPEECH_KEY_1=abc123`、誤: `AZURE_SPEECH_KEY_1="abc123"`）

2. **キーの長さが84文字などの異常な値の場合**
   - 複数のキーが連結されていないか確認
   - Azure Portalから正しいキーをコピーし直す
   - コピー時に余分な文字が含まれていないか確認
   - 各キーを別々の行に記述

3. **設定例（正しい形式）**
   ```
   AZURE_SPEECH_KEY_1=1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p
   AZURE_SPEECH_KEY_2=9z8y7x6w5v4u3t2s1r0q9p8o7n6m5l4k
   ```

4. `.gitignore`に`.env`が含まれていることを確認（セキュリティのため）

## 3. 動作確認

1. アプリを起動
2. レッスン画面でキーフレーズ練習またはダイアログ練習を開始
3. 録音ボタンを押して発音評価が正常に動作することを確認

## トラブルシューティング

- `.env`ファイルが正しく作成されているか確認
- APIキーとリージョンが正しくコピーされているか確認
- Azureリソースがアクティブであることを確認
- ネットワーク接続を確認

### デバッグ情報の確認方法

コンソールログで以下の情報を確認できます：
- `Azure Speech Service: Found X valid keys` - 有効なキー数
- `Key 1: XXXXXXXX... (length: 32)` - 各キーの情報
- `Using primary key: XXXXXXXX...` - 使用中のキー
- `Switching to Azure key 2: XXXXXXXX...` - キー切り替えの通知
- `Authentication failed with key 1` - 認証失敗時の詳細

### よくあるエラーと対処法

- **`No valid Azure Speech API keys found`**: すべてのキーが32文字でない
- **`All available keys exhausted`**: すべてのキーで認証が失敗
- **`Failed to get response from Azure Speech API after trying all keys`**: ネットワークまたはサービスの問題

## 関連リンク

- [Azure Speech Services ドキュメント](https://docs.microsoft.com/ja-jp/azure/cognitive-services/speech-service/)
- [価格の詳細](https://azure.microsoft.com/ja-jp/pricing/details/cognitive-services/speech-services/) 