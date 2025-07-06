# Azure Speech Service セットアップガイド

## 問題の症状
- `Exception: No valid Azure Speech API keys found`
- `401 - Authentication failed`

## 解決方法

### 1. Azure Speech APIキーの確認

Azure Portalで以下を確認してください：

1. [Azure Portal](https://portal.azure.com)にログイン
2. Speech Serviceリソースを開く
3. 「Keys and Endpoint」をクリック
4. **KEY 1**または**KEY 2**をコピー（両方とも同じ機能です）

### 2. .envファイルの正しい記載方法

```env
# 正しい記載例（引用符なし、スペースなし）
AZURE_SPEECH_KEY_1=abcdef1234567890abcdef1234567890
AZURE_SPEECH_KEY_2=fedcba0987654321fedcba0987654321
AZURE_SPEECH_REGION=japaneast

# 間違った例
AZURE_SPEECH_KEY_1="abcdef1234567890abcdef1234567890"  # 引用符は不要
AZURE_SPEECH_KEY_2= fedcba0987654321fedcba0987654321   # 先頭のスペースはNG
AZURE_SPEECH_REGION='japaneast'                        # 引用符は不要
```

### 3. APIキーの形式

- **長さ**: 通常32文字（古いキーは84文字の場合もあります）
- **文字**: 英数字のみ（特殊文字は含まれません）
- **大文字小文字**: そのままコピー

### 4. リージョンの確認

日本のリージョン：
- `japaneast`（東日本）
- `japanwest`（西日本）

### 5. 確認コマンド

```bash
# .envファイルの内容を確認（キーの長さをチェック）
cd /Users/yamazakishohei/Documents/SOZO/sozo_app
awk -F= '/^AZURE_SPEECH/ {print $1 ": " length($2) " characters"}' .env

# 期待される出力例
# AZURE_SPEECH_KEY_1: 32 characters
# AZURE_SPEECH_KEY_2: 32 characters
# AZURE_SPEECH_REGION: 9 characters
```

### 6. トラブルシューティング

#### APIキーが84文字の場合
古い形式のキーの可能性があります。Azure Portalで新しいSpeech Serviceリソースを作成してください。

#### 401エラーが続く場合
1. APIキーが正しくコピーされているか確認
2. リージョンが正しいか確認
3. Speech Serviceのサブスクリプションが有効か確認
4. 無料枠の制限に達していないか確認

#### デバッグ方法
アプリ起動時のコンソールログを確認：
```
flutter: Azure Speech Service: Found 2 valid keys
flutter: Key 1: 7xYYIWMg... (length: 84)
flutter: WARNING: Key 1 might be URL encoded!
```

### 7. 推奨事項

1. **新しいSpeech Serviceリソースを作成**することを推奨します
2. F0（無料）プランでテスト可能です
3. 本番環境ではS0（標準）プランを使用してください

## 参考リンク

- [Azure Speech Service ドキュメント](https://docs.microsoft.com/ja-jp/azure/cognitive-services/speech-service/)
- [価格の詳細](https://azure.microsoft.com/ja-jp/pricing/details/cognitive-services/speech-services/) 