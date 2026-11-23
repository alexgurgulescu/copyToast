import AppKit
import Testing
@testable import CopyToastCore

@MainActor
struct ClipboardInspectorTests {
    /// A private pasteboard, so tests never touch the real clipboard.
    private func withPasteboard(_ body: (NSPasteboard) -> Void) {
        let pasteboard = NSPasteboard.withUniqueName()
        defer { pasteboard.releaseGlobally() }
        pasteboard.clearContents()
        body(pasteboard)
    }

    @Test func countsFilesAndFolders() {
        withPasteboard { pasteboard in
            let urls: [NSURL] = [
                NSURL(fileURLWithPath: "/tmp/a.txt", isDirectory: false),
                NSURL(fileURLWithPath: "/tmp/b.txt", isDirectory: false),
                NSURL(fileURLWithPath: "/tmp/folder", isDirectory: true),
            ]
            pasteboard.writeObjects(urls)
            #expect(ClipboardInspector.inspect(pasteboard) == .items(files: 2, folders: 1))
        }
    }

    @Test func countsPathsOnePerLine() {
        withPasteboard { pasteboard in
            pasteboard.setString("/tmp/a\n/tmp/b\n", forType: .string)
            #expect(ClipboardInspector.inspect(pasteboard) == .paths(2))
        }
    }

    @Test func countsFinderPathFormats() {
        #expect(ClipboardInspector.classify(text: "/tmp/a.txt") == .paths(1))
        #expect(ClipboardInspector.classify(text: "/tmp/my file.txt") == .paths(1))
        #expect(ClipboardInspector.classify(text: "'/tmp/my file.txt'") == .paths(1))
        #expect(ClipboardInspector.classify(text: "/tmp/a /tmp/b /tmp/c") == .paths(3))
        #expect(ClipboardInspector.classify(text: "'/tmp/my file' /tmp/b /tmp/c") == .paths(3))
        #expect(ClipboardInspector.classify(text: "/tmp/a '/tmp/my file' '/tmp/other file'") == .paths(3))
        #expect(ClipboardInspector.classify(text: #"'/tmp/it'\''s here' /tmp/b"#) == .paths(2))
    }

    @Test func rejectsTextThatOnlyLooksLikePaths() {
        #expect(ClipboardInspector.classify(text: "'quoted words'") == .other)
        #expect(ClipboardInspector.classify(text: "'/tmp/unterminated") == .other)
        #expect(ClipboardInspector.classify(text: "see /tmp/a") == .other)
        #expect(ClipboardInspector.classify(text: "") == .other)
    }

    @Test func ignoresOtherText() {
        withPasteboard { pasteboard in
            pasteboard.setString("renamed file", forType: .string)
            #expect(ClipboardInspector.inspect(pasteboard) == .other)
        }
    }

    @Test func ignoresMixedPathAndText() {
        #expect(ClipboardInspector.classify(text: "/tmp/a\nnot a path") == .other)
    }

    @Test func ignoresConcealedCopies() {
        withPasteboard { pasteboard in
            let concealed = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")
            pasteboard.declareTypes([.string, concealed], owner: nil)
            pasteboard.setString("/looks/like/a/path", forType: .string)
            pasteboard.setString("", forType: concealed)
            #expect(ClipboardInspector.inspect(pasteboard) == .concealed)
        }
    }
}
