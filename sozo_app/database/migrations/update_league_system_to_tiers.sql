-- プロファイルテーブルに現在のリーグを保存するカラムを追加（存在しない場合）
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS current_league text DEFAULT 'bronze_3';

-- weekly_leaderboardテーブルのleagueカラムを更新
ALTER TABLE weekly_leaderboard ADD COLUMN IF NOT EXISTS user_total_xp integer DEFAULT 0;

-- ユーザーの総XPに基づいてリーグを計算する関数
CREATE OR REPLACE FUNCTION calculate_user_league(p_total_xp integer)
RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
  IF p_total_xp >= 100000 THEN RETURN 'legend_1';
  ELSIF p_total_xp >= 75000 THEN RETURN 'legend_2';
  ELSIF p_total_xp >= 50000 THEN RETURN 'legend_3';
  ELSIF p_total_xp >= 30000 THEN RETURN 'gold_1';
  ELSIF p_total_xp >= 20000 THEN RETURN 'gold_2';
  ELSIF p_total_xp >= 15000 THEN RETURN 'gold_3';
  ELSIF p_total_xp >= 10000 THEN RETURN 'silver_1';
  ELSIF p_total_xp >= 7500 THEN RETURN 'silver_2';
  ELSIF p_total_xp >= 5000 THEN RETURN 'silver_3';
  ELSIF p_total_xp >= 2500 THEN RETURN 'bronze_1';
  ELSIF p_total_xp >= 1000 THEN RETURN 'bronze_2';
  ELSE RETURN 'bronze_3';
  END IF;
END;
$$;

-- 週間ランキングを更新する関数を修正
CREATE OR REPLACE FUNCTION update_weekly_leaderboard()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_week_start date;
BEGIN
  v_week_start := date_trunc('week', CURRENT_DATE - INTERVAL '1 day')::date;
  
  -- 既存のエントリを更新または新規作成
  INSERT INTO weekly_leaderboard (user_id, week_start, week_xp, league, user_total_xp, updated_at)
  SELECT 
    p.user_id,
    v_week_start,
    COALESCE(SUM(
      CASE 
        WHEN lr.completed_at >= v_week_start 
        AND lr.completed_at < v_week_start + INTERVAL '7 days' 
        THEN lr.xp_earned 
        ELSE 0 
      END
    ), 0) as week_xp,
    calculate_user_league(p.total_xp) as league,
    p.total_xp as user_total_xp,
    NOW()
  FROM profiles p
  LEFT JOIN lesson_results lr ON p.user_id = lr.user_id
  GROUP BY p.user_id, p.total_xp
  ON CONFLICT (user_id, week_start) 
  DO UPDATE SET 
    week_xp = EXCLUDED.week_xp,
    league = EXCLUDED.league,
    user_total_xp = EXCLUDED.user_total_xp,
    previous_rank = weekly_leaderboard.current_rank,
    updated_at = NOW();
  
  -- ランクを更新
  WITH ranked_users AS (
    SELECT 
      user_id,
      RANK() OVER (PARTITION BY league ORDER BY week_xp DESC) as new_rank
    FROM weekly_leaderboard
    WHERE week_start = v_week_start
  )
  UPDATE weekly_leaderboard wl
  SET current_rank = ru.new_rank
  FROM ranked_users ru
  WHERE wl.user_id = ru.user_id
    AND wl.week_start = v_week_start;
    
  -- プロファイルの現在のリーグを更新
  UPDATE profiles p
  SET current_league = calculate_user_league(p.total_xp)
  WHERE EXISTS (
    SELECT 1 FROM weekly_leaderboard wl 
    WHERE wl.user_id = p.user_id 
    AND wl.week_start = v_week_start
  );
END;
$$; 

