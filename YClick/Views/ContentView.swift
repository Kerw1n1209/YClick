import SwiftUI

struct ContentView: View {
    @ObservedObject var store: FileTypeStore
    @State private var selectedFileTypeID: FileType.ID?
    @State private var isShowingEditor = false
    @State private var editingFileType: FileType?
    @State private var searchText = ""

    private var selectedFileType: FileType? {
        store.fileTypes.first { $0.id == selectedFileTypeID }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedFileTypeID) {
                ForEach(groupedFileTypes, id: \.category) { group in
                    Section(group.category) {
                        ForEach(group.fileTypes) { fileType in
                            FileTypeRow(fileType: fileType)
                                .tag(fileType.id)
                                .contextMenu {
                                    Button(fileType.isEnabled ? "Disable" : "Enable") {
                                        store.setEnabled(fileType, isEnabled: !fileType.isEnabled)
                                    }

                                    Button("Edit") {
                                        edit(fileType)
                                    }

                                    if !fileType.isBuiltIn {
                                        Button("Delete", role: .destructive) {
                                            store.delete(fileType)
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("File Types")
            .searchable(text: $searchText, placement: .sidebar, prompt: "Search file types")
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        editingFileType = FileType(name: "", fileExtension: "")
                        isShowingEditor = true
                    } label: {
                        Label("Add Type", systemImage: "plus")
                    }

                    Button {
                        store.restoreBuiltIns()
                    } label: {
                        Label("Restore Presets", systemImage: "arrow.clockwise")
                    }
                }
            }
        } detail: {
            if let selectedFileType {
                FileTypeDetailView(fileType: selectedFileType) {
                    edit(selectedFileType)
                } toggleEnabled: {
                    store.setEnabled(selectedFileType, isEnabled: !selectedFileType.isEnabled)
                }
            } else {
                EmptyStateView()
            }
        }
        .sheet(isPresented: $isShowingEditor) {
            if let editingFileType {
                FileTypeEditorView(fileType: editingFileType) { updatedFileType in
                    store.upsert(updatedFileType)
                    selectedFileTypeID = updatedFileType.id
                    isShowingEditor = false
                } onCancel: {
                    isShowingEditor = false
                }
            }
        }
    }

    private var filteredFileTypes: [FileType] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return store.fileTypes
        }

        return store.fileTypes.filter { fileType in
            fileType.name.localizedCaseInsensitiveContains(query)
                || fileType.fileExtension.localizedCaseInsensitiveContains(query)
                || fileType.category.localizedCaseInsensitiveContains(query)
        }
    }

    private var groupedFileTypes: [(category: String, fileTypes: [FileType])] {
        Dictionary(grouping: filteredFileTypes) { $0.category.isEmpty ? "Custom" : $0.category }
            .map { category, fileTypes in
                (
                    category,
                    fileTypes.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                )
            }
            .sorted { $0.category.localizedCaseInsensitiveCompare($1.category) == .orderedAscending }
    }

    private func edit(_ fileType: FileType) {
        editingFileType = fileType
        isShowingEditor = true
    }
}

private struct FileTypeRow: View {
    let fileType: FileType

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(fileType.isEnabled ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.08))

                Image(systemName: fileType.systemImage)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(fileType.isEnabled ? Color.accentColor : Color.secondary)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(fileType.name.isEmpty ? "Untitled Type" : fileType.name)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)

                Text(fileType.displayExtension)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if !fileType.isEnabled {
                Image(systemName: "slash.circle")
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 3)
        .opacity(fileType.isEnabled ? 1 : 0.55)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 52, weight: .regular))
                .foregroundStyle(Color.accentColor, .secondary)
                .symbolRenderingMode(.hierarchical)

            Text("Select a file type")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Enabled types appear in Finder's YClick menu and create empty files.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
