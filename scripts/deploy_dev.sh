#!/bin/bash

# SOZO English App - 開発用デプロイスクリプト
# Firebase App Distributionを使用して開発テストビルドを配布

set -e

echo "🚀 SOZO English App - 開発用ビルド開始"

# バージョン情報の取得
VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
echo "📱 バージョン: $VERSION"

# ビルド
echo "🔨 APKビルド中..."
flutter build apk --release

# Firebase App Distributionにアップロード
echo "📤 Firebase App Distributionにアップロード中..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:686083564926:android:1ac95af8c30c19ec573f2f \
  --release-notes "SOZO英会話アプリ - 開発テストビルド v$VERSION ($(date '+%Y-%m-%d %H:%M'))" \
  --groups "internal-testers"

echo "✅ デプロイ完了！"
echo "🔗 Firebase Console: https://console.firebase.google.com/project/hanacemi-a175c/appdistribution" 