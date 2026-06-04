import SwiftUI

@main
struct ClipboardManagerApp: App {
    @StateObject private var store = ClipboardStore()

    var body: some Scene {
        MenuBarExtra("Clipboard Manager", systemImage: "doc.on.clipboard") {
            MenuBarView()
                .environmentObject(store)
        }
        .menuBarExtraStyle(.menu)
    }
}
