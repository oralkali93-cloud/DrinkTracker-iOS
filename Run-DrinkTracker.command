#!/bin/bash
# לחיצה כפולה על הקובץ הזה תכין ותפתח את הפרויקט ב-Xcode — בלי להקליד כלום.
# (בפעם הראשונה ייתכן ש-macOS יחסום: לחצו קליק-ימני ▸ Open ▸ Open.)

cd "$(dirname "$0")" || exit 1
echo "📦 מכין את פרויקט DrinkTracker..."
echo "תיקייה: $(pwd)"
echo

# 1) ודא ש-xcodegen קיים, אחרת התקן דרך Homebrew
if ! command -v xcodegen >/dev/null 2>&1; then
  # נסה נתיבי Homebrew נפוצים (Apple Silicon / Intel)
  export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "⏳ מתקין xcodegen דרך Homebrew (פעם אחת)..."
    brew install xcodegen || { echo "❌ ההתקנה נכשלה."; read -r -p "Enter לסגירה..."; exit 1; }
  else
    echo "❌ Homebrew לא מותקן."
    echo "   התקינו אותו מ- https://brew.sh ואז הריצו שוב את הקובץ הזה."
    read -r -p "Enter לסגירה..."
    exit 1
  fi
fi

# 2) צור את הפרויקט
echo "⚙️  יוצר את DrinkTracker.xcodeproj..."
xcodegen generate || { echo "❌ יצירת הפרויקט נכשלה."; read -r -p "Enter לסגירה..."; exit 1; }

# 3) פתח ב-Xcode
echo "🚀 פותח ב-Xcode..."
open DrinkTracker.xcodeproj

echo
echo "✅ הפרויקט נפתח ב-Xcode."
echo "   נותר רק: בחרו את ה-Team שלכם תחת Target ▸ Signing & Capabilities"
echo "   (גם לאפליקציה וגם ל-Widget), חברו את האייפון, ולחצו Run (⌘R)."
read -r -p "אפשר לסגור את החלון הזה (Enter)..."
