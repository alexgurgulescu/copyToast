import AppKit

public enum CopyKind: Equatable, Sendable {
    case items(files: Int, folders: Int)
    case paths(Int)
    case concealed
    case other
}

public enum ClipboardInspector {
    private static let concealedType = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")

    /// Works out what was copied. Returns only a kind and counts, never content.
    @MainActor
    public static func inspect(_ pasteboard: NSPasteboard) -> CopyKind {
        let types = pasteboard.types ?? []

        // Decided from type names alone, so concealed data is never read.
        if types.contains(concealedType) { return .concealed }

        if types.contains(.fileURL) {
            let options: [NSPasteboard.ReadingOptionKey: Any] = [.urlReadingFileURLsOnly: true]
            let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: options) as? [URL] ?? []
            guard !urls.isEmpty else { return .other }
            // hasDirectoryPath needs no file system access, so the sandbox stays tight.
            let folders = urls.filter(\.hasDirectoryPath).count
            return .items(files: urls.count - folders, folders: folders)
        }

        if types.contains(.string), let text = pasteboard.string(forType: .string) {
            return classify(text: text)
        }
        return .other
    }

    static func classify(text: String) -> CopyKind {
        guard let count = countPaths(in: text), count > 0 else { return .other }
        return .paths(count)
    }

    /// Counts paths in Finder's Copy as Pathname text, or returns nil if it isn't that format.
    /// Finder separates several paths with spaces and single-quotes those containing spaces,
    /// for example: '/a/my file.txt' /a/b.txt /a/c.txt. A lone path may be unquoted with spaces.
    private static func countPaths(in text: String) -> Int? {
        let chars = Array(text)
        var index = 0
        var count = 0

        while true {
            while index < chars.count, chars[index].isWhitespace { index += 1 }
            guard index < chars.count else { return count }

            if chars[index] == "'" {
                guard index + 1 < chars.count, chars[index + 1] == "/" else { return nil }
                index += 1
                while true {
                    guard index < chars.count else { return nil } // Unterminated quote.
                    if chars[index] != "'" {
                        index += 1
                    } else if index + 3 < chars.count, String(chars[(index + 1)...(index + 3)]) == "\\''" {
                        index += 4 // An escaped apostrophe: '\''
                    } else {
                        index += 1
                        break
                    }
                }
                guard index == chars.count || chars[index].isWhitespace else { return nil }
            } else if chars[index] == "/" {
                while index < chars.count, !chars[index].isNewline, !startsNextPath(chars, at: index) {
                    index += 1
                }
            } else {
                return nil
            }
            count += 1
        }
    }

    private static func startsNextPath(_ chars: [Character], at index: Int) -> Bool {
        guard chars[index] == " ", index + 1 < chars.count else { return false }
        if chars[index + 1] == "/" { return true }
        return chars[index + 1] == "'" && index + 2 < chars.count && chars[index + 2] == "/"
    }
}
