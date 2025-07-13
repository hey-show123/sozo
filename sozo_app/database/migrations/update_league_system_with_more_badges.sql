-- ユーザーの総XPに基づいてリーグを計算する関数を更新
CREATE OR REPLACE FUNCTION calculate_user_league(p_total_xp integer)
RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
  IF p_total_xp >= 150000 THEN RETURN 'legend_elite_1';
  ELSIF p_total_xp >= 125000 THEN RETURN 'legend_elite_2';
  ELSIF p_total_xp >= 100000 THEN RETURN 'legend_elite_3';
  ELSIF p_total_xp >= 75000 THEN RETURN 'legend_1';
  ELSIF p_total_xp >= 60000 THEN RETURN 'legend_2';
  ELSIF p_total_xp >= 50000 THEN RETURN 'legend_3';
  ELSIF p_total_xp >= 45000 THEN RETURN 'gold_elite_1';
  ELSIF p_total_xp >= 40000 THEN RETURN 'gold_elite_2';
  ELSIF p_total_xp >= 35000 THEN RETURN 'gold_elite_3';
  ELSIF p_total_xp >= 30000 THEN RETURN 'gold_1';
  ELSIF p_total_xp >= 26000 THEN RETURN 'gold_2';
  ELSIF p_total_xp >= 22000 THEN RETURN 'gold_3';
  ELSIF p_total_xp >= 18000 THEN RETURN 'silver_elite_1';
  ELSIF p_total_xp >= 15000 THEN RETURN 'silver_elite_2';
  ELSIF p_total_xp >= 12000 THEN RETURN 'silver_elite_3';
  ELSIF p_total_xp >= 9000 THEN RETURN 'silver_1';
  ELSIF p_total_xp >= 7000 THEN RETURN 'silver_2';
  ELSIF p_total_xp >= 5000 THEN RETURN 'silver_3';
  ELSIF p_total_xp >= 4000 THEN RETURN 'bronze_elite_1';
  ELSIF p_total_xp >= 3000 THEN RETURN 'bronze_elite_2';
  ELSIF p_total_xp >= 2000 THEN RETURN 'bronze_elite_3';
  ELSIF p_total_xp >= 1000 THEN RETURN 'bronze_1';
  ELSIF p_total_xp >= 500 THEN RETURN 'bronze_2';
  ELSE RETURN 'bronze_3';
  END IF;
END;
$$;

-- テストアカウント用のデータを作成
DO $$
DECLARE
  v_user_id uuid;
  v_week_start date;
