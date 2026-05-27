import Foundation

final class FileTypeStore: ObservableObject {
    private let userDefaults: UserDefaults
    @Published private(set) var fileTypes: [FileType] = []

    init(userDefaults: UserDefaults = .yclickShared) {
        self.userDefaults = userDefaults
        load()
    }

    var enabledFileTypes: [FileType] {
        fileTypes
            .filter(\.isEnabled)
            .sorted { lhs, rhs in
                if lhs.category == rhs.category {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
                return lhs.category.localizedCaseInsensitiveCompare(rhs.category) == .orderedAscending
            }
    }

    func load() {
        guard let data = userDefaults.data(forKey: AppConstants.fileTypeStoreKey),
              let decoded = try? JSONDecoder().decode([FileType].self, from: data),
              !decoded.isEmpty
        else {
            fileTypes = Self.seedFileTypes()
            save()
            return
        }

        fileTypes = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(fileTypes) else {
            return
        }

        userDefaults.set(data, forKey: AppConstants.fileTypeStoreKey)
        userDefaults.synchronize()
    }

    func upsert(_ fileType: FileType) {
        if let index = fileTypes.firstIndex(where: { $0.id == fileType.id }) {
            fileTypes[index] = fileType
        } else {
            fileTypes.append(fileType)
        }
        save()
    }

    func delete(_ fileType: FileType) {
        fileTypes.removeAll { $0.id == fileType.id }
        save()
    }

    func setEnabled(_ fileType: FileType, isEnabled: Bool) {
        guard let index = fileTypes.firstIndex(where: { $0.id == fileType.id }) else {
            return
        }

        fileTypes[index].isEnabled = isEnabled
        save()
    }

    func restoreBuiltIns() {
        let customFileTypes = fileTypes.filter { !$0.isBuiltIn }
        fileTypes = Self.seedFileTypes() + customFileTypes
        save()
    }

    static func seedFileTypes() -> [FileType] {
        FileType.builtIn
    }
}

extension UserDefaults {
    static var yclickShared: UserDefaults {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier) != nil else {
            return .standard
        }

        return UserDefaults(suiteName: AppConstants.appGroupIdentifier) ?? .standard
    }
}
