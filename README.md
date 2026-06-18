# 💧 DrinkTracker — אפליקציית iOS למעקב משקאות + Apple Health

אפליקציית SwiftUI נייטיב למעקב אחרי כל המשקאות (מים, קפה, תה, מיץ, אלכוהול ועוד).
מחשבת אוטומטית קפאין, אלכוהול וסוכר, וכותבת אותם **ישירות לאפל בריאות** — בלי קיצורים.

**כולל:** טבעת התקדמות יומית · הוספה מהירה · סטטיסטיקות · **תרשים פירוט לפי סוג משקה** (Swift Charts) · יומן · גרף שבועי · **Widget למסך הבית**.

## דרישות
- **Mac עם Xcode 15+** (כדי לבנות ולהתקין).
- iPhone עם **iOS 16+** (מומלץ מכשיר אמיתי — HealthKit מוגבל מאוד בסימולטור).
- חשבון Apple חינמי מספיק כדי להריץ על המכשיר האישי שלך (7 ימים בכל פעם), או חשבון Developer בתשלום להתקנה קבועה.

## הקבצים
```
DrinkTracker-iOS/
├── Shared/
│   └── AppGroup.swift              ← אחסון משותף + תמונת מצב ל-Widget (שני היעדים!)
├── DrinkTracker/                   ← יעד האפליקציה
│   ├── DrinkTrackerApp.swift       ← נקודת הכניסה (RTL + בקשת הרשאת Health)
│   ├── Models.swift                ← קטלוג המשקאות + מבנה רשומה + חישובים
│   ├── Store.swift                 ← אחסון, כתיבה ל-Health, ריענון Widget, פירוט לפי משקה
│   ├── HealthKitManager.swift      ← כל הקריאות ל-HealthKit
│   ├── Theme.swift                 ← צבעים וסגנון כרטיסים
│   ├── ContentView.swift           ← כל המסכים (טבעת, הוספה, סטטיסטיקות, פירוט, יומן, שבועי)
│   ├── DrinkTracker.entitlements   ← יכולת HealthKit + App Group
│   └── Info-keys.plist             ← שני מפתחות פרטיות שצריך להוסיף ל-Info.plist
└── DrinkWidget/                    ← יעד ה-Widget
    ├── DrinkWidget.swift           ← ה-Widget (טבעת התקדמות + סיכום)
    └── DrinkWidget.entitlements    ← App Group (זהה לאפליקציה)
```

## 🚀 הרצה מהירה (מומלץ — שתי פקודות)

הדרך הקצרה ביותר להרצה. יוצרת אוטומטית פרויקט Xcode מלא עם שני היעדים, HealthKit וה-App Group:

```bash
# פעם אחת: התקנת הכלי (דורש Homebrew)
brew install xcodegen

# מתוך תיקיית DrinkTracker-iOS:
cd DrinkTracker-iOS
xcodegen generate
open DrinkTracker.xcodeproj
```

אחרי שהפרויקט נפתח ב-Xcode:
1. בחרו את ה-Target `DrinkTracker` ▸ **Signing & Capabilities** ▸ בחרו את ה-**Team** שלכם (Apple ID). חזרו על כך גם ל-Target של ה-Widget.
2. אם תרצו מזהה משלכם — החליפו את `com.yourcompany` ב-`project.yml`, בקבצי ה-`.entitlements` וב-`Shared/AppGroup.swift` (שיהיו זהים), והריצו שוב `xcodegen generate`.
3. חברו אייפון (או בחרו סימולטור — שימו לב ש-HealthKit כמעט לא עובד בסימולטור), ולחצו **Run** (⌘R).

> אם אין לכם Homebrew: התקינו מ-https://brew.sh , או השתמשו במסלול הידני שלמטה.

---

## בנייה ידנית צעד אחר צעד (חלופה ל-XcodeGen)

1. **צרו פרויקט חדש** ב-Xcode: `File ▸ New ▸ Project ▸ iOS ▸ App`.
   - Product Name: `DrinkTracker`
   - Interface: **SwiftUI**, Language: **Swift**.

2. **החליפו את קבצי המקור**: מחקו את `ContentView.swift` ואת קובץ ה-`App` שנוצרו אוטומטית,
   וגררו לפרויקט את כל קבצי ה-`.swift` מהתיקייה `DrinkTracker/` (ודאו ש-"Copy items if needed" מסומן).

