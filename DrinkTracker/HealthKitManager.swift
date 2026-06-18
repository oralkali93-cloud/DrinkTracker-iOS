import Foundation
import HealthKit

/// אחראי על כל התקשורת עם Apple Health (HealthKit).
final class HealthKitManager {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()

    // סוגי הנתונים שנכתוב
    private let waterType    = HKQuantityType(.dietaryWater)
    private let caffeineType = HKQuantityType(.dietaryCaffeine)
    private let sugarType    = HKQuantityType(.dietarySugar)
    private let alcoholType  = HKQuantityType(.numberOfAlcoholicBeverages)  // iOS 15+

    private var writeTypes: Set<HKSampleType> {
        [waterType, caffeineType, sugarType, alcoholType]
    }

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // MARK: הרשאות
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: writeTypes, read: [])
            return true
        } catch {
            print("HealthKit auth error: \(error)")
            return false
        }
    }

    // MARK: כתיבה
    /// כותב את כל הערכים הרלוונטיים של רשומה ומחזיר את מזהי הדגימות שנשמרו.
    @discardableResult
    func save(entry: DrinkEntry) async -> [UUID] {
        guard isAvailable else { return [] }
        var samples: [HKQuantitySample] = []

        if entry.waterML > 0 {
            samples.append(HKQuantitySample(
                type: waterType,
                quantity: HKQuantity(unit: .literUnit(with: .milli), doubleValue: entry.waterML),
                start: entry.date, end: entry.date))
        }
        if entry.caffeineMG > 0 {
            samples.append(HKQuantitySample(
                type: caffeineType,
                quantity: HKQuantity(unit: .gramUnit(with: .milli), doubleValue: entry.caffeineMG),
                start: entry.date, end: entry.date))
        }
        if entry.sugarG > 0 {
            samples.append(HKQuantitySample(
                type: sugarType,
                quantity: HKQuantity(unit: .gram(), doubleValue: entry.sugarG),
                start: entry.date, end: entry.date))
        }
        if entry.alcoholDrinks > 0 {
            samples.append(HKQuantitySample(
                type: alcoholType,
                quantity: HKQuantity(unit: .count(), doubleValue: entry.alcoholDrinks),
                start: entry.date, end: entry.date))
        }

        guard !samples.isEmpty else { return [] }
        do {
            try await store.save(samples)
            return samples.map { $0.uuid }
        } catch {
            print("HealthKit save error: \(error)")
            return []
        }
    }

    // MARK: מחיקה
    /// מנסה למחוק מ-Health את הדגימות שנכתבו עבור רשומה שנמחקה.
    func deleteSamples(uuids: [UUID]) async {
        guard isAvailable, !uuids.isEmpty else { return }
        let predicate = HKQuery.predicateForObjects(with: Set(uuids))
        for type in writeTypes {
            await withCheckedContinuation { cont in
                store.deleteObjects(of: type, predicate: predicate) { _, _, _ in
                    cont.resume()
                }
            }
        }
    }
}
