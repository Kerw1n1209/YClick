import SwiftUI

struct FileTypeDetailView: View {
    let fileType: FileType
    let edit: () -> Void
    let toggleEnabled: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                HStack(alignment: .top, spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.12))

                        Image(systemName: fileType.systemImage)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(Color.accentColor)
                    }
                    .frame(width: 58, height: 58)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(fileType.name)
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.semibold)

                        Text("\(fileType.displayExtension) - \(fileType.category)")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Toggle("Enabled", isOn: Binding(
                        get: { fileType.isEnabled },
                        set: { _ in toggleEnabled() }
                    ))
                    .toggleStyle(.switch)
                }

                HStack {
                    Button {
                        edit()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button {
                        NSWorkspace.shared.open(URL(fileURLWithPath: NSHomeDirectory()))
                    } label: {
                        Label("Open Home Folder", systemImage: "folder")
                    }
                }
                .buttonStyle(.bordered)

                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 14) {
                    InfoRow(label: "Created file", value: "\(AppConstants.defaultBaseName).\(fileType.fileExtension)")
                    InfoRow(label: "Content", value: "Empty file")
                    InfoRow(label: "Finder menu", value: fileType.isEnabled ? "Visible" : "Hidden")
                    InfoRow(label: "Source", value: fileType.isBuiltIn ? "Preset" : "Custom")
                }
                .padding(18)
                .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Finder Extension")
                        .font(.headline)

                    Text("YClick adds enabled file types to Finder's folder background menu. New files are created empty and named with the next available Untitled filename.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(fileType.name)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.medium)
                .textSelection(.enabled)
        }
    }
}
