import XCTest

final class FileCreationServiceTests: XCTestCase {
    func testUniqueURLIncrementsWhenFileExists() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let existing = directory.appendingPathComponent("Untitled.txt")
        FileManager.default.createFile(atPath: existing.path, contents: Data())

        let service = FileCreationService()
        let url = service.uniqueURL(in: directory, baseName: "Untitled", fileExtension: "txt")

        XCTAssertEqual(url.lastPathComponent, "Untitled 2.txt")
    }

    func testCreateFileCreatesEmptyFile() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let fileType = FileType(name: "Markdown", fileExtension: ".md")
        let createdURL = try FileCreationService().createFile(for: fileType, in: directory)
        let data = try Data(contentsOf: createdURL)

        XCTAssertEqual(createdURL.lastPathComponent, "Untitled.md")
        XCTAssertTrue(data.isEmpty)
    }
}