3. **הפעילו את יכולת HealthKit**:
   - בחרו את ה-Target ▸ לשונית **Signing & Capabilities** ▸ `+ Capability` ▸ **HealthKit**.
   - פעולה זו יוצרת/מעדכנת את קובץ ה-entitlements. אפשר גם פשוט להשתמש בקובץ `DrinkTracker.entitlements` המצורף.

4. **הוסיפו את מחרוזות הפרטיות** (חובה, אחרת האפליקציה תקרוס בבקשת ההרשאה):
   - Target ▸ **Info** ▸ הוסיפו שני מפתחות מתוך `Info-keys.plist`:
     - `Privacy - Health Records Usage Description` (`NSHealthShareUsageDescription`)
     - `Privacy - Health Update Usage Description` (`NSHealthUpdateUsageDescription`)

5. **הגדירו חתימה (Signing)**: Target ▸ Signing & Capabilities ▸ בחרו את ה-Team שלכם (Apple ID).

6. **הוסיפו את `AppGroup.swift`** (מתיקיית `Shared/`) לפרויקט, וודאו שהוא שייך ל-Target של האפליקציה. (בהמשך נצרף אותו גם ל-Widget.)

7. **חברו אייפון**, בחרו אותו כיעד הרצה, ולחצו **Run** (⌘R).
   - בהרצה הראשונה האפליקציה תבקש הרשאה לכתוב לבריאות — אשרו את כל הסוגים.

---

## הוספת ה-Widget למסך הבית

1. **צרו App Group** (מאפשר לאפליקציה ול-Widget לשתף נתונים):
   - Target של האפליקציה ▸ Signing & Capabilities ▸ `+ Capability` ▸ **App Groups** ▸ `+` ▸ הזינו מזהה, למשל `group.com.yourcompany.DrinkTracker`.
   - עדכנו את אותו מזהה בקובץ `Shared/AppGroup.swift` (השדה `AppGroup.id`).

2. **צרו Widget Extension**: `File ▸ New ▸ Target ▸ Widget Extension`.
   - שם: `DrinkWidget`. **בטלו** את הסימון של "Include Configuration Intent".
   - מחקו את קובץ ה-`.swift` שנוצר אוטומטית, וגררו במקומו את `DrinkWidget/DrinkWidget.swift`.

3. **שתפו קבצים בין היעדים**:
   - בחרו את `Shared/AppGroup.swift` ▸ ב-File Inspector ▸ **Target Membership** ▸ סמנו גם את `DrinkTracker` וגם את `DrinkWidgetExtension`.

4. **הוסיפו App Group ל-Widget**: Target של ה-Widget ▸ Signing & Capabilities ▸ `+ Capability` ▸ **App Groups** ▸ סמנו את אותו מזהה.

5. **Run** מחדש. הוסיפו את ה-Widget למסך הבית (לחיצה ארוכה ▸ `+` ▸ חפשו "מעקב שתייה"). הוא יתעדכן אוטומטית בכל פעם שתוסיפו שתייה.

## מה נכתב לאפל בריאות
| במשקה          | סוג נתון ב-Health                | יחידה  |
|----------------|----------------------------------|--------|
| מים            | Dietary Water                    | מ"ל    |
| קפאין          | Dietary Caffeine                 | מ"ג    |
| סוכר           | Dietary Sugar                    | גרם    |
| אלכוהול        | Number of Alcoholic Beverages    | מנות   |

- כל שתייה נכתבת לבריאות בשעה שבה הוזנה. מחיקת שתייה מהיומן מנסה למחוק גם את הדגימות מ-Health.
- **מנה תקנית** = 14 גרם אלכוהול טהור (תקן Apple). בירה 330 מ"ל ≈ 0.9 מנות, כוס יין ≈ 1 מנה.
- ערכי הקפאין/הסוכר הם **הערכות ממוצעות** לפי סוג וכמות, לא מדידת המוצר הספציפי.

## התאמה אישית
- לשינוי רשימת המשקאות או הערכים התזונתיים — ערכו את `Catalog.drinks` בקובץ `Models.swift`.
- לשינוי הכפתורים המהירים — ערכו את `Catalog.quickIDs`.
