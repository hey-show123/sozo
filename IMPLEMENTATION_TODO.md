# SOZO 詳細実装TODOリスト

## 🎯 実装の優先順位

### 🔴 Phase 1: 必須機能の完成（1-2週間）

#### 1.1 Azure Speech Services本番接続 ✅ 完了
**ファイル:** `/lib/services/azure_speech_service.dart`
**実施内容:**
- ~~flutter_azure_speechパッケージを導入~~ → 発音評価非対応のため削除
- Azure Speech Services REST APIを使用した完全実装に変更
- 発音評価機能をREST APIで実装
- エラーハンドリングとフォールバック機能を追加
- 本番APIキーでの動作確認完了（テスト音声ファイルで83.6%のスコアを確認）

**実装品質評価:**
- ✅ REST API実装完了
- ✅ JSONレスポンス解析実装（実際のAPI形式に対応）
- ✅ エラーハンドリング実装
- ✅ 本番環境でのテスト実施（Pythonスクリプトで検証）
- ✅ 実際の音声ファイルで発音評価が正常動作
- ✅ 単語レベルの詳細評価も取得可能

**残課題:**
- ⚠️ WAVファイル形式の最適化（現在は録音設定のデフォルトを使用）
- ⚠️ レスポンスタイムの最適化（現在最大30秒タイムアウト）
- ⚠️ 音素レベルの詳細評価データの活用（UIでの表示未実装）

**環境設定メモ:**
- APIキーは `/Users/yamazakishohei/Documents/SOZO/sozo_app/.env` に配置済み
- リージョンは `japaneast` を使用

#### 1.2 学習進捗の永続化 ✅ 完了
**実施内容:**
- `/lib/services/progress_service.dart` を作成
- `/lib/presentation/providers/user_stats_provider.dart` を作成
- KeyPhrasePracticeScreenに進捗記録を統合 ✅
- DialogPracticeScreenに進捗記録を統合 ✅
- AiBuddyScreenに進捗記録を統合 ✅
- PronunciationTestScreenに進捗記録を統合 ✅
- HomeScreenで実データ表示

**実装した機能:**
- レッスン開始記録
- アクティビティ完了時のXP計算と付与
- ストリーク管理（連続学習日数）
- ユーザー統計の表示（XP、レベル、ストリーク）
- レベルアップ検出機能
- 各画面での完了ダイアログとXP表示

**統合完了した画面:**
- ✅ KeyPhrasePracticeScreen: キーフレーズ練習完了時
- ✅ DialogPracticeScreen: ダイアログ完了時（平均スコア計算、時間計測）
- ✅ AiBuddyScreen: 会話セッション終了時（メッセージ数、時間、XP表示）
- ✅ PronunciationTestScreen: テスト完了時（XP付与、レベルアップ通知）

#### 1.3 データベーステーブル作成 ✅ 完了
**実施内容:**
- MCPサーバー経由でSupabaseテーブルを完全に再構築
- 既存の非効率なテーブル構造を削除
- 最適化された新しいテーブル構造を作成

**作成したテーブル:**
1. **curriculums** - カリキュラムマスター（ビジネス、旅行、日常会話など）
2. **lessons** - レッスン（key_phrasesとdialoguesをJSONBで直接格納）
3. **user_lesson_progress** - ユーザーの学習進捗
4. **pronunciation_sessions** - 発音評価記録
5. **achievements** - 実績マスター
6. **user_achievements** - ユーザー実績
7. **ai_conversations** - AI会話セッション（メッセージをJSONBで格納）
8. **learning_sessions** - 日々の学習記録
9. **user_settings** - ユーザー設定

**最適化のポイント:**
- ✅ 正規化を適度に抑えてパフォーマンスを優先
- ✅ JSONBを活用して関連データを効率的に格納
- ✅ 適切なインデックスを作成
- ✅ RLSポリシーを全テーブルに設定
- ✅ 便利なビューと関数を作成

