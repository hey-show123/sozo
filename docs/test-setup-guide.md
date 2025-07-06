# 組織管理機能テストセットアップガイド

## 概要

組織管理機能をテストするためのダミーアカウントとデータのセットアップ手順です。

## 現在のテストデータ

以下のテスト組織が作成されています：

1. **テスト株式会社** (ID: 7aefa49d-8e1e-402a-b3e9-6173f91f119d)
   - 組織管理機能のテスト用組織
   
2. **サンプル企業** (ID: 21691c73-1aad-492b-8a99-11a302c0d83f)
   - 別の組織のテスト用

現在、`hey_show@icloud.com` が「テスト株式会社」の**管理者(Admin)**として設定されています。

## テスト用アカウントの作成手順

### 1. 新規テストユーザーの作成

アプリケーションの新規登録画面から以下のテストアカウントを作成してください：

#### Viewer（閲覧者）テストアカウント
- メール: `viewer.test@example.com`
- パスワード: `TestViewer123!`
- ユーザー名: `閲覧テストユーザー`

#### Learner（学習者）テストアカウント1
- メール: `learner1.test@example.com`
- パスワード: `TestLearner123!`
- ユーザー名: `学習者1`

#### Learner（学習者）テストアカウント2
- メール: `learner2.test@example.com`
- パスワード: `TestLearner123!`
- ユーザー名: `学習者2`

### 2. ユーザーを組織に追加

Supabase管理画面のSQL Editorで以下のクエリを実行してください：

```sql
-- ユーザーIDを取得
SELECT id, email FROM auth.users WHERE email IN (
  'viewer.test@example.com',
  'learner1.test@example.com',
  'learner2.test@example.com'
);

-- 取得したIDを使って組織にユーザーを追加
-- 以下は例です。実際のIDに置き換えてください
INSERT INTO user_organization_roles (user_id, organization_id, role)
VALUES 
  -- Viewerユーザー
  ('viewer-user-id', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'viewer'),
  -- Learnerユーザー1
  ('learner1-user-id', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'learner'),
  -- Learnerユーザー2
  ('learner2-user-id', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'learner');
```

### 3. テスト用学習データの作成

各学習者アカウントでログインして、いくつかのレッスンを完了させることで、リアルな学習進捗データを作成できます。

または、以下のSQLクエリでダミーデータを作成することも可能です：

```sql
-- プロフィールデータの更新（例）
UPDATE profiles 
SET 
  total_xp = 1500,
  current_level = 3,
  streak_count = 7
WHERE id = 'learner1-user-id';

UPDATE profiles 
SET 
  total_xp = 800,
  current_level = 2,
  streak_count = 3
WHERE id = 'learner2-user-id';

-- ダミーのレッスン進捗データ（例）
INSERT INTO user_lesson_progress (user_id, lesson_id, status, best_score, completed_at)
VALUES 
  ('learner1-user-id', 'lesson-1', 'completed', 95.0, NOW() - INTERVAL '2 days'),
  ('learner1-user-id', 'lesson-2', 'completed', 88.0, NOW() - INTERVAL '1 day'),
  ('learner1-user-id', 'lesson-3', 'in_progress', 72.0, NULL),
  ('learner2-user-id', 'lesson-1', 'completed', 82.0, NOW() - INTERVAL '3 days');
```

## テストシナリオ

### 1. Admin（管理者）としてのテスト
1. `hey_show@icloud.com` でログイン
2. プロフィール画面から「組織ダッシュボード」にアクセス
3. 全メンバーの学習進捗が表示されることを確認
4. 「招待」ボタンから新しいユーザーを招待できることを確認

### 2. Viewer（閲覧者）としてのテスト
1. `viewer.test@example.com` でログイン
2. プロフィール画面から「組織ダッシュボード」にアクセス
3. 全メンバーの学習進捗が表示されることを確認
4. 「招待」ボタンが表示されない（権限がない）ことを確認

### 3. Learner（学習者）としてのテスト
1. `learner1.test@example.com` でログイン
2. プロフィール画面に「組織ダッシュボード」リンクが表示されないことを確認
3. 通常の学習機能のみ利用可能であることを確認

## トラブルシューティング

### 組織ダッシュボードが表示されない
- ユーザーのロールが正しく設定されているか確認
- `user_organization_roles` テーブルを確認

### データが表示されない
- RLSポリシーが正しく設定されているか確認
- ユーザーが組織に所属しているか確認

### エラーが発生する
- ブラウザのコンソールログを確認
- Supabaseのログを確認 