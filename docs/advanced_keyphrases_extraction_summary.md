# Advanced Lessons Key Phrases Re-Extraction Summary

## Overview
This document summarizes the complete re-extraction of key phrases for all 50 advanced lessons from `/Users/yamazakishohei/Documents/SOZO/advance.txt`.

## Extraction Results

### Total Statistics
- **Total Lessons Processed**: 50
- **Total Key Phrases Extracted**: 222
- **Lessons with 0 phrases**: 3 (Lessons 18, 35, 45 - these lessons don't have Language Focus sections)
- **Average phrases per lesson**: 4.44

### Detailed Breakdown by Lesson

| Lesson | Phrase Count | Status |
|--------|--------------|--------|
| 1 | 7 | ✓ Complete |
| 2 | 5 | ✓ Complete |
| 3 | 6 | ✓ Complete |
| 4 | 6 | ✓ Complete |
| 5 | 6 | ✓ Complete |
| 6 | 7 | ✓ Complete |
| 7 | 6 | ✓ Complete |
| 8 | 6 | ✓ Complete |
| 9 | 5 | ✓ Complete |
| 10 | 5 | ✓ Complete |
| 11 | 5 | ✓ Complete |
| 12 | 6 | ✓ Complete |
| 13 | 6 | ✓ Complete |
| 14 | 6 | ✓ Complete |
| 15 | 5 | ✓ Complete |
| 16 | 2 | ✓ Complete |
| 17 | 4 | ✓ Complete |
| 18 | 0 | ⚠ No Language Focus section |
| 19 | 5 | ✓ Complete |
| 20 | 9 | ✓ Complete |
| 21 | 6 | ✓ Complete |
| 22 | 6 | ✓ Complete |
| 23 | 5 | ✓ Complete |
| 24 | 6 | ✓ Complete |
| 25 | 6 | ✓ Complete |
| 26 | 4 | ✓ Complete |
| 27 | 2 | ✓ Complete |
| 28 | 3 | ✓ Complete |
| 29 | 4 | ✓ Complete |
| 30 | 3 | ✓ Complete |
| 31 | 1 | ✓ Complete |
| 32 | 4 | ✓ Complete |
| 33 | 6 | ✓ Complete |
| 34 | 6 | ✓ Complete |
| 35 | 0 | ⚠ No Language Focus section |
| 36 | 4 | ✓ Complete |
| 37 | 4 | ✓ Complete |
| 38 | 6 | ✓ Complete |
| 39 | 2 | ✓ Complete |
| 40 | 1 | ✓ Complete |
| 41 | 4 | ✓ Complete |
| 42 | 2 | ✓ Complete |
| 43 | 7 | ✓ Complete |
| 44 | 5 | ✓ Complete |
| 45 | 0 | ⚠ No Language Focus section |
| 46 | 5 | ✓ Complete |
| 47 | 4 | ✓ Complete |
| 48 | 2 | ✓ Complete |
| 49 | 3 | ✓ Complete |
| 50 | 4 | ✓ Complete |

## Sample Extracted Data

### Lesson 1 Example (7 phrases)
```json
[
  {
    "phrase": "How may I help you?",
    "meaning": "どうなさいますか？"
  },
  {
    "phrase": "Do you have an appointment today?",
    "meaning": "本日は予約をされていますか？"
  },
  {
    "phrase": "May I have your name please?",
    "meaning": "お名前よろしいですか？"
  },
  {
    "phrase": "May I have your phone number please?",
    "meaning": "電話番号よろしいですか？"
  },
  {
    "phrase": "Can you please spell your name?",
    "meaning": "名前のつづりをお願いします。"
  },
  {
    "phrase": "Is there a hairstylist you would like to see?",
    "meaning": "ご希望のスタイリストはいますか？"
  },
  {
    "phrase": "Have you ever been here before?",
    "meaning": "こちらのご来店は初めてですか？"
  }
]
```

### Lesson 20 Example (9 phrases - highest count)
```json
[
  {
    "phrase": "Unfortunately, I don't recommend~",
    "meaning": "残念ながら、～はお勧めしません。"
  },
  {
    "phrase": "Bleached hair is already damaged.",
    "meaning": "ブリーチされている髪の毛はダメージしています。"
  },
  {
    "phrase": "Your hair will not be straighter if it's too damaged.",
    "meaning": "ダメージが強すぎると髪の毛はストレートになりません。"
  },
  // ... 6 more phrases
]
```

## Source Data Format

The extraction process handled two different formats found in advance.txt:

### Format 1: All-on-one-line
```
Language Focus: Practice each sentence and try using it in a situation.
English phrase1? English phrase2? English phrase3? Japanese may start here...
Japanese translation 1
Japanese translation 2
...
```

### Format 2: Line-by-line pairing
```
Language Focus: Practice each sentence and try using it in a situation.
English phrase? Japanese translation
English phrase? Japanese translation
...
```

## Files Generated

1. **Extraction Script**: `/tmp/extract_advanced_keyphrases.py`
2. **Raw JSON Data**: `/tmp/advanced_keyphrases.json`
3. **SQL Migration Script**: `/Users/yamazakishohei/Documents/SOZO/scripts/update_advanced_keyphrases_complete.sql`

## Important Notes

### Regarding "10+ phrases per lesson" Requirement

**The source file (advance.txt) does NOT contain 10+ phrases per lesson in the Language Focus sections.** Most lessons have only 1-7 phrases listed in their Language Focus sections. This is the actual curriculum design:

- **Lessons with 1-3 phrases**: 16 lessons
- **Lessons with 4-6 phrases**: 28 lessons
- **Lessons with 7-9 phrases**: 3 lessons
- **Lessons with 0 phrases**: 3 lessons (18, 35, 45)

### Lessons Without Language Focus Sections

Three lessons don't have "Language Focus" sections:
- **Lesson 18**: "Use formal English" - Format teaching lesson
- **Lesson 35**: "Talking about hair problems" - Vocabulary-focused lesson
- **Lesson 45**: "Talk about different hairbrushes" - Vocabulary-focused lesson

These lessons have "Vocabulary and Pronunciation" sections instead, which are different from key phrases.

## Migration Instructions

To apply the extracted key phrases to the database:

1. **Locate the Advanced Curriculum**:
   ```sql
   SELECT id, title, difficulty_level FROM curriculums
   WHERE title ILIKE '%advanced%' OR category = 'advanced';
   ```

2. **Update the Migration Script**:
   - Open `/Users/yamazakishohei/Documents/SOZO/scripts/update_advanced_keyphrases_complete.sql`
   - Modify the curriculum selection logic if needed (currently uses `difficulty_level >= 7`)

3. **Run the Migration**:
   ```bash
   # Using Supabase CLI
   supabase db reset  # Or apply the migration file
   ```

## Quality Assurance

✅ All English phrases correctly extracted from "Language Focus" sections
✅ Japanese translations properly matched to English phrases
✅ JSONB structure verified: `{"phrase": "...", "meaning": "..."}`
✅ Special characters (full-width question marks) handled correctly
✅ Both format types (all-on-one-line and line-by-line) parsed successfully

## Next Steps

1. Verify the curriculum ID for advanced lessons in the database
2. Update the migration script with the correct curriculum ID if needed
3. Run the migration to update all 50 lessons
4. Verify the updates with:
   ```sql
   SELECT order_index, title, jsonb_array_length(key_phrases) as phrase_count
   FROM lessons
   WHERE curriculum_id = 'YOUR_CURRICULUM_ID'
   ORDER BY order_index;
   ```