BEGIN
  v_week_start := date_trunc('week', CURRENT_DATE - INTERVAL '1 day')::date;
  
  -- テストユーザー1: Bronze Elite III (2,500 XP)
  v_user_id := gen_random_uuid();
  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
  VALUES (v_user_id, 'test_bronze_elite@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW())
  ON CONFLICT (email) DO UPDATE SET id = EXCLUDED.id RETURNING id INTO v_user_id;
  
  INSERT INTO profiles (user_id, display_name, username, total_xp, current_level, streak_count, created_at, updated_at)
  VALUES (v_user_id, 'Bronze Elite Player', 'bronze_elite_test', 2500, 3, 7, NOW(), NOW())
  ON CONFLICT (user_id) DO UPDATE SET 
    total_xp = EXCLUDED.total_xp,
    current_level = EXCLUDED.current_level,
    display_name = EXCLUDED.display_name;
    
  INSERT INTO weekly_leaderboard (user_id, week_start, week_xp, league, user_total_xp)
  VALUES (v_user_id, v_week_start, 500, calculate_user_league(2500), 2500)
  ON CONFLICT (user_id, week_start) DO UPDATE SET 
    week_xp = EXCLUDED.week_xp,
    league = EXCLUDED.league,
    user_total_xp = EXCLUDED.user_total_xp;
  
  -- テストユーザー2: Silver Elite II (16,000 XP)
  v_user_id := gen_random_uuid();
  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
  VALUES (v_user_id, 'test_silver_elite@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW())
  ON CONFLICT (email) DO UPDATE SET id = EXCLUDED.id RETURNING id INTO v_user_id;
  
  INSERT INTO profiles (user_id, display_name, username, total_xp, current_level, streak_count, created_at, updated_at)
  VALUES (v_user_id, 'Silver Elite Master', 'silver_elite_test', 16000, 16, 15, NOW(), NOW())
  ON CONFLICT (user_id) DO UPDATE SET 
    total_xp = EXCLUDED.total_xp,
    current_level = EXCLUDED.current_level,
    display_name = EXCLUDED.display_name;
    
  INSERT INTO weekly_leaderboard (user_id, week_start, week_xp, league, user_total_xp)
  VALUES (v_user_id, v_week_start, 1200, calculate_user_league(16000), 16000)
  ON CONFLICT (user_id, week_start) DO UPDATE SET 
    week_xp = EXCLUDED.week_xp,
    league = EXCLUDED.league,
    user_total_xp = EXCLUDED.user_total_xp;
  
  -- テストユーザー3: Gold Elite I (48,000 XP)
  v_user_id := gen_random_uuid();
  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
  VALUES (v_user_id, 'test_gold_elite@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW())
  ON CONFLICT (email) DO UPDATE SET id = EXCLUDED.id RETURNING id INTO v_user_id;
  
  INSERT INTO profiles (user_id, display_name, username, total_xp, current_level, streak_count, created_at, updated_at)
  VALUES (v_user_id, 'Gold Elite Champion', 'gold_elite_test', 48000, 48, 30, NOW(), NOW())
  ON CONFLICT (user_id) DO UPDATE SET 
    total_xp = EXCLUDED.total_xp,
    current_level = EXCLUDED.current_level,
    display_name = EXCLUDED.display_name;
    
  INSERT INTO weekly_leaderboard (user_id, week_start, week_xp, league, user_total_xp)
  VALUES (v_user_id, v_week_start, 2500, calculate_user_league(48000), 48000)
  ON CONFLICT (user_id, week_start) DO UPDATE SET 
    week_xp = EXCLUDED.week_xp,
    league = EXCLUDED.league,
    user_total_xp = EXCLUDED.user_total_xp;
  
  -- テストユーザー4: Legend Elite II (130,000 XP)
  v_user_id := gen_random_uuid();
  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
  VALUES (v_user_id, 'test_legend_elite@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW())
  ON CONFLICT (email) DO UPDATE SET id = EXCLUDED.id RETURNING id INTO v_user_id;
  
  INSERT INTO profiles (user_id, display_name, username, total_xp, current_level, streak_count, created_at, updated_at)
  VALUES (v_user_id, 'Legend Elite Master', 'legend_elite_test', 130000, 130, 60, NOW(), NOW())
  ON CONFLICT (user_id) DO UPDATE SET 
    total_xp = EXCLUDED.total_xp,
    current_level = EXCLUDED.current_level,
    display_name = EXCLUDED.display_name;
    
  INSERT INTO weekly_leaderboard (user_id, week_start, week_xp, league, user_total_xp)
  VALUES (v_user_id, v_week_start, 5000, calculate_user_league(130000), 130000)
  ON CONFLICT (user_id, week_start) DO UPDATE SET 
    week_xp = EXCLUDED.week_xp,
    league = EXCLUDED.league,
    user_total_xp = EXCLUDED.user_total_xp;
    
  -- 追加のランダムユーザーを各リーグに作成
  FOR i IN 1..5 LOOP
    -- Bronze users
    v_user_id := gen_random_uuid();
    INSERT INTO profiles (user_id, display_name, username, total_xp, current_level, streak_count, created_at, updated_at)
    VALUES (v_user_id, 'Bronze Player ' || i, 'bronze_' || i, (random() * 1000)::int, 1, (random() * 5)::int, NOW(), NOW());
    
    INSERT INTO weekly_leaderboard (user_id, week_start, week_xp, league, user_total_xp)
    VALUES (v_user_id, v_week_start, (random() * 300)::int, calculate_user_league((random() * 1000)::int), (random() * 1000)::int);
    
    -- Silver users
    v_user_id := gen_random_uuid();
    INSERT INTO profiles (user_id, display_name, username, total_xp, current_level, streak_count, created_at, updated_at)
    VALUES (v_user_id, 'Silver Player ' || i, 'silver_' || i, 5000 + (random() * 7000)::int, 6 + i, (random() * 10)::int, NOW(), NOW());
    
    INSERT INTO weekly_leaderboard (user_id, week_start, week_xp, league, user_total_xp)
    VALUES (v_user_id, v_week_start, (random() * 800)::int, calculate_user_league(5000 + (random() * 7000)::int), 5000 + (random() * 7000)::int);
    
    -- Gold users
    v_user_id := gen_random_uuid();
    INSERT INTO profiles (user_id, display_name, username, total_xp, current_level, streak_count, created_at, updated_at)
    VALUES (v_user_id, 'Gold Player ' || i, 'gold_' || i, 22000 + (random() * 28000)::int, 25 + i, (random() * 20)::int, NOW(), NOW());
    
    INSERT INTO weekly_leaderboard (user_id, week_start, week_xp, league, user_total_xp)
    VALUES (v_user_id, v_week_start, (random() * 1500)::int, calculate_user_league(22000 + (random() * 28000)::int), 22000 + (random() * 28000)::int);
  END LOOP;
END $$; 