import SwiftUI
import ServiceManagement

struct MenuBarView: View {
    @EnvironmentObject var store: ClipboardStore
    @State private var launchAtLogin: Bool = (SMAppService.mainApp.status == .enabled)

    var body: some View {
        Menu("History Limit: \(store.maxItems)") {
            Button("10 items") { store.maxItems = 10 }
            Button("20 items") { store.maxItems = 20 }
            Button("50 items") { store.maxItems = 50 }
        }

        Divider()

        if store.items.isEmpty {
            Text("No clipboard history yet")
        } else {
            ForEach(store.items) { item in
                Button(action: { store.copyToClipboard(item) }) {
                    Label(item.previewText, systemImage: item.iconName)
                }
            }
        }

        Divider()

        Button("Clear All History") { store.clearAll() }
            .disabled(store.items.isEmpty)

        Divider()

        Toggle("Launch at Login", isOn: $launchAtLogin)
            .onChange(of: launchAtLogin) { enabled in
                do {
                    if enabled {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    launchAtLogin = !enabled
                }
            }

        Divider()

        Button("Quit") { NSApplication.shared.terminate(nil) }
    }
}
