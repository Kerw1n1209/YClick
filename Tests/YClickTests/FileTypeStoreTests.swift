import XCTest

final class FileTypeStoreTests: XCTestCase {
    func testBuiltInFileTypesIncludeRequiredTypes() {
        let extensions = Set(FileType.builtIn.map(\.fileExtension))

        XCTAssertTrue(extensions.isSuperset(of: ["txt", "md", "json", "html", "css", "js", "py", "swift", "plist"]))
    }

    func testExtensionNormalization() {
        XCTAssertEqual(FileType.normalizedExtension(" .MD "), "md")
    }
}
