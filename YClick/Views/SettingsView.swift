import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Finder Integration") {
                Text("YClick adds enabled file types to Finder context menus and creates empty files in the folder you right-click.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .padding()
    }
}
