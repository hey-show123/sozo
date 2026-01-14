#!/bin/bash

# SOZOアプリ実装検証スクリプト
# 1. ストリーク機能（全レッスン完了時のみ更新）
# 2. AI会話セッションナビゲーション

echo "================================================"
echo "SOZO App Implementation Verification"
echo "================================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. データベース接続確認
echo "1. Checking database connection..."
echo "-----------------------------------"

# Supabase CLIを使用してデータベース接続を確認
if npx supabase db remote status 2>/dev/null | grep -q "Connected"; then
    echo -e "${GREEN}✓ Database connection successful${NC}"
else
    echo -e "${RED}✗ Database connection failed${NC}"
    echo "Please check your Supabase configuration"
    exit 1
fi

echo ""

# 2. ストリーク機能のテスト
echo "2. Testing Streak Functionality"
echo "--------------------------------"
echo "Testing that streak only updates when ALL activities are completed..."
echo ""

# SQLテストスクリプトを実行
echo "Running SQL test script..."
npx supabase db exec -f scripts/test_full_lesson_completion.sql

echo ""
echo -e "${YELLOW}Please verify in the output above:${NC}"
echo "- Streak should NOT change after individual activity completion"
echo "- Streak should ONLY update after the 6th (final) activity"
echo ""

# 3. Flutter アプリのビルド確認
echo "3. Checking Flutter App Build"
echo "------------------------------"

cd sozo_app

# ビルドチェック
echo "Running Flutter build check..."
if flutter analyze --no-fatal-infos 2>/dev/null; then
    echo -e "${GREEN}✓ No critical issues found${NC}"
else
    echo -e "${YELLOW}⚠ Some issues detected (non-critical)${NC}"
fi

echo ""

# 4. AI会話セッションナビゲーションのファイル確認
echo "4. Verifying AI Conversation Session Navigation Files"
echo "------------------------------------------------------"

# 必要なファイルの存在確認
files_to_check=(
    "lib/presentation/screens/lesson/ai_conversation_practice_screen.dart"
    "lib/presentation/screens/lesson/ai_conversation_structured_review.dart"
)

all_files_exist=true
for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file exists${NC}"
    else
        echo -e "${RED}✗ $file not found${NC}"
        all_files_exist=false
    fi
done

echo ""

# 5. 実装確認チェックリスト
echo "5. Implementation Verification Checklist"
echo "----------------------------------------"
echo ""
echo "Please manually verify the following in the running app:"
echo ""
echo -e "${YELLOW}Streak Functionality:${NC}"
echo "□ Open a lesson from the home screen"
echo "□ Complete vocabulary practice - check that streak does NOT update"
echo "□ Complete key phrase practice - check that streak does NOT update"
echo "□ Complete listening practice - check that streak does NOT update"
echo "□ Complete dialog practice - check that streak does NOT update"
echo "□ Complete application practice - check that streak does NOT update"
echo "□ Complete AI conversation - check that streak DOES update (all 6 complete)"
echo ""
echo -e "${YELLOW}AI Conversation Session Navigation:${NC}"
echo "□ Start AI conversation from HOME screen footer"
echo "  → Should show 'もう一度練習' and 'ホームへ' buttons after completion"
echo ""
echo "□ Start AI conversation from LESSON screen"
echo "  → Session 1 completion should show:"
echo "    - 'もう一度' (retry)"
echo "    - '完了' (complete)"
echo "    - '次のセッションへ→' (next session)"
echo "  → Session 2 completion should show same 3 buttons"
echo "  → Session 3 completion should show:"
echo "    - 'もう一度練習' (retry)"
echo "    - 'AI会話を完了' (complete AI conversation)"
echo ""

# 6. アプリ起動提案
echo "6. App Launch Command"
echo "---------------------"
echo ""
echo "To test the implementations, run the app with:"
echo -e "${GREEN}flutter run${NC}"
echo ""
echo "Or for iOS simulator:"
echo -e "${GREEN}flutter run -d iPhone${NC}"
echo ""
echo "Or for Android emulator:"
echo -e "${GREEN}flutter run -d emulator${NC}"
echo ""

cd ..

echo "================================================"
echo "Verification script completed"
echo "================================================"