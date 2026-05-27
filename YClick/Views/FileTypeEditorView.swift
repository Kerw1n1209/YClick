import SwiftUI

struct FileTypeEditorView: View {
    @State private var draft: FileType
    let onSave: (FileType) -> Void
    let onCancel: () -> Void

    init(fileType: FileType, onSave: @escaping (FileType) -> Void, onCancel: @escaping () -> Void) {
        _draft = State(initialValue: fileType)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Identity") {
                    TextField("Display name", text: $draft.name)
                    TextField("Extension", text: $draft.fileExtension)
                    TextField("Category", text: $draft.category)
                }

                Section("Menu Appearance") {
                    TextField("SF Symbol", text: $draft.systemImage)
                    Toggle("Show in Finder menu", isOn: $draft.isEnabled)
                }
            }
            .formStyle(.grouped)

            Divider()

            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                Button("Save") {
                    draft.name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    draft.fileExtension = FileType.normalizedExtension(draft.fileExtension)
                    if draft.category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        draft.category = "Custom"
                    }
                    onSave(draft)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || FileType.normalizedExtension(draft.fileExtension).isEmpty)
            }
            .padding()
        }
        .frame(width: 520, height: 340)
    }
}
