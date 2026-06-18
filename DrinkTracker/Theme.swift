import SwiftUI

enum Theme {
    // רקע
    static let bgTop    = Color(red: 0.04, green: 0.07, blue: 0.15)
    static let bgMid    = Color(red: 0.04, green: 0.10, blue: 0.19)
    static let bgBottom = Color(red: 0.03, green: 0.13, blue: 0.20)
    static var background: LinearGradient {
        LinearGradient(colors: [bgTop, bgMid, bgBottom], startPoint: .topTrailing, endPoint: .bottomLeading)
    }

    // טקסט
    static let text  = Color.white
    static let muted = Color.white.opacity(0.55)

    // צבעי מותג
    static let cyan = Color(red: 0.24, green: 0.81, blue: 0.97)
    static let blue = Color(red: 0.23, green: 0.51, blue: 0.96)
    static let good = Color(red: 0.20, green: 0.83, blue: 0.45)

    // צבעי נתונים
    static let caffeine = Color(red: 0.98, green: 0.67, blue: 0.18)
    static let alcohol  = Color(red: 0.70, green: 0.58, blue: 0.99)
    static let sugar    = Color(red: 0.98, green: 0.49, blue: 0.72)

    static var waterGradient: LinearGradient {
        LinearGradient(colors: [cyan, blue], startPoint: .top, endPoint: .bottom)
    }
    static var accentGradient: LinearGradient {
        LinearGradient(colors: [cyan, blue], startPoint: .leading, endPoint: .trailing)
    }

    static let cardStroke = Color.white.opacity(0.10)

    /// צבע/גרדיאנט לכל סוג משקה
    static func drinkColors(_ id: String) -> [Color] {
        switch id {
        case "water":  return [Color(red:0.30,green:0.82,blue:0.98), Color(red:0.20,green:0.55,blue:0.95)]
        case "coffee": return [Color(red:0.60,green:0.42,blue:0.28), Color(red:0.40,green:0.26,blue:0.16)]
        case "tea":    return [Color(red:0.46,green:0.78,blue:0.46), Color(red:0.24,green:0.56,blue:0.34)]
        case "juice":  return [Color(red:0.99,green:0.72,blue:0.20), Color(red:0.96,green:0.50,blue:0.12)]
        case "soda":   return [Color(red:0.62,green:0.64,blue:0.70), Color(red:0.40,green:0.43,blue:0.50)]
        case "energy": return [Color(red:0.95,green:0.85,blue:0.22), Color(red:0.78,green:0.60,blue:0.10)]
        case "milk":   return [Color(red:0.92,green:0.93,blue:0.97), Color(red:0.74,green:0.78,blue:0.86)]
        case "beer":   return [Color(red:0.98,green:0.74,blue:0.22), Color(red:0.85,green:0.52,blue:0.08)]
        case "wine":   return [Color(red:0.80,green:0.24,blue:0.42), Color(red:0.55,green:0.10,blue:0.26)]
        case "spirit": return [Color(red:0.74,green:0.62,blue:0.99), Color(red:0.50,green:0.38,blue:0.86)]
        default:       return [cyan, blue]
        }
    }
    static func drinkGradient(_ id: String) -> LinearGradient {
        LinearGradient(colors: drinkColors(id), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static func drinkColor(_ id: String) -> Color { drinkColors(id).first ?? cyan }
}

// כרטיס זגוגי
struct GlassCard: ViewModifier {
    var padding: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Theme.cardStroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.28), radius: 16, x: 0, y: 8)
    }
}
extension View {
    func glassCard(padding: CGFloat = 18) -> some View { modifier(GlassCard(padding: padding)) }
}
