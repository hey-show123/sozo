# テストユーザー作成手順書

## 📋 現在の状況確認

### hey_show@icloud.comの権限
✅ **確認済み**: `super_admin` 権限を持っています
- 組織: ヘイショウ株式会社
- 組織ID: `7aefa49d-8e1e-402a-b3e9-6173f91f119d`
- 権限レベル: スーパー管理者（最高権限）

## 🎯 作成予定のテストユーザー

### 1. 田中太郎 (Viewer - 閲覧者)
- **メール**: `tanaka@heisho.com`
- **権限**: `viewer` (進捗閲覧のみ)
- **設定データ**: XP 2500, Level 5, Streak 15

### 2. 佐藤花子 (Admin - 管理者)  
- **メール**: `sato@heisho.com`
- **権限**: `admin` (メンバー管理可能)
- **設定データ**: XP 3200, Level 6, Streak 22

### 3. 鈴木一郎 (Learner - 学習者)
- **メール**: `suzuki@heisho.com`
- **権限**: `learner` (学習のみ)
- **設定データ**: XP 1800, Level 3, Streak 8

### 4. 山田美香 (Learner - 学習者)
- **メール**: `yamada@heisho.com`
- **権限**: `learner` (学習のみ)
- **設定データ**: XP 1200, Level 2, Streak 5

### 5. 高橋健太 (Viewer - 閲覧者)
- **メール**: `takahashi@heisho.com`
- **権限**: `viewer` (進捗閲覧のみ)
- **設定データ**: XP 2100, Level 4, Streak 12

## 🚀 作成手順

### Step 1: Supabaseダッシュボードでユーザー作成

