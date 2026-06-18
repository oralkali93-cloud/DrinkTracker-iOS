import Foundation

/// משותף בין האפליקציה ל-Widget. הוסיפו את הקובץ הזה ל-Target Membership של *שני* היעדים.
enum AppGroup {
    /// ⚠️ עדכנו למזהה ה-App Group שיצרתם (חייב להיות זהה באפליקציה וב-Widget).
    static let id = "group.com.yourcompany.DrinkTracker"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: id) ?? .standard
    }

    static let snapshotKey = "widgetSnapshot_v1"

    private static let dayFmt: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    static func dayKey(_ date: Date = Date()) -> String { dayFmt.string(from: date) }
}

/// תמונת מצב קלת-משקל שה-Widget קורא (בלי תלות בלוגיקת האפליקציה).
struct WidgetSnapshot: Codable {
    var dateKey: String
    var volume: Double
    var goal: Double
    var water: Double
    var caffeine: Double
    var sugar: Double
    var drinks: Double

    static let empty = WidgetSnapshot(dateKey: "", volume: 0, goal: 2500, water: 0, caffeine: 0, sugar: 0, drinks: 0)

    static func load() -> WidgetSnapshot {
        guard let data = AppGroup.defaults.data(forKey: AppGroup.snapshotKey),
              let s = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else { return .empty }
        // אם התמונה היא מיום אחר — מציגים 0 להיום אבל שומרים את היעד.
        if s.dateKey != AppGroup.dayKey() {
            return WidgetSnapshot(dateKey: AppGroup.dayKey(), volume: 0, goal: s.goal, water: 0, caffeine: 0, sugar: 0, drinks: 0)
        }
        return s
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            AppGroup.defaults.set(data, forKey: AppGroup.snapshotKey)
        }
    }
}
