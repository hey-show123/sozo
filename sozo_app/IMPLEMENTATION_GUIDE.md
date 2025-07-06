# SOZO 実装ガイド - ステップバイステップ

## 🎯 今すぐ始められる実装タスク

### Step 1: Azure Speech Services有効化（5分）✅ 完了

1. **ファイルを開く:** `/lib/services/azure_speech_service.dart`
2. **74行目を変更:**
```dart
// 変更前
static const bool _useMockImplementation = true;

// 変更後
static const bool _useMockImplementation = false;
```

3. **動作確認:**
   - アプリを再起動
   - 発音テスト画面へ移動
   - 実際に声を録音
   - リアルなスコアが表示されることを確認

**実装済み:** Azure Speech Services REST APIを使用した完全な実装が完了。本番環境で動作確認済み。

### Step 2: Supabaseテーブル作成 ✅ 完了

**注意:** MCPサーバー経由で既にテーブルを完全に再構築済みです。

**作成済みのテーブル構造:**
- `curriculums` - カリキュラムマスター
- `lessons` - レッスン（JSONBでkey_phrasesとdialogues格納）
- `user_lesson_progress` - 学習進捗
- `pronunciation_sessions` - 発音評価記録
- `achievements` - 実績マスター
- `user_achievements` - ユーザー実績
- `ai_conversations` - AI会話セッション
- `learning_sessions` - 日々の学習記録
- `user_settings` - ユーザー設定

**便利な関数も作成済み:**
- `update_user_streak()` - ストリーク自動更新
- `add_user_xp()` - XP追加とレベル計算
- `record_learning_activity()` - 学習アクティビティ記録

**MCPサーバーの活用:**
今後もSupabaseの操作はMCPサーバー経由で可能です。以下のツールが利用可能：
- `mcp_supabase_list_tables` - テーブル一覧
- `mcp_supabase_execute_sql` - SQL実行
- `mcp_supabase_apply_migration` - マイグレーション適用

### Step 3: 進捗サービスの実装（30分）✅ 完了

1. **新規ファイル作成:** `/lib/services/progress_service.dart` ✅
2. **既存画面への統合** ✅
   - KeyPhrasePracticeScreenに統合済み
   - レッスン開始時の記録
   - アクティビティ完了時のXP計算と付与
   - Supabaseの関数（`add_user_xp`, `update_user_streak`）を活用

### Step 4: ホーム画面の実データ連携（20分）✅ 完了

1. **プロバイダー作成:** `/lib/presentation/providers/user_stats_provider.dart` ✅
   - `userStatsProvider` - ユーザーの統計情報（XP、レベル、ストリーク）
   - `todayLearningStatsProvider` - 今日の学習データ

2. **HomeScreenの更新:** ✅
   - 実際のユーザーデータを表示
   - XPとストリークの表示
   - 今日の学習時間と進捗の表示
   - エラーハンドリングとローディング状態の実装

### Step 5: テストと確認（10分）✅ 完了

1. **アプリを再起動** ✅
2. **以下のフローをテスト:**
   - サインイン
   - レッスン選択
   - キーフレーズ練習を完了
   - XPが増えることを確認
   - ホーム画面でXPとストリークが更新されることを確認

---

## 🎯 次のステップ

### Step 6: XP獲得アニメーション ✅ 完了
- `/lib/presentation/widgets/xp_animation.dart` を作成済み
- 美しいアニメーション効果（フェードイン、スライド、スケール）
- オーバーレイ表示のヘルパークラス実装
- KeyPhrasePracticeScreenに統合済み

### Step 7: 他の画面への進捗サービス統合（進行中）
1. **DialogPracticeScreen** - ダイアログ練習完了時
2. **AiBuddyScreen** - AI会話セッション終了時  
3. **PronunciationTestScreen** - テスト完了時

### Step 8: 実績システムの実装 ✅ 完了

1. **実績データの投入** ✅
   - 18種類の実績マスターデータをSupabaseに投入
   - カテゴリ: マイルストーン、ストリーク、スキル、チャレンジ

2. **AchievementCheckerサービス作成** ✅
   - `/lib/services/achievement_service.dart` を作成
   - 実績の解除条件チェックロジック
   - XP自動付与機能

3. **実績解除通知の実装** ✅
   - `/lib/presentation/widgets/achievement_notification.dart` を作成
   - カテゴリ別カラーリング
   - 美しいアニメーション効果
   - 複数実績の順次表示機能

