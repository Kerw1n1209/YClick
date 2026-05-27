import Foundation

enum FileCreationError: LocalizedError {
    case invalidExtension
    case targetIsNotDirectory(URL)

    var errorDescription: String? {
        switch self {
        case .invalidExtension:
            return "The file extension is empty or invalid."
        case let .targetIsNotDirectory(url):
            return "\(url.path) is not a folder."
        }
    }
}

struct FileCreationService {
    var fileManager: FileManager = .default

    func createFile(for fileType: FileType, in directory: URL) throws -> URL {
        let didAccessSecurityScopedResource = directory.startAccessingSecurityScopedResource()
        defer {
            if didAccessSecurityScopedResource {
                directory.stopAccessingSecurityScopedResource()
            }
        }

        let fileExtension = FileType.normalizedExtension(fileType.fileExtension)
        guard !fileExtension.isEmpty else {
            throw FileCreationError.invalidExtension
        }

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw FileCreationError.targetIsNotDirectory(directory)
        }

        let destination = uniqueURL(
            in: directory,
            baseName: AppConstants.defaultBaseName,
            fileExtension: fileExtension
        )

        try Data().write(to: destination, options: [.atomic])
        return destination
    }

    func uniqueURL(in directory: URL, baseName: String, fileExtension: String) -> URL {
        let normalizedExtension = FileType.normalizedExtension(fileExtension)
        var candidate = directory.appendingPathComponent("\(baseName).\(normalizedExtension)")
        var index = 2

        while fileManager.fileExists(atPath: candidate.path) {
            candidate = directory.appendingPathComponent("\(baseName) \(index).\(normalizedExtension)")
            index += 1
        }

        return candidate
    }
}
