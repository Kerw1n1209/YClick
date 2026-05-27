import Foundation

struct FileType: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var fileExtension: String
    var systemImage: String
    var category: String
    var isEnabled: Bool
    var isBuiltIn: Bool

    init(
        id: UUID = UUID(),
        name: String,
        fileExtension: String,
        systemImage: String = "doc",
        category: String = "Custom",
        isEnabled: Bool = true,
        isBuiltIn: Bool = false
    ) {
        self.id = id
        self.name = name
        self.fileExtension = FileType.normalizedExtension(fileExtension)
        self.systemImage = systemImage
        self.category = category
        self.isEnabled = isEnabled
        self.isBuiltIn = isBuiltIn
    }

    var displayExtension: String {
        ".\(fileExtension)"
    }

    static func normalizedExtension(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
            .lowercased()
    }
}

extension FileType {
    static let builtIn: [FileType] = [
        FileType(id: UUID(uuidString: "11111111-1111-4111-8111-111111111111")!, name: "Text File", fileExtension: "txt", systemImage: "doc.text", category: "Text", isBuiltIn: true),
        FileType(id: UUID(uuidString: "22222222-2222-4222-8222-222222222222")!, name: "Markdown", fileExtension: "md", systemImage: "text.alignleft", category: "Text", isBuiltIn: true),
        FileType(id: UUID(uuidString: "33333333-3333-4333-8333-333333333333")!, name: "JSON", fileExtension: "json", systemImage: "curlybraces", category: "Data", isBuiltIn: true),
        FileType(id: UUID(uuidString: "44444444-4444-4444-8444-444444444444")!, name: "HTML", fileExtension: "html", systemImage: "globe", category: "Web", isBuiltIn: true),
        FileType(id: UUID(uuidString: "55555555-5555-4555-8555-555555555555")!, name: "CSS", fileExtension: "css", systemImage: "paintbrush", category: "Web", isBuiltIn: true),
        FileType(id: UUID(uuidString: "66666666-6666-4666-8666-666666666666")!, name: "JavaScript", fileExtension: "js", systemImage: "chevron.left.forwardslash.chevron.right", category: "Code", isBuiltIn: true),
        FileType(id: UUID(uuidString: "77777777-7777-4777-8777-777777777777")!, name: "Python", fileExtension: "py", systemImage: "terminal", category: "Code", isBuiltIn: true),
        FileType(id: UUID(uuidString: "88888888-8888-4888-8888-888888888888")!, name: "Swift", fileExtension: "swift", systemImage: "swift", category: "Code", isBuiltIn: true),
        FileType(id: UUID(uuidString: "99999999-9999-4999-8999-999999999999")!, name: "Property List", fileExtension: "plist", systemImage: "list.bullet.rectangle", category: "Data", isBuiltIn: true)
    ]
}
