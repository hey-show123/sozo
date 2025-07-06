# Firebase App Distribution 設定ガイド

## 1. Firebase Consoleでの設定

1. [Firebase Console](https://console.firebase.google.com/project/hanacemi-a175c/appdistribution) にアクセス
2. 左メニューから「App Distribution」を選択
3. 「開始」ボタンをクリック

## 2. テスターグループの作成

1. App Distributionダッシュボードで「テスターとグループ」タブを選択
2. 「グループを作成」をクリック
3. グループ名を「testers」として作成
4. テスターのメールアドレスを追加

## 3. APKのアップロード

### 手動アップロード（初回推奨）
1. Firebase Consoleの「リリース」タブを選択
2. 「APKをアップロード」をクリック
3. ビルドされたAPKファイルを選択：
   ```
   ./android/app/property(org.gradle.api.file.Directory, fixed(class org.gradle.api.internal.file.DefaultFilePropertyFactory$FixedDirectory, /Users/yamazakishohei/Documents/SOZO/sozo_app/build))/app/outputs/apk/release/app-release.apk
   ```
4. リリースノートを追加
5. 「testers」グループを選択して配布

### コマンドラインからのアップロード

```bash
# Firebase CLIでのアップロード
firebase appdistribution:distribute \
  "./android/app/property(org.gradle.api.file.Directory, fixed(class org.gradle.api.internal.file.DefaultFilePropertyFactory$FixedDirectory, /Users/yamazakishohei/Documents/SOZO/sozo_app/build))/app/outputs/apk/release/app-release.apk" \
  --app "1:686083564926:android:1ac95af8c30c19ec573f2f" \
  --release-notes "バージョン 1.0.0+1
- 発音評価の単語重複を修正
- 単語ごとの正確率表示を削除
- 文字自体に色をつけて読みやすく表示" \
  --groups "testers"
```

## 4. テスターへの通知

テスターグループに追加されたユーザーには自動的にメール通知が送信されます。

### テスター側の手順：
1. 招待メールを開く
2. 「アプリをダウンロード」をクリック
3. Firebase App Testerアプリをインストール（初回のみ）
4. アプリ内でSOZOアプリをダウンロード・インストール

## 5. 自動デプロイスクリプト

開発を効率化するため、以下のスクリプトを使用できます：

```bash
# 開発ビルドのデプロイ
./scripts/deploy_firebase.sh
```

このスクリプトは：
- ビルド番号を自動インクリメント
- リリースAPKをビルド
- Firebase App Distributionにアップロード
- テスターグループに自動配布

## トラブルシューティング

### APKが見つからない場合
```bash
# APKファイルの場所を確認
find . -name "app-release.apk" -type f
```

### Firebase CLIの認証エラー
```bash
# 再認証
firebase login --reauth
```

### ビルドエラー
```bash
# クリーンビルド
flutter clean
flutter pub get
flutter build apk --release
``` 