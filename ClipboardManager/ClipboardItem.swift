import Foundation

enum ClipboardItemType: String, Codable {
    case text
    case image
    case fileURL
}

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let type: ClipboardItemType
    let text: String?
    let imageFilename: String?
    let timestamp: Date

    var displayText: String {
        switch type {
        case .text:    return text ?? ""
        case .image:   return "[Image]"
        case .fileURL: return text ?? "[File]"
        }
    }

    var previewText: String {
        let s = displayText
        guard s.count > 55 else { return s }
        return String(s.prefix(55)) + "…"
    }

    var iconName: String {
        switch type {
        case .text:    return "doc.text"
        case .image:   return "photo"
        case .fileURL: return "folder"
        }
    }
}
