#!/bin/bash

# SOZO English App - iOS + Android 同時デプロイスクリプト
# Firebase App Distributionを使用して両プラットフォームのテストビルドを配布

set -e

echo "🚀 SOZO English App - iOS + Android 同時ビルド開始"

# バージョン情報の取得
VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
RELEASE_NOTES="SOZO英会話アプリ - 開発テストビルド v$VERSION ($TIMESTAMP)"

echo "📱 バージョン: $VERSION"

# Android APK ビルド
echo "🤖 Android APKビルド中..."
flutter build apk --release
echo "✅ Android APK完了"

# iOS IPA ビルド（macOSでのみ実行）
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 iOS IPAビルド中..."
    flutter build ios --release --no-codesign
    
    # IPAファイルの作成（Xcode必要）
    echo "📦 IPAファイル作成中..."
    xcodebuild -workspace ios/Runner.xcworkspace \
               -scheme Runner \
               -sdk iphoneos \
               -configuration Release \
               archive -archivePath build/ios/archive/Runner.xcarchive
    
    xcodebuild -exportArchive \
               -archivePath build/ios/archive/Runner.xcarchive \
               -exportOptionsPlist ios/ExportOptions.plist \
               -exportPath build/ios/ipa
    
    echo "✅ iOS IPA完了"
else
    echo "⚠️  iOS ビルドはmacOSでのみ可能です。Androidのみ配布します。"
fi

# Firebase App Distribution にアップロード
echo "📤 Firebase App Distributionにアップロード中..."

# Android アップロード
echo "🤖 Android配布中..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:686083564926:android:1ac95af8c30c19ec573f2f \
  --release-notes "$RELEASE_NOTES" \
  --groups "internal-testers"

# iOS アップロード（macOSの場合のみ）
if [[ "$OSTYPE" == "darwin"* ]] && [[ -f "build/ios/ipa/Runner.ipa" ]]; then
    echo "🍎 iOS配布中..."
    firebase appdistribution:distribute build/ios/ipa/Runner.ipa \
      --app 1:686083564926:ios:9365dce5af5fd295573f2f \
      --release-notes "$RELEASE_NOTES" \
      --groups "internal-testers"
fi

echo "✅ 配布完了！"
echo "🔗 Firebase Console: https://console.firebase.google.com/project/hanacemi-a175c/appdistribution" 