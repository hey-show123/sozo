#!/bin/bash

# Firebase App Distribution デプロイスクリプト

echo "🚀 Firebase App Distribution へのデプロイを開始します..."

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# エラーハンドリング
set -e

# プロジェクトのルートディレクトリに移動
cd "$(dirname "$0")/.."

# Flutterの依存関係を取得
echo "📦 Flutter依存関係を取得中..."
flutter pub get

# ビルド番号を自動インクリメント
CURRENT_VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
VERSION_NAME=$(echo $CURRENT_VERSION | cut -d'+' -f1)
BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
NEW_VERSION="${VERSION_NAME}+${NEW_BUILD_NUMBER}"

echo "📝 バージョンを更新: $CURRENT_VERSION → $NEW_VERSION"
sed -i '' "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml

# Androidビルド
echo "🔨 Androidアプリをビルド中..."
flutter build apk --release

# APKファイルのパスを確認
APK_PATH="./android/app/property(org.gradle.api.file.Directory, fixed(class org.gradle.api.internal.file.DefaultFilePropertyFactory\$FixedDirectory, /Users/yamazakishohei/Documents/SOZO/sozo_app/build))/app/outputs/apk/release/app-release.apk"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}❌ APKファイルが見つかりません: $APK_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ APKビルド完了${NC}"
echo "📍 APKパス: $APK_PATH"

# Firebase App Distributionにアップロード
echo "📤 Firebase App Distributionにアップロード中..."

# リリースノート
RELEASE_NOTES="バージョン $NEW_VERSION
- 発音評価の単語重複を修正
- 単語ごとの正確率表示を削除
- 文字自体に色をつけて読みやすく表示"

# Firebase CLIを使用してアップロード
firebase appdistribution:distribute "$APK_PATH" \
    --app "1:686083564926:android:1ac95af8c30c19ec573f2f" \
    --release-notes "$RELEASE_NOTES" \
    --groups "testers"

echo -e "${GREEN}✅ Firebase App Distributionへのアップロード完了！${NC}"
echo "👥 テスターグループに配布されました"
echo "📱 テスターはFirebase App Distributionアプリからダウンロードできます" 