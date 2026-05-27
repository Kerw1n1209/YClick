import AppKit
import FinderSync
import os

private final class FileCreationCommand: NSObject {
    let fileType: FileType
    let directoryPath: String

    init(fileType: FileType, directoryPath: String) {
        self.fileType = fileType
        self.directoryPath = directoryPath
    }
}

@objc(FinderSync)
final class FinderSync: FIFinderSync {
    private let store = FileTypeStore()
    private let creationService = FileCreationService()
    private let logger = Logger(subsystem: "com.yclick.YClick.FinderExtension", category: "FinderSync")
    private static var fileCreationCommands: [Int: FileCreationCommand] = [:]
    private static var nextCommandID = 1

    override init() {
        super.init()
        let monitoredURLs = monitoredDirectories()
        FIFinderSyncController.default().directoryURLs = monitoredURLs
        let monitoredPaths = monitoredURLs.map(\.path).sorted().joined(separator: ", ")
        NSLog("YClick Finder extension initialized. Monitoring: %@", monitoredPaths)
        logger.info("YClick Finder extension monitoring: \(monitoredPaths, privacy: .public)")
    }

    override func beginObservingDirectory(at url: URL) {
        logger.info("Begin observing Finder directory: \(url.path, privacy: .public)")
    }

    override func endObservingDirectory(at url: URL) {
        logger.info("End observing Finder directory: \(url.path, privacy: .public)")
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        NSLog("YClick Finder requested menu kind: %@", String(describing: menuKind))
        logger.info("Finder requested menu kind \(String(describing: menuKind), privacy: .public)")

        guard menuKind == .contextualMenuForContainer || menuKind == .contextualMenuForItems else {
            return nil
        }

        guard let directory = targetDirectory(for: menuKind) else {
            logger.warning("No Finder target directory for menu kind \(String(describing: menuKind), privacy: .public)")
            return nil
        }

        store.load()

        let menu = NSMenu(title: "YClick")
        let fileTypes = store.enabledFileTypes
        Self.fileCreationCommands.removeAll(keepingCapacity: true)
        Self.nextCommandID = 1

        guard !fileTypes.isEmpty else {
            let item = NSMenuItem(title: "No enabled file types", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
            return menu
        }

        let submenu = NSMenu(title: "New File")

        for fileType in fileTypes {
            let commandID = Self.nextCommandID
            Self.nextCommandID += 1
            Self.fileCreationCommands[commandID] = FileCreationCommand(
                fileType: fileType,
                directoryPath: directory.path
            )

            let item = NSMenuItem(
                title: "\(fileType.name) (\(fileType.displayExtension))",
                action: #selector(createFile(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.tag = commandID
            item.image = NSImage(systemSymbolName: fileType.systemImage, accessibilityDescription: fileType.name)
            submenu.addItem(item)
        }

        let yclickItem = NSMenuItem(title: "YClick", action: nil, keyEquivalent: "")
        yclickItem.image = NSImage(systemSymbolName: "doc.badge.plus", accessibilityDescription: "YClick")
        yclickItem.submenu = submenu
        menu.addItem(yclickItem)
        return menu
    }

    @objc func createFile(_ sender: Any) {
        NSLog("YClick createFile action started")
        logger.info("Create file action started")

        guard let menuItem = sender as? NSMenuItem else {
            let message = "Could not read this file type."
            NSLog("YClick createFile failed before writing: %@ Sender: %@", message, String(describing: type(of: sender)))
            logger.error("\(message, privacy: .public) Sender: \(String(describing: type(of: sender)), privacy: .public)")
            return
        }

        guard let command = Self.fileCreationCommands[menuItem.tag] else {
            let message = "Could not match this menu item to a file type."
            NSLog("YClick createFile failed before writing: %@ Tag: %ld", message, menuItem.tag)
            logger.error("\(message, privacy: .public) Tag: \(menuItem.tag, privacy: .public)")
            return
        }

        let fileType = command.fileType
        let directory = URL(fileURLWithPath: command.directoryPath, isDirectory: true)
        NSLog("YClick createFile resolved type %@ in %@", fileType.name, directory.path)
        logger.info("Creating \(fileType.displayExtension, privacy: .public) in \(directory.path, privacy: .public)")

        do {
            let createdURL = try creationService.createFile(for: fileType, in: directory)
            NSLog("YClick created file at %@", createdURL.path)
            logger.info("Created file at \(createdURL.path, privacy: .public)")
        } catch {
            NSLog("YClick createFile write failed: %@", error.localizedDescription)
            logger.error("Create file failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func monitoredDirectories() -> Set<URL> {
        [
            URL(fileURLWithPath: "/", isDirectory: true)
        ]
    }

    private func targetDirectory(for menuKind: FIMenuKind) -> URL? {
        let controller = FIFinderSyncController.default()

        if menuKind == .contextualMenuForItems,
           let firstSelectedURL = controller.selectedItemURLs()?.first {
            if firstSelectedURL.hasDirectoryPath {
                return firstSelectedURL
            }

            return firstSelectedURL.deletingLastPathComponent()
        }

        if let targetedURL = controller.targetedURL() {
            if targetedURL.hasDirectoryPath {
                return targetedURL
            }

            return targetedURL.deletingLastPathComponent()
        }

        if let firstSelectedURL = controller.selectedItemURLs()?.first {
            if firstSelectedURL.hasDirectoryPath {
                return firstSelectedURL
            }

            return firstSelectedURL.deletingLastPathComponent()
        }

        return nil
    }

}
