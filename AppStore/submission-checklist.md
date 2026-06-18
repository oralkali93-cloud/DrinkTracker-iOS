# ✅ צ'ק-ליסט העלאה ל-App Store

מה שכבר מוכן בפרויקט, ומה שצריך לעשות בעצמך (הגשה דורשת התחברות לחשבון Apple שלך — את זה רק אתה יכול לעשות).

## מה כבר מוכן ✅
- קוד האפליקציה + Widget, חתימה אוטומטית עם ה-Team שלך (`9BP8G56Q79`)
- Bundle ID ייחודי: `com.oralkalay.DrinkTracker`
- אייקון אפליקציה 1024×1024 (`Assets.xcassets/AppIcon`)
- מדיניות פרטיות (`privacy-policy.md`) + מטא-דאטה (`metadata.md`)

## שלב 0 — רענון הפרויקט
הרץ שוב את `Run-DrinkTracker.command` (לחיצה כפולה) כדי שה-icon וה-Bundle ID החדש ייכנסו לפרויקט.

## שלב 1 — ארח את מדיניות הפרטיות 🌐
App Store **חוסם** אפליקציות HealthKit בלי קישור מדיניות פרטיות.
- העלה את `privacy-policy.md` לדף ציבורי (GitHub Pages / Notion public / אתר). שמור את ה-URL.

## שלב 2 — צור את האפליקציה ב-App Store Connect
1. היכנס ל-https://appstoreconnect.apple.com (עם ה-Apple ID שלך).
2. My Apps → ➕ → New App. בחר iOS, שם, שפה ראשית (עברית), Bundle ID = `com.oralkalay.DrinkTracker`, SKU כלשהו.
3. מלא את השדות מתוך `metadata.md` (תיאור, keywords, קטגוריה, Support URL, Privacy Policy URL).
4. מלא **App Privacy** = "Data Not Collected", ו-**Age Rating** (ענה על שאלת האלכוהול).

## שלב 3 — צילומי מסך 📸 (חובה)
Apple דורשת לפחות סט אחד. הכי קל: סימולטור iPhone 6.7" (למשל iPhone 15 Pro Max).
- הרץ באפליקציה בסימולטור, הוסף כמה שתיות, ‎⌘S לצילום מסך.
- גדלים נדרשים: **6.7"** (1290×2796) ו-**6.5"** (1242×2688). מינימום 1 לכל גודל, עד 10.

## שלב 4 — Archive והעלאה ⬆️ (ב-Xcode)
1. ב-Xcode בורר היעד למעלה: בחר **Any iOS Device (arm64)** (לא סימולטור).
2. תפריט **Product → Archive**. המתן לסיום.
3. בחלון ה-Organizer שנפתח: **Distribute App → App Store Connect → Upload**. עקוב עד Done.
4. ההעלאה מופיעה ב-App Store Connect תוך ~5–15 דקות (אחרי "Processing").

## שלב 5 — שלח לבדיקה
1. ב-App Store Connect, במסך הגרסה, תחת **Build** בחר את ה-build שהעלית.
2. הדבק **Review Notes** מתוך `metadata.md`.
3. **Add for Review → Submit**. הבדיקה אורכת בד"כ יום-שלושה.

---
### מה אני (Claude) יכול ולא יכול לעשות
- ✅ הכנתי: קוד, אייקון, מטא-דאטה, מדיניות פרטיות, הגדרות חתימה, וצ'ק-ליסט.
- ✅ אני יכול להדריך אותך על המסך בשלב ה-Archive (לחיצות).
- ❌ אני **לא** יכול להתחבר לחשבון Apple שלך, להזין סיסמאות, או ללחוץ "Submit" בשמך — העלאה/פרסום והתחברות הם פעולות שרק אתה מבצע, ואני גם חסום מהקלדה בתוך Xcode.
