import Foundation
import AppKit

class ClipboardStore: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var maxItems: Int {
        didSet {
            UserDefaults.standard.set(maxItems, forKey: "maxItems")
            trimToMax()
            saveItems()
        }
    }

    private var lastChangeCount: Int = -1
    private var timer: Timer?
    private let storageURL: URL
    private let imagesURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appDir = appSupport.appendingPathComponent("ClipboardManager")
        storageURL = appDir.appendingPathComponent("history.json")
        imagesURL  = appDir.appendingPathComponent("images")

        try? FileManager.default.createDirectory(at: appDir,    withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: imagesURL, withIntermediateDirectories: true)

        let saved = UserDefaults.standard.integer(forKey: "maxItems")
        maxItems = saved > 0 ? saved : 10

        loadItems()
        lastChangeCount = NSPasteboard.general.changeCount
        startMonitoring()
    }

    deinit { timer?.invalidate() }

    // MARK: - Monitoring

    private func startMonitoring() {
        let t = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func checkClipboard() {
        let pb = NSPasteboard.general
        let count = pb.changeCount
        guard count != lastChangeCount else { return }
        lastChangeCount = count
        if let item = readPasteboard(pb) {
            DispatchQueue.main.async { self.addItem(item) }
        }
    }

    private func readPasteboard(_ pb: NSPasteboard) -> ClipboardItem? {
        // File URLs first (Finder copies, drag-drop)
        let urlOptions: [NSPasteboard.ReadingOptionKey: Any] = [.urlReadingFileURLsOnly: true]
        if let urls = pb.readObjects(forClasses: [NSURL.self], options: urlOptions) as? [URL], !urls.isEmpty {
            let paths = urls.map(\.path).joined(separator: "\n")
            return ClipboardItem(id: UUID(), type: .fileURL, text: paths, imageFilename: nil, timestamp: Date())
        }

        // Images (browser copy, graphics apps)
        if let images = pb.readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage],
           let image = images.first,
           let tiff   = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff),
           let png    = bitmap.representation(using: .png, properties: [:]) {
            let filename = UUID().uuidString + ".png"
            try? png.write(to: imagesURL.appendingPathComponent(filename))
            return ClipboardItem(id: UUID(), type: .image, text: nil, imageFilename: filename, timestamp: Date())
        }

        // Plain text
        if let string = pb.string(forType: .string),
           !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return ClipboardItem(id: UUID(), type: .text, text: string, imageFilename: nil, timestamp: Date())
        }

        return nil
    }

    // MARK: - Public API

    func addItem(_ item: ClipboardItem) {
        // Deduplicate text and file items by content
        if item.type != .image {
            items.removeAll { $0.type == item.type && $0.text == item.text }
        }
        items.insert(item, at: 0)
        trimToMax()
        saveItems()
    }

    func copyToClipboard(_ item: ClipboardItem) {
        let pb = NSPasteboard.general
        pb.clearContents()

        switch item.type {
        case .text:
            if let text = item.text { pb.setString(text, forType: .string) }

        case .fileURL:
            if let text = item.text {
                let urls = text.split(separator: "\n")
                    .compactMap { URL(fileURLWithPath: String($0)) as NSURL? }
                pb.writeObjects(urls)
            }

        case .image:
            if let filename = item.imageFilename,
               let data  = try? Data(contentsOf: imagesURL.appendingPathComponent(filename)),
               let image = NSImage(data: data) {
                pb.writeObjects([image])
            }
        }

        // Prevent re-ingesting the item we just wrote
        lastChangeCount = pb.changeCount
    }

    func clearAll() {
        for item in items where item.type == .image {
            if let fn = item.imageFilename {
                try? FileManager.default.removeItem(at: imagesURL.appendingPathComponent(fn))
            }
        }
        items.removeAll()
        saveItems()
    }

    // MARK: - Persistence

    private func trimToMax() {
        while items.count > maxItems {
            let removed = items.removeLast()
            if removed.type == .image, let fn = removed.imageFilename {
                try? FileManager.default.removeItem(at: imagesURL.appendingPathComponent(fn))
            }
        }
    }

    private func saveItems() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: storageURL, options: .atomic)
    }

    private func loadItems() {
        guard let data    = try? Data(contentsOf: storageURL),
              let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) else { return }
        items = decoded
    }
}
