import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject var store: DrinkStore
    @State private var showCustom = false

    var body: some View {
        ZStack {
            // רקע מדורג + הילות אור
            Theme.background.ignoresSafeArea()
            GeometryReader { geo in
                Circle().fill(Theme.cyan.opacity(0.22)).frame(width: 320, height: 320)
                    .blur(radius: 90).offset(x: geo.size.width * 0.35, y: -120)
                Circle().fill(Theme.blue.opacity(0.20)).frame(width: 300, height: 300)
                    .blur(radius: 100).offset(x: -geo.size.width * 0.35, y: geo.size.height * 0.55)
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    HeaderView()
                    HeroCard()
                    QuickAddCard(showCustom: $showCustom)
                    StatsCard()
                    BreakdownCard()
                    LogCard()
                    WeekCard()
                    Button { store.resetToday() } label: {
                        Label("איפוס נתוני היום", systemImage: "arrow.counterclockwise")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(Theme.muted)
                            .padding(.vertical, 9).padding(.horizontal, 18)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.top, 4)
                    Text("הנתונים נשמרים במכשיר ומסונכרנים לאפל בריאות")
                        .font(.caption2).foregroundColor(Theme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .tint(Theme.cyan)
        .sheet(isPresented: $showCustom) { CustomAddSheet() }
    }
}

// MARK: - כותרת
struct HeaderView: View {
    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12:  return "בוקר טוב ☀️"
        case 12..<17: return "צהריים טובים 🌤️"
        case 17..<22: return "ערב טוב 🌆"
        default:       return "לילה טוב 🌙"
        }
    }
    private var dateLabel: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "he_IL")
        f.dateFormat = "EEEE, d בMMMM"; return f.string(from: Date())
    }
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting).font(.title3.bold()).foregroundColor(Theme.text)
                Text(dateLabel).font(.caption).foregroundColor(Theme.muted)
            }
            Spacer()
            Text("💧").font(.system(size: 34))
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - גלים (אנימציית מילוי מים)
struct Wave: Shape {
    var progress: CGFloat
    var phase: CGFloat
    var amplitude: CGFloat = 7
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(progress, phase) }
        set { progress = newValue.first; phase = newValue.second }
    }
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let level = rect.height * (1 - progress)
        p.move(to: CGPoint(x: 0, y: level))
        let step: CGFloat = 2
        var x: CGFloat = 0
        while x <= rect.width {
            let rel = x / rect.width
            let y = level + amplitude * sin(rel * 2 * .pi + phase)
            p.addLine(to: CGPoint(x: x, y: y))
            x += step
        }
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        return p
    }
}

struct WaterFillCircle: View {
    var progress: Double          // 0...1+
    var reached: Bool
    @State private var phase: CGFloat = 0

    private var fill: CGFloat { CGFloat(min(1, max(0, progress))) }
    private var colors: [Color] { reached ? [Theme.good, Theme.good.opacity(0.7)] : [Theme.cyan, Theme.blue] }

