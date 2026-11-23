public struct Toast: Equatable, Sendable {
    public enum Icon: Equatable, Sendable {
        case logo
        case folder
        case path
    }

    public let text: String
    public let icon: Icon

    /// The toast for a copy, or nil when the copy should show nothing.
    public init?(for kind: CopyKind) {
        switch kind {
        case let .items(files, 0) where files > 0:
            text = files == 1 ? "File copied" : "\(files) files copied"
            icon = .logo
        case let .items(0, folders) where folders > 0:
            text = folders == 1 ? "Folder copied" : "\(folders) folders copied"
            icon = .folder
        case let .items(files, folders) where files > 0 && folders > 0:
            text = "\(Self.counted(files, "file")) and \(Self.counted(folders, "folder")) copied"
            icon = .logo
        case let .paths(count) where count > 0:
            text = count == 1 ? "Path copied" : "\(count) paths copied"
            icon = .path
        default:
            return nil
        }
    }

    private static func counted(_ count: Int, _ noun: String) -> String {
        "\(count) \(noun)\(count == 1 ? "" : "s")"
    }
}