4. **既存画面への統合** ✅
   - KeyPhrasePracticeScreenに実績チェックを統合
   - アクティビティ完了時に自動チェック

### Step 9: レベルアップ通知システム ✅ 完了

1. **レベルアップ通知ウィジェット作成** ✅
   - `/lib/presentation/widgets/level_up_notification.dart` を作成
   - 豪華なアニメーション効果（パーティクル、スケール、グラデーション）
   - ProgressServiceに `LevelUpInfo` クラスを追加
   - レベルアップ検出ロジックの実装

2. **ProgressServiceの拡張** ✅
   - `completeActivity()` がレベルアップ情報を返すように修正
   - XP変更前後のレベル比較機能
   - レベル計算ユーティリティ関数の追加

3. **KeyPhrasePracticeScreenへの統合** ✅
   - レベルアップ時の通知表示機能
   - XPアニメーション → レベルアップ通知 → 実績通知の順次表示
   - 適切なタイミング制御

**実装した機能:**
- パーティクルエフェクト付きの豪華なレベルアップ演出
- レベルアップアニメーション（フェード、スライド、スケール）
- 新レベル到達の祝福メッセージ
- オーバーレイ表示による没入感の向上
- 5秒後の自動消去またはタップで閉じる機能

### Step 10: 他の画面への統合（3/4完了）✅ 部分完了

1. **DialogPracticeScreen** ✅ 完了
   - ダイアログ練習完了時の進捗サービス統合
   - 平均スコア計算とXP付与
   - レベルアップ・実績通知の表示

2. **AiBuddyScreen** ✅ 完了
   - AI会話セッション終了時の進捗サービス統合
   - メッセージ数、会話時間、発音スコアの記録
   - セッション完了ダイアログとXP表示
   - WillPopScopeでの適切な終了処理

3. **PronunciationTestScreen** 🔄 進行中
   - テスト完了時の進捗サービス統合

**実装内容:**
- 各画面での学習開始記録
- アクティビティ完了時のXP計算と付与
- レベルアップ通知の統合
- 実績チェックと通知表示
- 統計情報の記録と表示

### Step 11: レッスン自動遷移システム ✅ 完了

**実装内容:**
1. **キーフレーズ練習完了時の自動遷移** ✅
   - 完了ダイアログに「次のステップへ」ボタンを追加
   - ダイアログ練習画面への直接遷移機能
   - 完了メッセージの改善と次ステップの案内

2. **ダイアログ練習完了時の自動遷移** ✅
   - AI会話練習への遷移オプション追加
   - 完了ダイアログのUI改善
   - 次ステップへの誘導メッセージ

3. **AI会話練習完了時の遷移オプション** ✅
   - レッスン一覧への遷移機能
   - 全ステップ完了の祝福メッセージ
   - 他のレッスンへの案内

4. **ルーティング設定の追加** ✅
   - `/lesson/:id/dialog` - ダイアログ練習画面
   - `/lesson/:id/ai-conversation` - AI会話練習画面
   - AiBuddyScreenのlessonIdパラメータ対応

**修正したファイル:**
- `/lib/presentation/screens/lesson/key_phrase_practice_screen.dart`
- `/lib/presentation/screens/lesson/dialog_practice_screen.dart`
- `/lib/presentation/screens/chat/ai_buddy_screen.dart`
- `/lib/core/router/app_router.dart`

**UX改善効果:**
- 学習者が迷うことなく次のステップに進める
- 各ステップの完了感と達成感を向上
- レッスンの全体的な流れを明確化
- 学習継続率の向上を期待

### Step 12: 週間学習グラフの実データ化
1. **fl_chartパッケージの導入**
2. **学習データの集計**
3. **グラフコンポーネントの実装**

### Step 13: オンボーディングフロー
1. **学習目標選択画面**
2. **レベル診断**
3. **AIパートナー選択**
4. **初回チュートリアル**

---

## 💡 トラブルシューティング

### Supabaseエラーが出る場合
```sql
-- RLSが原因の場合、一時的に無効化してテスト
ALTER TABLE user_lesson_progress DISABLE ROW LEVEL SECURITY;
-- テスト後は必ず有効化
ALTER TABLE user_lesson_progress ENABLE ROW LEVEL SECURITY;
```

### Azureが動かない場合
- .envファイルのキーが正しいか確認
- リージョンが正しいか確認（japaneast推奨）
- APIの使用量制限に達していないか確認

---

最終更新: 2024/12/19 