**作成した便利な機能:**
- `user_learning_stats` ビュー - ユーザーの総合統計
- `today_learning_summary` ビュー - 今日の学習サマリー
- `update_user_streak()` 関数 - ストリーク自動更新
- `add_user_xp()` 関数 - XP追加とレベル計算
- `record_learning_activity()` 関数 - 学習アクティビティ記録

**MCPサーバー利用のメリット:**
- Supabaseダッシュボードを開かずに直接操作可能
- プログラマティックにテーブル構造を管理
- マイグレーションとして記録される

#### 1.4 レッスン自動遷移機能 ✅ 完了
**実施内容:**
- キーフレーズ練習 → ダイアログ練習 → AI会話練習の順次自動遷移を実装
- 各ステップ完了時に「次のステップへ」ボタンを追加
- 適切なルーティング設定を追加

**実装した機能:**
- KeyPhrasePracticeScreen完了時にダイアログ練習への遷移オプション
- DialogPracticeScreen完了時にAI会話練習への遷移オプション
- AI会話練習完了時にレッスン一覧への遷移オプション
- 各ステップでの完了メッセージと次ステップの案内
- ルーティング設定の追加（`/lesson/:id/dialog`, `/lesson/:id/ai-conversation`）

**修正したファイル:**
- ✅ `/lib/presentation/screens/lesson/key_phrase_practice_screen.dart`
- ✅ `/lib/presentation/screens/lesson/dialog_practice_screen.dart`
- ✅ `/lib/presentation/screens/chat/ai_buddy_screen.dart`
- ✅ `/lib/core/router/app_router.dart`

**UX改善:**
- 学習者が迷うことなく次のステップに進める
- 各ステップの完了感と達成感を向上
- レッスンの全体的な流れを明確化

### 🟠 Phase 2: ゲーミフィケーション（1週間）

#### 2.1 XPシステム実装 ✅ 完了
**実施内容:**
- XP計算ロジックの実装
- XPアニメーションウィジェットの作成
- 各アクティビティへのXP付与統合

#### 2.2 実績システム ✅ 完了
**実施内容:**
- 実績マスターデータをSupabaseに投入（18種類の実績）
- AchievementServiceの作成
  - 実績の取得・解除判定ロジック
  - カテゴリ別実績管理
  - 進捗率計算
- 実績解除通知アニメーションの実装
  - 美しいスライドインアニメーション
  - カテゴリ別カラーリング
  - 複数実績の順次表示
- 全学習画面への統合完了

**実績カテゴリ:**
- 🏆 マイルストーン: レベル達成、XP獲得
- 🔥 ストリーク: 連続学習日数
- 💪 スキル: 発音スコア、会話回数
- ⚡ チャレンジ: 特定条件下での学習

#### 2.3 レベルアップ通知システム ✅ 完了
**実施内容:**
- `/lib/presentation/widgets/level_up_notification.dart` を作成
  - パーティクルエフェクト付きの豪華な演出
  - レベルアップアニメーション（フェード、スライド、スケール）
  - 新レベル到達の祝福メッセージ
  - オーバーレイ表示による没入感の向上
- ProgressServiceの拡張
  - `LevelUpInfo` クラスの追加
  - XP変更前後のレベル比較機能
  - レベル計算ユーティリティ関数
- 全学習画面への統合完了
  - XPアニメーション → レベルアップ通知 → 実績通知の順次表示
  - 適切なタイミング制御

#### 2.4 実績画面 ✅ 完了
**実施内容:**
- `/lib/presentation/screens/achievements/achievements_screen.dart` を作成
  - カテゴリー別タブ表示（すべて、マイルストーン、ストリーク、スキル、チャレンジ）
  - 実績カードのグリッド表示
  - 進捗バー付きの未解除実績表示
  - 実績詳細モーダル
  - 全体の実績解除率表示
- プロフィール画面からの導線追加
- ルーティング設定の追加（`/achievements`）

**UI/UX特徴:**
- カテゴリー別カラーリング
- ロック/アンロック状態の視覚的区別
- スムーズなアニメーション
- 実績達成時のXP報酬表示

### 🟡 Phase 3: オンボーディング（1週間）

