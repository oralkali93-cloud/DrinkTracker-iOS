import Foundation

// MARK: - קטלוג משקאות
// ערכים פר מ"ל: קפאין (מ"ג), סוכר (גרם), abv = אחוז אלכוהול כשבר
struct Drink: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let defaultML: Double
    let isWater: Bool
    let caffeinePerML: Double   // mg / ml
    let sugarPerML: Double      // g / ml
    let abv: Double             // 0...1
}

enum Catalog {
    static let standardDrinkGrams = 14.0   // גרם אלכוהול טהור למנה תקנית (תקן Apple)
    static let ethanolDensity = 0.789

    static let drinks: [Drink] = [
        Drink(id: "water",  name: "מים",       emoji: "💧", defaultML: 250, isWater: true,  caffeinePerML: 0,    sugarPerML: 0,     abv: 0),
        Drink(id: "coffee", name: "קפה",       emoji: "☕️", defaultML: 200, isWater: false, caffeinePerML: 0.40, sugarPerML: 0,     abv: 0),
        Drink(id: "tea",    name: "תה",        emoji: "🍵", defaultML: 200, isWater: false, caffeinePerML: 0.15, sugarPerML: 0,     abv: 0),
        Drink(id: "juice",  name: "מיץ",       emoji: "🧃", defaultML: 250, isWater: false, caffeinePerML: 0,    sugarPerML: 0.10,  abv: 0),
        Drink(id: "soda",   name: "מוגז/קולה", emoji: "🥤", defaultML: 330, isWater: false, caffeinePerML: 0.10, sugarPerML: 0.106, abv: 0),
        Drink(id: "energy", name: "אנרגיה",    emoji: "⚡️", defaultML: 250, isWater: false, caffeinePerML: 0.32, sugarPerML: 0.11,  abv: 0),
        Drink(id: "milk",   name: "חלב",       emoji: "🥛", defaultML: 200, isWater: false, caffeinePerML: 0,    sugarPerML: 0.047, abv: 0),
        Drink(id: "beer",   name: "בירה",      emoji: "🍺", defaultML: 330, isWater: false, caffeinePerML: 0,    sugarPerML: 0.01,  abv: 0.05),
        Drink(id: "wine",   name: "יין",       emoji: "🍷", defaultML: 150, isWater: false, caffeinePerML: 0,    sugarPerML: 0.006, abv: 0.125),
        Drink(id: "spirit", name: "חריף",      emoji: "🥃", defaultML: 40,  isWater: false, caffeinePerML: 0,    sugarPerML: 0,     abv: 0.40),
    ]

    static let quickIDs = ["water", "coffee", "tea", "beer"]

    static func drink(_ id: String) -> Drink {
        drinks.first(where: { $0.id == id })
            ?? Drink(id: id, name: id, emoji: "🥛", defaultML: 250, isWater: false, caffeinePerML: 0, sugarPerML: 0, abv: 0)
    }
}

// MARK: - רשומת שתייה
struct DrinkEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var drinkID: String
    var ml: Double
    var date: Date
    var healthUUIDs: [String] = []   // מזהי הדגימות שנכתבו ל-Health (למחיקה מסונכרנת)

    var drink: Drink { Catalog.drink(drinkID) }

    // ערכים בריאותיים מחושבים
    var waterML: Double      { drink.isWater ? ml : 0 }
    var caffeineMG: Double   { ml * drink.caffeinePerML }
    var sugarG: Double       { ml * drink.sugarPerML }
    var alcoholGrams: Double { ml * drink.abv * Catalog.ethanolDensity }
    var alcoholDrinks: Double { alcoholGrams / Catalog.standardDrinkGrams }
}
