import SwiftUI

@main
struct DrinkTrackerApp: App {
    @StateObject private var store = DrinkStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environment(\.layoutDirection, .rightToLeft)   // עברית RTL
                .preferredColorScheme(.dark)
                .onAppear { store.requestHealthAccess() }
        }
    }
}