#### 3.1 学習目標選択画面
**ファイル:** `/lib/presentation/screens/onboarding/goal_selection_screen.dart`
```dart
class GoalSelectionScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // プログレスインジケーター (1/4)
            LinearProgressIndicator(value: 0.25),
            
            // タイトル
            Text('学習目標を選んでください'),
            
            // 目標カード一覧
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  GoalCard(
                    icon: Icons.business,
                    title: 'ビジネス英語',
                    color: Colors.blue,
                  ),
                  GoalCard(
                    icon: Icons.flight,
                    title: '旅行・生活',
                    color: Colors.green,
                  ),
                  // ... 他の目標
                ],
              ),
            ),
            
            // 次へボタン
            ElevatedButton(
              onPressed: selectedGoal != null ? () => navigateNext() : null,
              child: Text('次へ'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 3.2 レベル診断
**実装フロー:**
1. 簡易発音テスト（3フレーズ）
2. 語彙クイズ（10問）
3. リスニング理解（5問）
4. 結果に基づくレベル判定

#### 3.3 AIパートナー選択
**キャラクターデータ:**
```dart
final aiPartners = [
  AIPartner(
    id: 'maya',
    name: 'Maya',
    personality: 'フレンドリーで励まし上手',
    voice: 'nova',
    avatar: 'assets/avatars/maya.png',
  ),
  // ... 他のパートナー
];
```

### 🟢 Phase 4: 追加機能（2週間）

#### 4.1 オフライン対応
**キャッシュ戦略:**
1. レッスンデータ: SharedPreferencesに保存
2. 音声ファイル: path_providerでローカル保存
3. 進捗データ: SQLiteでローカルDB

#### 4.2 ソーシャル機能
- フレンドリスト
- 週間リーダーボード
- 学習グループ

#### 4.3 詳細分析
- 発音の弱点分析
- 学習パターン分析
- パーソナライズされた推奨

---

## 📋 実装チェックリスト

### Week 1
- [x] Azure本番接続 (REST API実装完了、本番テスト実施済み)
- [x] データベーステーブル作成 (MCPサーバー経由で完全再構築済み)
- [x] 進捗記録サービス実装
- [x] XPシステム基本実装 (計算ロジック完了、UI実装完了)
- [x] XP獲得アニメーション実装
- [x] ホーム画面の実データ連携

### Week 2
- [x] 実績システム実装
- [x] レベルアップ通知システム実装
- [x] レッスン自動遷移機能実装 (キーフレーズ→ダイアログ→AI会話)
- [ ] ストリーク機能（基本実装は完了、UI改善が必要）
- [x] 他の画面への進捗サービス統合（4/4完了）
  - [x] KeyPhrasePracticeScreen
  - [x] DialogPracticeScreen
  - [x] AiBuddyScreen
  - [x] PronunciationTestScreen
- [x] 実績画面の作成
- [x] プロフィール画面の実データ化

### Week 3
- [x] 週間学習グラフの実装（ホーム画面） ✅ fl_chart使用で実装完了
- [x] オンボーディングフロー ✅ 3ステップ実装完了
  - [x] 学習目標選択（旅行、ビジネス、日常会話、試験対策）
  - [x] レベル選択（初級、中級、上級）
  - [x] AIパートナー選択（フレンドリー、プロフェッショナル、カジュアル）
- [ ] レベル診断（詳細診断テスト）
- [ ] 初回ユーザー体験の最適化

### Week 4
- [ ] オフライン対応
- [ ] パフォーマンス最適化
- [ ] バグ修正
- [ ] リリース準備

---

## 🚀 即実行可能なタスク

1. **次の優先タスク:**
   - レベル診断テストの実装（発音、語彙、リスニング）
   - ストリーク表示のUI改善
   - プッシュ通知機能の実装

2. **Supabaseで実行:**
   - 学習データの集計用RPCの作成
   - パフォーマンス最適化

3. **テスト実行:**
   ```bash
   flutter test
   flutter run
   ```

---

最終更新: 2024/12/19 - 週間学習グラフ実装完了、オンボーディングフロー実装完了 