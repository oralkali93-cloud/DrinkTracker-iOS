import Foundation
import SwiftUI
import WidgetKit

/// מקור האמת לנתוני האפליקציה: אחסון מקומי + כתיבה ל-Health.
@MainActor
final class DrinkStore: ObservableObject {
    @Published private(set) var entriesByDay: [String: [DrinkEntry]] = [:]
    @Published var goalML: Double {
        didSet { defaults.set(goalML, forKey: goalKey); updateWidget() }
    }
    @Published var healthEnabled: Bool {
        didSet { defaults.set(healthEnabled, forKey: healthKey) }
    }

    private let defaults = AppGroup.defaults
    private let dataKey = "drinksTrackerData_v1"
    private let goalKey = "drinksTrackerGoal_v1"
    private let healthKey = "drinksTrackerHealth_v1"

    init() {
        let g = defaults.double(forKey: goalKey)
        goalML = g > 0 ? g : 2500
        healthEnabled = defaults.object(forKey: healthKey) as? Bool ?? true
        load()
        updateWidget()
    }

    // MARK: מפתחות תאריך
    private static let dayFmt: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    func dayKey(_ date: Date = Date()) -> String { Self.dayFmt.string(from: date) }

    // MARK: גישה
    func entries(for date: Date = Date()) -> [DrinkEntry] {
        (entriesByDay[dayKey(date)] ?? []).sorted { $0.date > $1.date }
    }

    var todayEntries: [DrinkEntry] { entries(for: Date()) }

    // MARK: סיכומים יומיים
    func totals(for date: Date = Date()) -> (volume: Double, water: Double, caffeine: Double, sugar: Double, drinks: Double, count: Int) {
        let list = entriesByDay[dayKey(date)] ?? []
        return (
            list.reduce(0) { $0 + $1.ml },
            list.reduce(0) { $0 + $1.waterML },
            list.reduce(0) { $0 + $1.caffeineMG },
            list.reduce(0) { $0 + $1.sugarG },
            list.reduce(0) { $0 + $1.alcoholDrinks },
            list.count
        )
    }

    func volume(for date: Date) -> Double { (entriesByDay[dayKey(date)] ?? []).reduce(0) { $0 + $1.ml } }

    /// פירוט נפח לפי סוג משקה ליום נתון, ממוין מהגדול לקטן.
    func breakdown(for date: Date = Date()) -> [(drink: Drink, volume: Double)] {
        let list = entriesByDay[dayKey(date)] ?? []
        let grouped = Dictionary(grouping: list, by: { $0.drinkID })
        return grouped
            .map { (drink: Catalog.drink($0.key), volume: $0.value.reduce(0) { $0 + $1.ml }) }
            .sorted { $0.volume > $1.volume }
    }

    // MARK: פעולות
    func add(drinkID: String, ml: Double) {
        var entry = DrinkEntry(drinkID: drinkID, ml: ml, date: Date())
        let key = dayKey(entry.date)
        entriesByDay[key, default: []].append(entry)
        persist()

        guard healthEnabled else { return }
        Task {
            let uuids = await HealthKitManager.shared.save(entry: entry)
            if !uuids.isEmpty {
                entry.healthUUIDs = uuids.map { $0.uuidString }
                // עדכון הרשומה השמורה עם מזהי ה-Health
                if let idx = entriesByDay[key]?.firstIndex(where: { $0.id == entry.id }) {
                    entriesByDay[key]?[idx] = entry
                    persist()
                }
            }
        }
    }

    func delete(_ entry: DrinkEntry) {
        let key = dayKey(entry.date)
        entriesByDay[key]?.removeAll { $0.id == entry.id }
        if entriesByDay[key]?.isEmpty == true { entriesByDay[key] = nil }
        persist()

        let uuids = entry.healthUUIDs.compactMap { UUID(uuidString: $0) }
        if healthEnabled && !uuids.isEmpty {
            Task { await HealthKitManager.shared.deleteSamples(uuids: uuids) }
        }
    }

    func resetToday() {
        let key = dayKey()
        let entries = entriesByDay[key] ?? []
        entriesByDay[key] = nil
        persist()
        if healthEnabled {
            let uuids = entries.flatMap { $0.healthUUIDs }.compactMap { UUID(uuidString: $0) }
            if !uuids.isEmpty { Task { await HealthKitManager.shared.deleteSamples(uuids: uuids) } }
        }
    }

    func requestHealthAccess() {
        Task { _ = await HealthKitManager.shared.requestAuthorization() }
    }

    // MARK: התמדה
    private func persist() {
        if let data = try? JSONEncoder().encode(entriesByDay) {
            defaults.set(data, forKey: dataKey)
        }
        updateWidget()
    }

    /// כותב תמונת מצב ל-App Group ומרענן את ה-Widget.
    private func updateWidget() {
        let t = totals()
        WidgetSnapshot(dateKey: dayKey(), volume: t.volume, goal: goalML,
                       water: t.water, caffeine: t.caffeine, sugar: t.sugar, drinks: t.drinks).save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    private func load() {
        guard let data = defaults.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode([String: [DrinkEntry]].self, from: data) else { return }
        entriesByDay = decoded
    }
}