-- ユーザーの週間ランク情報を取得する関数を修正
CREATE OR REPLACE FUNCTION get_user_weekly_rank(p_user_id uuid)
RETURNS TABLE (
  rank integer,
  score integer,
  total_users integer,
  percentile numeric,
  league text,
  league_icon text,
  league_color text,
  next_league text,
  xp_to_next_league integer
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_week_start date;
  v_user_league text;
  v_user_total_xp integer;
  v_current_league_min_xp integer;
  v_current_league_max_xp integer;
BEGIN
  v_week_start := date_trunc('week', CURRENT_DATE - INTERVAL '1 day')::date;
  
  -- ユーザーの総XPとリーグを取得
  SELECT total_xp, calculate_user_league(total_xp) 
  INTO v_user_total_xp, v_user_league
  FROM profiles 
  WHERE user_id = p_user_id;
  
  -- 現在のリーグのXP範囲を取得
  SELECT 
    CASE 
      WHEN v_user_league = 'bronze_3' THEN 0
      WHEN v_user_league = 'bronze_2' THEN 500
      WHEN v_user_league = 'bronze_1' THEN 1000
      WHEN v_user_league = 'bronze_elite_3' THEN 2000
      WHEN v_user_league = 'bronze_elite_2' THEN 3000
      WHEN v_user_league = 'bronze_elite_1' THEN 4000
      WHEN v_user_league = 'silver_3' THEN 5000
      WHEN v_user_league = 'silver_2' THEN 7000
      WHEN v_user_league = 'silver_1' THEN 9000
      WHEN v_user_league = 'silver_elite_3' THEN 12000
      WHEN v_user_league = 'silver_elite_2' THEN 15000
      WHEN v_user_league = 'silver_elite_1' THEN 18000
      WHEN v_user_league = 'gold_3' THEN 22000
      WHEN v_user_league = 'gold_2' THEN 26000
      WHEN v_user_league = 'gold_1' THEN 30000
      WHEN v_user_league = 'gold_elite_3' THEN 35000
      WHEN v_user_league = 'gold_elite_2' THEN 40000
      WHEN v_user_league = 'gold_elite_1' THEN 45000
      WHEN v_user_league = 'legend_3' THEN 50000
      WHEN v_user_league = 'legend_2' THEN 60000
      WHEN v_user_league = 'legend_1' THEN 75000
      WHEN v_user_league = 'legend_elite_3' THEN 100000
      WHEN v_user_league = 'legend_elite_2' THEN 125000
      WHEN v_user_league = 'legend_elite_1' THEN 150000
    END,
    CASE 
      WHEN v_user_league = 'bronze_3' THEN 500
      WHEN v_user_league = 'bronze_2' THEN 1000
      WHEN v_user_league = 'bronze_1' THEN 2000
      WHEN v_user_league = 'bronze_elite_3' THEN 3000
      WHEN v_user_league = 'bronze_elite_2' THEN 4000
      WHEN v_user_league = 'bronze_elite_1' THEN 5000
      WHEN v_user_league = 'silver_3' THEN 7000
      WHEN v_user_league = 'silver_2' THEN 9000
      WHEN v_user_league = 'silver_1' THEN 12000
      WHEN v_user_league = 'silver_elite_3' THEN 15000
      WHEN v_user_league = 'silver_elite_2' THEN 18000
      WHEN v_user_league = 'silver_elite_1' THEN 22000
      WHEN v_user_league = 'gold_3' THEN 26000
      WHEN v_user_league = 'gold_2' THEN 30000
      WHEN v_user_league = 'gold_1' THEN 35000
      WHEN v_user_league = 'gold_elite_3' THEN 40000
      WHEN v_user_league = 'gold_elite_2' THEN 45000
      WHEN v_user_league = 'gold_elite_1' THEN 50000
      WHEN v_user_league = 'legend_3' THEN 60000
      WHEN v_user_league = 'legend_2' THEN 75000
      WHEN v_user_league = 'legend_1' THEN 100000
      WHEN v_user_league = 'legend_elite_3' THEN 125000
      WHEN v_user_league = 'legend_elite_2' THEN 150000
      WHEN v_user_league = 'legend_elite_1' THEN 999999999
    END
  INTO v_current_league_min_xp, v_current_league_max_xp;
  
  RETURN QUERY
  WITH user_stats AS (
    SELECT 
      wl.user_id,
      wl.week_xp,
      RANK() OVER (PARTITION BY wl.league ORDER BY wl.week_xp DESC) as league_rank,
      COUNT(*) OVER (PARTITION BY wl.league) as league_total
    FROM weekly_leaderboard wl
    WHERE wl.week_start = v_week_start
      AND wl.league = v_user_league
  )
  SELECT 
    COALESCE(us.league_rank, 0)::integer as rank,
    COALESCE(us.week_xp, 0)::integer as score,
    COALESCE(us.league_total, 0)::integer as total_users,
    CASE 
      WHEN us.league_total > 0 THEN ((us.league_total - us.league_rank + 1)::numeric / us.league_total * 100)
      ELSE 0
    END as percentile,
    v_user_league as league,
    v_user_league as league_icon, -- アプリ側でアセットパスに変換
    CASE 
      WHEN v_user_league LIKE 'bronze%' THEN '#CD7F32'
      WHEN v_user_league LIKE 'silver%' THEN '#C0C0C0'
      WHEN v_user_league LIKE 'gold%' THEN '#FFD700'
      WHEN v_user_league LIKE 'legend%' THEN '#2B2B2B'
      ELSE '#CD7F32'
    END as league_color,
    CASE 
      WHEN v_user_league = 'bronze_3' THEN 'bronze_2'
      WHEN v_user_league = 'bronze_2' THEN 'bronze_1'
      WHEN v_user_league = 'bronze_1' THEN 'bronze_elite_3'
      WHEN v_user_league = 'bronze_elite_3' THEN 'bronze_elite_2'
      WHEN v_user_league = 'bronze_elite_2' THEN 'bronze_elite_1'
      WHEN v_user_league = 'bronze_elite_1' THEN 'silver_3'
      WHEN v_user_league = 'silver_3' THEN 'silver_2'
      WHEN v_user_league = 'silver_2' THEN 'silver_1'
      WHEN v_user_league = 'silver_1' THEN 'silver_elite_3'
      WHEN v_user_league = 'silver_elite_3' THEN 'silver_elite_2'
      WHEN v_user_league = 'silver_elite_2' THEN 'silver_elite_1'
      WHEN v_user_league = 'silver_elite_1' THEN 'gold_3'
      WHEN v_user_league = 'gold_3' THEN 'gold_2'
      WHEN v_user_league = 'gold_2' THEN 'gold_1'
      WHEN v_user_league = 'gold_1' THEN 'gold_elite_3'
      WHEN v_user_league = 'gold_elite_3' THEN 'gold_elite_2'
      WHEN v_user_league = 'gold_elite_2' THEN 'gold_elite_1'
      WHEN v_user_league = 'gold_elite_1' THEN 'legend_3'
      WHEN v_user_league = 'legend_3' THEN 'legend_2'
      WHEN v_user_league = 'legend_2' THEN 'legend_1'
      WHEN v_user_league = 'legend_1' THEN 'legend_elite_3'
      WHEN v_user_league = 'legend_elite_3' THEN 'legend_elite_2'
      WHEN v_user_league = 'legend_elite_2' THEN 'legend_elite_1'
      ELSE NULL
    END as next_league,
    GREATEST(0, v_current_league_max_xp - v_user_total_xp)::integer as xp_to_next_league
  FROM user_stats us
  WHERE us.user_id = p_user_id
  UNION ALL
  SELECT 
    0,
    0,
    0,
    0.0,
    v_user_league,
    v_user_league,
    CASE 
      WHEN v_user_league LIKE 'bronze%' THEN '#CD7F32'
      WHEN v_user_league LIKE 'silver%' THEN '#C0C0C0'
      WHEN v_user_league LIKE 'gold%' THEN '#FFD700'
      WHEN v_user_league LIKE 'legend%' THEN '#2B2B2B'
      ELSE '#CD7F32'
    END,
    CASE 
      WHEN v_user_league = 'bronze_3' THEN 'bronze_2'
      WHEN v_user_league = 'bronze_2' THEN 'bronze_1'
      WHEN v_user_league = 'bronze_1' THEN 'bronze_elite_3'
      WHEN v_user_league = 'bronze_elite_3' THEN 'bronze_elite_2'
      WHEN v_user_league = 'bronze_elite_2' THEN 'bronze_elite_1'
      WHEN v_user_league = 'bronze_elite_1' THEN 'silver_3'
      WHEN v_user_league = 'silver_3' THEN 'silver_2'
      WHEN v_user_league = 'silver_2' THEN 'silver_1'
      WHEN v_user_league = 'silver_1' THEN 'silver_elite_3'
      WHEN v_user_league = 'silver_elite_3' THEN 'silver_elite_2'
      WHEN v_user_league = 'silver_elite_2' THEN 'silver_elite_1'
      WHEN v_user_league = 'silver_elite_1' THEN 'gold_3'
      WHEN v_user_league = 'gold_3' THEN 'gold_2'
      WHEN v_user_league = 'gold_2' THEN 'gold_1'
      WHEN v_user_league = 'gold_1' THEN 'gold_elite_3'
      WHEN v_user_league = 'gold_elite_3' THEN 'gold_elite_2'
      WHEN v_user_league = 'gold_elite_2' THEN 'gold_elite_1'
      WHEN v_user_league = 'gold_elite_1' THEN 'legend_3'
      WHEN v_user_league = 'legend_3' THEN 'legend_2'
      WHEN v_user_league = 'legend_2' THEN 'legend_1'
      WHEN v_user_league = 'legend_1' THEN 'legend_elite_3'
      WHEN v_user_league = 'legend_elite_3' THEN 'legend_elite_2'
      WHEN v_user_league = 'legend_elite_2' THEN 'legend_elite_1'
      ELSE NULL
    END,
    GREATEST(0, v_current_league_max_xp - v_user_total_xp)
  WHERE NOT EXISTS (
    SELECT 1 FROM weekly_leaderboard wl 
    WHERE wl.user_id = p_user_id 
    AND wl.week_start = v_week_start
  )
  LIMIT 1;
END;
$$; 