1. [Supabase Dashboard](https://supabase.com/dashboard) にアクセス
2. プロジェクト: `uwgxkekvpchqzvnylszl` を選択
3. **Authentication** → **Users** → **Add user** をクリック
4. 各ユーザーを以下の設定で作成:

```
✅ Auto Confirm Email: チェック
パスワード: 任意（テスト用なので簡単なもので可）
```

**作成順序**:
1. tanaka@heisho.com
2. sato@heisho.com  
3. suzuki@heisho.com
4. yamada@heisho.com
5. takahashi@heisho.com

### Step 2: ユーザーIDを取得・記録

各ユーザー作成後、**User ID**をコピーして記録：

```
田中太郎: [ユーザーID]
佐藤花子: [ユーザーID]
鈴木一郎: [ユーザーID]  
山田美香: [ユーザーID]
高橋健太: [ユーザーID]
```

### Step 3: 組織への追加

Supabase SQL Editorで以下を実行：

```sql
-- 田中太郎 (Viewer)
INSERT INTO user_organization_roles (user_id, organization_id, role, created_at, updated_at)
VALUES ('[田中太郎のユーザーID]', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'viewer', NOW(), NOW());

-- 佐藤花子 (Admin)  
INSERT INTO user_organization_roles (user_id, organization_id, role, created_at, updated_at)
VALUES ('[佐藤花子のユーザーID]', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'admin', NOW(), NOW());

-- 鈴木一郎 (Learner)
INSERT INTO user_organization_roles (user_id, organization_id, role, created_at, updated_at)
VALUES ('[鈴木一郎のユーザーID]', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'learner', NOW(), NOW());

-- 山田美香 (Learner)
INSERT INTO user_organization_roles (user_id, organization_id, role, created_at, updated_at)
VALUES ('[山田美香のユーザーID]', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'learner', NOW(), NOW());

-- 高橋健太 (Viewer)
INSERT INTO user_organization_roles (user_id, organization_id, role, created_at, updated_at)
VALUES ('[高橋健太のユーザーID]', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'viewer', NOW(), NOW());
```

### Step 4: プロフィールデータ追加

```sql
-- 田中太郎のプロフィール
INSERT INTO profiles (id, username, total_xp, current_level, streak_count, created_at, updated_at)
VALUES ('[田中太郎のユーザーID]', '田中太郎', 2500, 5, 15, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  username = EXCLUDED.username,
  total_xp = EXCLUDED.total_xp,
  current_level = EXCLUDED.current_level,
  streak_count = EXCLUDED.streak_count,
  updated_at = NOW();

-- 佐藤花子のプロフィール
INSERT INTO profiles (id, username, total_xp, current_level, streak_count, created_at, updated_at)
VALUES ('[佐藤花子のユーザーID]', '佐藤花子', 3200, 6, 22, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  username = EXCLUDED.username,
  total_xp = EXCLUDED.total_xp,
  current_level = EXCLUDED.current_level,
  streak_count = EXCLUDED.streak_count,
  updated_at = NOW();

-- 鈴木一郎のプロフィール  
INSERT INTO profiles (id, username, total_xp, current_level, streak_count, created_at, updated_at)
VALUES ('[鈴木一郎のユーザーID]', '鈴木一郎', 1800, 3, 8, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  username = EXCLUDED.username,
  total_xp = EXCLUDED.total_xp,
  current_level = EXCLUDED.current_level,
  streak_count = EXCLUDED.streak_count,
  updated_at = NOW();

-- 山田美香のプロフィール
INSERT INTO profiles (id, username, total_xp, current_level, streak_count, created_at, updated_at)
VALUES ('[山田美香のユーザーID]', '山田美香', 1200, 2, 5, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  username = EXCLUDED.username,
  total_xp = EXCLUDED.total_xp,
  current_level = EXCLUDED.current_level,
  streak_count = EXCLUDED.streak_count,
  updated_at = NOW();

-- 高橋健太のプロフィール
INSERT INTO profiles (id, username, total_xp, current_level, streak_count, created_at, updated_at)
VALUES ('[高橋健太のユーザーID]', '高橋健太', 2100, 4, 12, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  username = EXCLUDED.username,
  total_xp = EXCLUDED.total_xp,
  current_level = EXCLUDED.current_level,
  streak_count = EXCLUDED.streak_count,
  updated_at = NOW();
```

### Step 5: 確認クエリ

作成完了後、以下で確認：

```sql
-- 組織メンバー一覧
SELECT 
    u.email,
    p.username,
    uor.role,
    p.total_xp,
    p.current_level,
    p.streak_count,
    uor.created_at as joined_at
FROM user_organization_roles uor
JOIN auth.users u ON uor.user_id = u.id
LEFT JOIN profiles p ON u.id = p.id
JOIN organizations o ON uor.organization_id = o.id
WHERE o.id = '7aefa49d-8e1e-402a-b3e9-6173f91f119d'
ORDER BY uor.role, u.email;
```

## 🔒 権限テストシナリオ

### Super Admin (hey_show@icloud.com)
- ✅ 組織ダッシュボードアクセス
- ✅ 全メンバー進捗閲覧
- ✅ メンバー招待・権限変更
- ✅ 組織設定変更

### Admin (佐藤花子)
- ✅ 組織ダッシュボードアクセス
- ✅ 全メンバー進捗閲覧
- ✅ メンバー招待・権限変更
- ❌ 組織設定変更（Super Adminのみ）

### Viewer (田中太郎・高橋健太)
- ✅ 組織ダッシュボードアクセス
- ✅ 全メンバー進捗閲覧
- ❌ メンバー招待・権限変更
- ❌ 組織設定変更

### Learner (鈴木一郎・山田美香)
- ❌ 組織ダッシュボードアクセス
- ✅ 自分の学習進捗のみ
- ❌ 他メンバー情報閲覧
- ❌ 組織管理機能全て

## 📱 アプリでのテスト方法

1. **hey_show@icloud.com**でログイン → 組織管理ボタンが表示される
2. 各テストユーザーでログイン → 権限に応じた機能制限を確認
3. 組織ダッシュボードで各メンバーの進捗データが表示される
4. ユーザー詳細画面で個別進捗が確認できる

## ⚠️ 注意事項

- テストユーザーのパスワードは簡単なものにして構いません
- 実際の運用では強力なパスワードを使用してください
- profilesテーブルの構造に合わせてクエリを調整してください
- 本番環境では絶対にテストデータを作成しないでください 