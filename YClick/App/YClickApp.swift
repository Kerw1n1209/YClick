import SwiftUI

@main
struct YClickApp: App {
    @StateObject private var fileTypeStore = FileTypeStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: fileTypeStore)
                .frame(minWidth: 860, minHeight: 560)
        }
        .windowStyle(.titleBar)

        Settings {
            SettingsView()
        }
    }
}
