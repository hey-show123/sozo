-- user_settingsテーブルの作成
CREATE TABLE IF NOT EXISTS user_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  daily_goal_minutes INT DEFAULT 30,
  daily_lesson_goal INT DEFAULT 2,
  notifications_enabled BOOLEAN DEFAULT true,
  reminder_enabled BOOLEAN DEFAULT true,
  reminder_time TIME DEFAULT '19:00',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- RLS（Row Level Security）を有効化
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- ポリシーの作成
-- ユーザーは自分の設定のみ参照・更新可能
CREATE POLICY "Users can view own settings" ON user_settings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own settings" ON user_settings
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings" ON user_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- インデックスの作成
CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);

-- updated_atを自動更新するトリガー
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc', now());
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON user_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 