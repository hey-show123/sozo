#!/bin/bash

# TestFlight 自動アップロードスクリプト

echo "🚀 TestFlight への自動アップロードを開始します..."

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

# CocoaPods更新
echo "🔧 CocoaPods を更新中..."
cd ios && pod install && cd ..

# iOSアーカイブをビルド（IPAファイル作成）
echo "🔨 iOS アーカイブをビルド中..."
flutter build ipa --release

# IPAファイルのパスを確認
IPA_PATH="build/ios/ipa/sozo_app.ipa"

if [ ! -f "$IPA_PATH" ]; then
    echo -e "${RED}❌ IPAファイルが見つかりません: $IPA_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ IPAビルド完了${NC}"
echo "📍 IPAパス: $IPA_PATH"

# App Store Connect にアップロード
echo "📤 App Store Connect にアップロード中..."

# 注意: 以下のコマンドを実行する前に、App Store Connect APIキーを設定するか、
# アプリ固有のパスワードをキーチェーンに保存する必要があります

# 方法1: アプリ固有のパスワードを直接入力する場合
# xcrun altool --upload-app \
#     --type ios \
#     --file "$IPA_PATH" \
#     --username "hey1296show@gmail.com" \
#     --password "アプリ固有のパスワード" \
#     --verbose

# 方法2: Apple Transporterアプリを使用する（推奨）
echo -e "${YELLOW}⚠️ IPAファイルが作成されました。以下の方法でアップロードしてください：${NC}"
echo "1. Apple Transporterアプリを開く: https://apps.apple.com/us/app/transporter/id1450874784"
echo "2. 作成されたIPAファイルをドラッグ＆ドロップ: $IPA_PATH"
echo ""
echo "または、以下のコマンドを手動で実行してアップロードすることもできます："
echo "xcrun altool --upload-app --type ios -f $IPA_PATH --apiKey your_api_key --apiIssuer your_issuer_id"

# Apple Transporterを開く
open -a "Transporter"

# IPAファイルが正常に作成されたことを確認
if [ -f "$IPA_PATH" ]; then
    echo -e "${GREEN}✅ IPAファイルが正常に作成されました！${NC}"
    echo "🎉 Apple Transporterアプリを使用してアップロードしてください"
    echo "📱 アップロード後、TestFlight でテスターに配布できます"
    
    # App Store Connect を開く
    open "https://appstoreconnect.apple.com"
else
    echo -e "${RED}❌ IPAファイルの作成に失敗しました${NC}"
    echo "💡 エラーログを確認してください"
    exit 1
fi 