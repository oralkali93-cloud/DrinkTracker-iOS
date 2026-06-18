import WidgetKit
import SwiftUI

// MARK: - Timeline
struct DrinkEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DrinkEntry {
        DrinkEntry(date: Date(), snapshot: WidgetSnapshot(dateKey: AppGroup.dayKey(), volume: 1200, goal: 2500, water: 1000, caffeine: 80, sugar: 12, drinks: 0))
    }
    func getSnapshot(in context: Context, completion: @escaping (DrinkEntry) -> Void) {
        completion(DrinkEntry(date: Date(), snapshot: WidgetSnapshot.load()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<DrinkEntry>) -> Void) {
        let entry = DrinkEntry(date: Date(), snapshot: WidgetSnapshot.load())
        // רענון תקופתי כדי לאפס בתחילת יום חדש
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - צבעים (עצמאי, ללא תלות באפליקציה)
private enum WColor {
    static let bg     = Color(red: 0.08, green: 0.11, blue: 0.18)
    static let track  = Color(red: 0.20, green: 0.25, blue: 0.33)
    static let accent = Color(red: 0.22, green: 0.74, blue: 0.97)
    static let good   = Color(red: 0.13, green: 0.77, blue: 0.37)
    static let text   = Color(red: 0.95, green: 0.96, blue: 0.98)
    static let muted  = Color(red: 0.58, green: 0.64, blue: 0.72)
}

// MARK: - תצוגה
struct DrinkWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    private var progress: Double { min(1, entry.snapshot.volume / max(1, entry.snapshot.goal)) }
    private var ringColor: Color { progress >= 1 ? WColor.good : WColor.accent }

    var body: some View {
        switch family {
        case .systemSmall: smallView
        default: mediumView
        }
    }

    private var ring: some View {
        ZStack {
            Circle().stroke(WColor.track, lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(Int(progress * 100))%").font(.system(size: 17, weight: .bold)).foregroundColor(WColor.text)
                Text("\(Int(entry.snapshot.volume))").font(.system(size: 10)).foregroundColor(WColor.muted)
            }
        }
    }

    private var smallView: some View {
        VStack(spacing: 6) {
            Text("💧 היום").font(.caption2.bold()).foregroundColor(WColor.muted)
            ring.frame(maxWidth: .infinity, maxHeight: .infinity)
            Text("\(Int(entry.snapshot.volume)) / \(Int(entry.snapshot.goal)) מ\"ל")
                .font(.system(size: 10)).foregroundColor(WColor.muted)
        }
        .padding(12)
        .containerBackgroundCompat(WColor.bg)
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            ring.frame(width: 90, height: 90)
            VStack(alignment: .leading, spacing: 6) {
                Text("💧 השתייה של היום").font(.subheadline.bold()).foregroundColor(WColor.text)
                stat("נוזלים", "\(Int(entry.snapshot.volume)) מ\"ל")
                stat("מים", "\(Int(entry.snapshot.water)) מ\"ל")
                if entry.snapshot.caffeine >= 1 { stat("קפאין", "\(Int(entry.snapshot.caffeine)) מ\"ג") }
                if entry.snapshot.drinks >= 0.05 { stat("אלכוהול", String(format: "%.1f מנות", entry.snapshot.drinks)) }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .containerBackgroundCompat(WColor.bg)
    }

    private func stat(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(label).font(.caption2).foregroundColor(WColor.muted)
            Text(value).font(.caption2.bold()).foregroundColor(WColor.text)
        }
    }
}

// תאימות רקע: iOS 17 דורש containerBackground, גרסאות קודמות משתמשות ב-background.
private extension View {
    @ViewBuilder
    func containerBackgroundCompat(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(color, for: .widget)
        } else {
            self.background(color)
        }
    }
}

// MARK: - Widget
struct DrinkWidget: Widget {
    let kind = "DrinkWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DrinkWidgetEntryView(entry: entry)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .configurationDisplayName("מעקב שתייה")
        .description("ההתקדמות שלך ליעד הנוזלים היומי.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct DrinkWidgetBundle: WidgetBundle {
    var body: some Widget { DrinkWidget() }
}