    var body: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.05))
            Wave(progress: fill, phase: phase, amplitude: 8)
                .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
                .opacity(0.95)
            Wave(progress: fill, phase: phase + .pi * 0.7, amplitude: 5)
                .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
                .opacity(0.4)
        }
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 2))
        .overlay(
            Circle().stroke(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom), lineWidth: 4)
                .opacity(0.35)
        )
        .animation(.easeInOut(duration: 0.9), value: fill)
        .onAppear {
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - כרטיס ראשי (מילוי מים)
struct HeroCard: View {
    @EnvironmentObject var store: DrinkStore
    var body: some View {
        let t = store.totals()
        let prog = t.volume / max(1, store.goalML)
        let reached = t.volume >= store.goalML
        VStack(spacing: 16) {
            ZStack {
                WaterFillCircle(progress: prog, reached: reached)
                    .frame(width: 210, height: 210)
                VStack(spacing: 2) {
                    Text("\(Int(t.volume))")
                        .font(.system(size: 46, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("מ\"ל היום").font(.subheadline).foregroundColor(.white.opacity(0.85))
                    Text("\(Int(min(100, prog * 100)))% מהיעד")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 2)
                }
            }
            HStack(spacing: 10) {
                Image(systemName: "target").foregroundColor(Theme.cyan)
                Text("יעד נוזלים יומי").foregroundColor(Theme.muted)
                Spacer()
                HStack(spacing: 4) {
                    TextField("יעד", value: $store.goalML, format: .number)
                        .keyboardType(.numberPad).multilineTextAlignment(.center)
                        .frame(width: 60).foregroundColor(Theme.text).fontWeight(.semibold)
                    Text("מ\"ל").foregroundColor(Theme.muted).font(.caption)
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Color.white.opacity(0.08), in: Capsule())
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .glassCard(padding: 22)
    }
}

// MARK: - הוספה מהירה
struct QuickAddCard: View {
    @EnvironmentObject var store: DrinkStore
    @Binding var showCustom: Bool
    private let cols = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("הוספה מהירה").font(.headline).foregroundColor(Theme.text)
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(Catalog.quickIDs, id: \.self) { id in
                    let d = Catalog.drink(id)
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            store.add(drinkID: id, ml: d.defaultML)
                        }
                    } label: {
                        VStack(spacing: 5) {
                            Text(d.emoji).font(.system(size: 28))
                            Text(d.name).font(.caption.weight(.semibold)).foregroundColor(.white)
                            Text("\(Int(d.defaultML))").font(.system(size: 10)).foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Theme.drinkGradient(id).opacity(0.9))
                        )
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(.white.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
            }
            Button { showCustom = true } label: {
                Label("הוסף שתייה אחרת", systemImage: "plus.circle.fill")
                    .font(.body.weight(.semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(14)
                    .background(Theme.accentGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

// MARK: - הוספה מותאמת
struct CustomAddSheet: View {
    @EnvironmentObject var store: DrinkStore
    @Environment(\.dismiss) var dismiss
    @State private var selected = Catalog.drinks.first!.id
    @State private var ml: Double = 250

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 22) {
                    Text(Catalog.drink(selected).emoji).font(.system(size: 64))
                        .padding(.top, 10)
                    Picker("סוג", selection: $selected) {
                        ForEach(Catalog.drinks) { d in Text("\(d.emoji) \(d.name)").tag(d.id) }
                    }
                    .pickerStyle(.wheel).frame(height: 130)
                    .onChange(of: selected) { new in ml = Catalog.drink(new).defaultML }

                    HStack(spacing: 14) {
                        Button { ml = max(10, ml - 50) } label: {
                            Image(systemName: "minus").font(.title3.bold()).frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.1), in: Circle()).foregroundColor(.white)
                        }
                        VStack(spacing: 0) {
                            TextField("מ\"ל", value: $ml, format: .number)
                                .keyboardType(.numberPad).multilineTextAlignment(.center)
                                .font(.system(size: 34, weight: .bold, design: .rounded)).foregroundColor(.white)
                                .frame(width: 110)
                            Text("מ\"ל").font(.caption).foregroundColor(Theme.muted)
                        }
                        Button { ml += 50 } label: {
                            Image(systemName: "plus").font(.title3.bold()).frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.1), in: Circle()).foregroundColor(.white)
                        }
                    }

                    Button {
                        store.add(drinkID: selected, ml: ml); dismiss()
                    } label: {
                        Text("הוסף").font(.body.weight(.bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(15)
                            .background(Theme.drinkGradient(selected), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("הוספת שתייה").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("ביטול") { dismiss() } } }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - סטטיסטיקות
struct StatsCard: View {
    @EnvironmentObject var store: DrinkStore
    private let cols = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    var body: some View {
        let t = store.totals()
        LazyVGrid(columns: cols, spacing: 12) {
            stat("drop.fill", "\(Int(t.water))", "מים מ\"ל", Theme.cyan)
            stat("cup.and.saucer.fill", "\(Int(t.caffeine))", "קפאין מ\"ג", Theme.caffeine)
            stat("wineglass.fill", String(format: "%.1f", t.drinks), "אלכוהול", Theme.alcohol)
            stat("cube.fill", "\(Int(t.sugar))", "סוכר גרם", Theme.sugar)
            stat("drop.circle.fill", "\(Int(t.volume))", "סה\"כ נוזלים", Theme.blue)
            stat("list.bullet", "\(t.count)", "שתיות", Theme.good)
        }
        .glassCard(padding: 16)
    }
    private func stat(_ icon: String, _ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundColor(color)
            Text(value).font(.title3.weight(.bold)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(Theme.muted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - פירוט לפי משקה
struct BreakdownCard: View {
    @EnvironmentObject var store: DrinkStore
    var body: some View {
        let data = store.breakdown()
        let total = data.reduce(0) { $0 + $1.volume }
        VStack(alignment: .leading, spacing: 14) {
            Text("פירוט לפי משקה").font(.headline).foregroundColor(Theme.text)
            if data.isEmpty {
                Text("אין נתונים להיום עדיין").font(.subheadline).foregroundColor(Theme.muted)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
            } else {
                HStack(alignment: .center, spacing: 16) {
                    chart(data: data, total: total).frame(width: 120, height: 120)
                    VStack(alignment: .leading, spacing: 9) {
                        ForEach(data, id: \.drink.id) { item in
                            HStack(spacing: 9) {
                                Circle().fill(Theme.drinkGradient(item.drink.id)).frame(width: 11, height: 11)
                                Text("\(item.drink.emoji) \(item.drink.name)")
                                    .font(.subheadline).foregroundColor(.white)
                                Spacer()
                                Text("\(Int(item.volume))")
                                    .font(.caption.weight(.semibold)).foregroundColor(Theme.muted)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    @ViewBuilder
    private func chart(data: [(drink: Drink, volume: Double)], total: Double) -> some View {
        if #available(iOS 17.0, *) {
            Chart(data, id: \.drink.id) { item in
                SectorMark(angle: .value("נפח", item.volume), innerRadius: .ratio(0.62), angularInset: 2)
                    .foregroundStyle(Theme.drinkColor(item.drink.id))
                    .cornerRadius(4)
            }
            .chartLegend(.hidden)
        } else {
            ZStack {
                ForEach(Array(segments(data, total: total).enumerated()), id: \.offset) { _, s in
                    Circle().trim(from: s.start, to: s.end)
                        .stroke(Theme.drinkColor(s.id), style: StrokeStyle(lineWidth: 20, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                }
            }.padding(10)
        }
    }
    private func segments(_ data: [(drink: Drink, volume: Double)], total: Double) -> [(id: String, start: CGFloat, end: CGFloat)] {
        guard total > 0 else { return [] }
        var acc: CGFloat = 0
        return data.map { item in
            let f = CGFloat(item.volume / total); defer { acc += f }
            return (item.drink.id, acc, acc + f)
        }
    }
}

// MARK: - יומן
struct LogCard: View {
    @EnvironmentObject var store: DrinkStore
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("היומן של היום").font(.headline).foregroundColor(Theme.text)
            if store.todayEntries.isEmpty {
                VStack(spacing: 6) {
                    Text("🌵").font(.system(size: 36))
                    Text("עדיין לא שתיתם כלום היום").font(.subheadline).foregroundColor(Theme.muted)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 16)
            } else {
                ForEach(store.todayEntries) { entry in
                    LogRow(entry: entry)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

struct LogRow: View {
    @EnvironmentObject var store: DrinkStore
    let entry: DrinkEntry
    private var timeStr: String { let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: entry.date) }
    private var detail: String {
        var parts: [String] = [timeStr]
        if entry.caffeineMG >= 1 { parts.append("\(Int(entry.caffeineMG)) מ\"ג קפאין") }
        if entry.alcoholDrinks >= 0.05 { parts.append(String(format: "%.1f מנות", entry.alcoholDrinks)) }
        if entry.sugarG >= 1 { parts.append("\(Int(entry.sugarG)) ג׳ סוכר") }
        return parts.joined(separator: " · ")
    }
    var body: some View {
        HStack(spacing: 12) {
            Text(entry.drink.emoji).font(.title3)
                .frame(width: 44, height: 44)
                .background(Theme.drinkGradient(entry.drink.id).opacity(0.85), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.drink.name).font(.subheadline.weight(.semibold)).foregroundColor(.white)
                Text(detail).font(.caption2).foregroundColor(Theme.muted)
            }
            Spacer()
            Text("\(Int(entry.ml)) מ\"ל").font(.subheadline.weight(.bold)).foregroundColor(Theme.cyan)
            Button {
                withAnimation { store.delete(entry) }
            } label: {
                Image(systemName: "xmark.circle.fill").foregroundColor(.white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - גרף שבועי
struct WeekCard: View {
    @EnvironmentObject var store: DrinkStore
    private let dayNames = ["א","ב","ג","ד","ה","ו","ש"]
    private var days: [(date: Date, vol: Double)] {
        (0..<7).reversed().map { off in
            let d = Calendar.current.date(byAdding: .day, value: -off, to: Date())!
            return (d, store.volume(for: d))
        }
    }
    var body: some View {
        let data = days
        let maxV = max(store.goalML, data.map { $0.vol }.max() ?? 0, 1)
        VStack(alignment: .leading, spacing: 12) {
            Text("7 הימים האחרונים").font(.headline).foregroundColor(Theme.text)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { idx, item in
                    let met = item.vol >= store.goalML
                    let isToday = idx == data.count - 1
                    VStack(spacing: 7) {
                        GeometryReader { geo in
                            VStack {
                                Spacer(minLength: 0)
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(met ? LinearGradient(colors: [Theme.good, Theme.good.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                                              : Theme.waterGradient)
                                    .frame(height: max(4, geo.size.height * (item.vol / maxV)))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        Text(dayNames[Calendar.current.component(.weekday, from: item.date) - 1])
                            .font(.caption2).fontWeight(isToday ? .bold : .regular)
                            .foregroundColor(isToday ? Theme.cyan : Theme.muted)
                    }
                }
            }
            .frame(height: 130)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

#Preview {
    ContentView().environmentObject(DrinkStore())
        .environment(\.layoutDirection, .rightToLeft)
}
