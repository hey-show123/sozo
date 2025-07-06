-- テスト用組織データ作成スクリプト
-- hey_show@icloud.com (super_admin) の配下にテストユーザーを追加

-- 1. 既存の組織IDを使用（ヘイショウ株式会社）
-- 組織ID: 7aefa49d-8e1e-402a-b3e9-6173f91f119d

-- 2. テスト用ユーザーを auth.users テーブルに追加
-- 注意: 実際のパスワードハッシュは Supabase ダッシュボードで生成する必要があります
-- このスクリプトは参考用です。実際の追加は Supabase ダッシュボードで行ってください。

-- 参考: テストユーザーリスト
-- 1. 田中太郎 (Viewer) - tanaka@heisho.com
-- 2. 佐藤花子 (Admin) - sato@heisho.com  
-- 3. 鈴木一郎 (Learner) - suzuki@heisho.com
-- 4. 山田美香 (Learner) - yamada@heisho.com
-- 5. 高橋健太 (Viewer) - takahashi@heisho.com

-- 3. ユーザーIDを取得したら、以下のSQLで組織に追加
-- 注意: 実際のユーザーIDに置き換えてください

-- テストユーザー1: 田中太郎 (Viewer)
-- INSERT INTO user_organization_roles (user_id, organization_id, role, created_at, updated_at)
-- VALUES ('TANAKA_USER_ID', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'viewer', NOW(), NOW());

-- テストユーザー2: 佐藤花子 (Admin)  
-- INSERT INTO user_organization_roles (user_id, organization_id, role, created_at, updated_at)
-- VALUES ('SATO_USER_ID', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'admin', NOW(), NOW());

-- テストユーザー3: 鈴木一郎 (Learner)
-- INSERT INTO user_organization_roles (user_id, organization_id, role, created_at, updated_at)
-- VALUES ('SUZUKI_USER_ID', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'learner', NOW(), NOW());

-- テストユーザー4: 山田美香 (Learner)
-- INSERT INTO user_organization_roles (user_id, organization_id, role, created_at, updated_at)
-- VALUES ('YAMADA_USER_ID', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'learner', NOW(), NOW());

-- テストユーザー5: 高橋健太 (Viewer)
-- INSERT INTO user_organization_roles (user_id, organization_id, role, created_at, updated_at)
-- VALUES ('TAKAHASHI_USER_ID', '7aefa49d-8e1e-402a-b3e9-6173f91f119d', 'viewer', NOW(), NOW());

-- 4. テスト用プロフィールデータの追加
-- 注意: profilesテーブルの構造に合わせて調整してください

-- プロフィールデータ例（ユーザーIDを実際の値に置き換えてください）

-- 田中太郎のプロフィール
-- INSERT INTO profiles (id, username, total_xp, current_level, streak_count, created_at, updated_at)
-- VALUES ('TANAKA_USER_ID', '田中太郎', 2500, 5, 15, NOW(), NOW())
-- ON CONFLICT (id) DO UPDATE SET
--   username = EXCLUDED.username,
--   total_xp = EXCLUDED.total_xp,
--   current_level = EXCLUDED.current_level,
--   streak_count = EXCLUDED.streak_count,
--   updated_at = NOW();

-- 佐藤花子のプロフィール
-- INSERT INTO profiles (id, username, total_xp, current_level, streak_count, created_at, updated_at)
-- VALUES ('SATO_USER_ID', '佐藤花子', 3200, 6, 22, NOW(), NOW())
-- ON CONFLICT (id) DO UPDATE SET
--   username = EXCLUDED.username,
--   total_xp = EXCLUDED.total_xp,
--   current_level = EXCLUDED.current_level,
--   streak_count = EXCLUDED.streak_count,
--   updated_at = NOW();

-- 鈴木一郎のプロフィール  
-- INSERT INTO profiles (id, username, total_xp, current_level, streak_count, created_at, updated_at)
-- VALUES ('SUZUKI_USER_ID', '鈴木一郎', 1800, 3, 8, NOW(), NOW())
-- ON CONFLICT (id) DO UPDATE SET
--   username = EXCLUDED.username,
--   total_xp = EXCLUDED.total_xp,
--   current_level = EXCLUDED.current_level,
--   streak_count = EXCLUDED.streak_count,
--   updated_at = NOW();

-- 山田美香のプロフィール
-- INSERT INTO profiles (id, username, total_xp, current_level, streak_count, created_at, updated_at)
-- VALUES ('YAMADA_USER_ID', '山田美香', 1200, 2, 5, NOW(), NOW())
-- ON CONFLICT (id) DO UPDATE SET
--   username = EXCLUDED.username,
--   total_xp = EXCLUDED.total_xp,
--   current_level = EXCLUDED.current_level,
--   streak_count = EXCLUDED.streak_count,
--   updated_at = NOW();

-- 高橋健太のプロフィール
-- INSERT INTO profiles (id, username, total_xp, current_level, streak_count, created_at, updated_at)
-- VALUES ('TAKAHASHI_USER_ID', '高橋健太', 2100, 4, 12, NOW(), NOW())
-- ON CONFLICT (id) DO UPDATE SET
--   username = EXCLUDED.username,
--   total_xp = EXCLUDED.total_xp,
--   current_level = EXCLUDED.current_level,
--   streak_count = EXCLUDED.streak_count,
--   updated_at = NOW();

-- 5. 現在の権限確認クエリ
-- hey_show@icloud.comの権限を確認
SELECT 
    u.email,
    uor.role,
    o.name as organization_name,
    uor.created_at,
    uor.updated_at
FROM auth.users u
JOIN user_organization_roles uor ON u.id = uor.user_id
JOIN organizations o ON uor.organization_id = o.id
WHERE u.email = 'hey_show@icloud.com';

-- 組織内の全メンバーを確認
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