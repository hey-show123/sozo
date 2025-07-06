-- レッスン29に応用練習データを追加
UPDATE lessons
SET metadata = jsonb_set(
  COALESCE(metadata, '{}'::jsonb),
  '{application_practices}',
  '[
    {
      "practice_id": "app_001",
      "target_phrase": "Would you like to do a ~ as well?",
      "hint": "カットはいかがですか？",
      "example": "Would you like to do a cut as well?",
      "tips": ["as wellは「〜も」という意味", "丁寧な提案の表現"]
    },
    {
      "practice_id": "app_002",
      "target_phrase": "Would you like to try ~?",
      "hint": "新しいヘアスタイルを試してみませんか？",
      "example": "Would you like to try a new hairstyle?",
      "tips": ["tryは「試す」という意味", "提案や勧誘の表現"]
    },
    {
      "practice_id": "app_003",
      "target_phrase": "Would you like me to ~?",
      "hint": "髪を短くしましょうか？",
      "example": "Would you like me to make it shorter?",
      "tips": ["私が〜しましょうか？という申し出", "サービス業でよく使う表現"]
    }
  ]'::jsonb
)
WHERE id = 'lesson_029';

-- 他のレッスンにもサンプルデータを追加
UPDATE lessons
SET metadata = jsonb_set(
  COALESCE(metadata, '{}'::jsonb),
  '{application_practices}',
  '[
    {
      "practice_id": "app_default_001",
      "target_phrase": "Can I ~ please?",
      "hint": "メニューをいただけますか？",
      "example": "Can I have the menu please?",
      "tips": ["丁寧な依頼の表現", "pleaseを付けてより丁寧に"]
    },
    {
      "practice_id": "app_default_002",
      "target_phrase": "I would like to ~",
      "hint": "予約したいのですが",
      "example": "I would like to make a reservation",
      "tips": ["フォーマルな希望の表現", "I want toより丁寧"]
    }
  ]'::jsonb
)
WHERE id != 'lesson_029' 
AND metadata IS DISTINCT FROM NULL
AND NOT (metadata ? 'application_practices');

-- 確認用クエリ
SELECT 
  id,
  title,
  metadata->'application_practices' as application_practices
FROM lessons
WHERE metadata ? 'application_practices'
ORDER BY id; 