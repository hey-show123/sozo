# OpenAI API セットアップガイド

このドキュメントでは、SOZO AppでOpenAI APIを使用するための設定方法を説明します。

## 必要なもの

- OpenAI APIキー
- Flutterプロジェクトの`.env`ファイル

## セットアップ手順

### 1. OpenAI APIキーの取得

1. [OpenAI Platform](https://platform.openai.com/)にアクセス
2. アカウントにログイン（まだの場合は新規登録）
3. 右上のメニューから「API keys」を選択
4. 「Create new secret key」をクリック
5. キーをコピーして安全な場所に保存

### 2. プロジェクトへの設定

1. プロジェクトルートに`.env`ファイルを作成（既にある場合はそれを使用）

```bash
cd sozo_app
touch .env
```

2. `.env`ファイルに以下を追加：

```
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

3. `.gitignore`に`.env`が含まれていることを確認：

```gitignore
# 環境変数
.env
.env.local
```

### 3. 利用可能なモデル

AI会話練習機能では以下のモデルが利用可能です：

- **OpenAI o3** - 最先端の推論モデル（高精度、高コスト）
- **OpenAI o3-mini** - 効率的な推論モデル
- **OpenAI o4-mini** - 高速・低コスト（2025年4月版）
- **GPT-4o** - マルチモーダル対応
- **GPT-4o-mini** - 軽量版（推奨）
- **GPT-3.5 Turbo** - 高速応答

### 4. 機能の確認

1. アプリを起動
2. レッスンを選択
3. 「AI会話練習」を選択
4. 画面上部のドロップダウンでモデルを選択
5. 音声またはテキストで会話を開始

### 5. トラブルシューティング

#### APIキーエラーの場合

```dart
// lib/config/env.dartを確認
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get openAIApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
}
```

#### 音声認識が動作しない場合

1. マイクの権限を確認
2. iOS: Info.plistに以下が含まれているか確認

```xml
<key>NSMicrophoneUsageDescription</key>
<string>音声認識のためにマイクを使用します</string>
```

3. Android: AndroidManifest.xmlに以下が含まれているか確認

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### 6. 料金について

- Whisper API: $0.006/分
- GPT-4o-mini: $0.15/1M入力トークン、$0.60/1M出力トークン
- Text-to-Speech: $15.00/1M文字

詳細は[OpenAI Pricing](https://openai.com/pricing)を参照してください。 