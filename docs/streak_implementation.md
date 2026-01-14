# ストリーク機能実装ドキュメント

## 概要
レッスンを完了するたびにストリーク（連続学習日数）が更新される機能を実装しました。

## 実装内容

### 1. データベース変更
- `profiles`テーブルに追加:
  - `longest_streak` INTEGER - 最長ストリーク記録
  - `last_streak_update` DATE - 最終ストリーク更新日

- `learning_sessions`テーブルを新規作成:
  - ユーザーの日次学習セッションを記録
  - レッスン完了情報、学習時間、獲得XPを保存

### 2. SQL関数
#### `complete_lesson()`
レッスン完了時に呼び出される主要関数：
- XPの更新
- レベルの更新
- 学習セッションの記録
- **ストリークの自動更新**

使用例:
```sql
SELECT public.complete_lesson(
    p_user_id := 'user-uuid',
    p_lesson_id := 'lesson-001',
    p_xp_earned := 100,
    p_minutes_spent := 15
);
```

#### `update_user_streak()`
ストリーク更新専用関数：
- 今日のアクティビティをチェック
- 昨日から継続しているかチェック
- ストリークカウントを更新
- 最長ストリークを記録

### 3. Flutter側の実装

#### StreakService (`lib/services/streak_service.dart`)
```dart
// レッスン完了時にストリークを更新
await streakService.completeLesson(
  lessonId: 'lesson-001',
  xpEarned: 100,
  minutesSpent: 15,
);
```

#### ProgressService の変更
- `completeActivity()`メソッド内で`complete_lesson` RPC関数を呼び出し
- レッスン完了と同時にストリークが自動更新される

### 4. UI表示
#### 進捗画面 (`progress_screen.dart`)
- 713-859行目: `_buildProminentStreakCard`
  - 現在のストリーク数を大きく表示
  - 最長ストリーク記録を表示
  - 週間目標への進捗バー
  - モチベーショナルメッセージ

## 動作フロー

1. **レッスン完了時**
   - ユーザーがレッスンの任意のアクティビティを完了
   - `ProgressService.completeActivity()` が呼び出される
   - `complete_lesson` SQL関数が実行される
   - ストリークが自動的に更新される

2. **ストリーク更新ロジック**
   - 今日初めてのレッスン完了 → ストリーク+1
   - 昨日も学習していた → 連続としてカウント
   - 2日以上空いた → ストリークを1にリセット
   - 同日に複数レッスン完了 → ストリークは増えない（1日1カウント）

3. **最長ストリーク**
   - 現在のストリークが最長記録を超えた場合、自動更新
   - リセットされても最長記録は保持される

## テスト方法

### SQL テスト
```sql
-- テストユーザーでレッスンを完了
SELECT public.complete_lesson(
    p_user_id := (SELECT id FROM profiles LIMIT 1),
    p_lesson_id := 'test_lesson',
    p_xp_earned := 100,
    p_minutes_spent := 10
);

-- ストリークを確認
SELECT display_name, streak_count, longest_streak, last_streak_update
FROM profiles;
```

### デバッグ用関数
```sql
-- ストリークを手動設定（テスト用）
SELECT public.debug_set_streak(
    p_user_id := 'user-uuid',
    p_streak_count := 7,
    p_longest_streak := 10,
    p_last_update := CURRENT_DATE
);
```

## 注意事項
- ストリークは日付ベースで管理（タイムゾーンは考慮）
- 1日に複数回レッスンを完了してもストリークは1つだけ増加
- `learning_sessions`テーブルで詳細な学習履歴を追跡可能

## 今後の拡張案
- [ ] ストリーク達成時の通知
- [ ] ストリークボーナスXP
- [ ] ストリークカレンダー表示
- [ ] ストリーク復活アイテム