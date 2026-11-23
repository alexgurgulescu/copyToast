import AppKit
import Testing
@testable import CopyToastCore

struct ToastTextTests {
    @Test(arguments: [
        (CopyKind.items(files: 1, folders: 0), "File copied"),
        (.items(files: 3, folders: 0), "3 files copied"),
        (.items(files: 0, folders: 1), "Folder copied"),
        (.items(files: 0, folders: 2), "2 folders copied"),
        (.items(files: 3, folders: 2), "3 files and 2 folders copied"),
        (.items(files: 1, folders: 1), "1 file and 1 folder copied"),
        (.paths(1), "Path copied"),
        (.paths(4), "4 paths copied"),
    ])
    func text(kind: CopyKind, expected: String) {
        #expect(Toast(for: kind)?.text == expected)
    }

    @Test(arguments: [CopyKind.other, .concealed, .items(files: 0, folders: 0), .paths(0)])
    func showsNothing(kind: CopyKind) {
        #expect(Toast(for: kind) == nil)
    }
}

@MainActor
struct ToastPanelTests {
    @Test func staysOutOfTheWay() {
        let panel = ToastPanel()
        #expect(panel.ignoresMouseEvents)
        #expect(!panel.canBecomeKey)
        #expect(!panel.canBecomeMain)
        #expect(panel.styleMask.contains(.nonactivatingPanel))
        #expect(panel.sharingType == .none)
        #expect(panel.collectionBehavior.contains(.canJoinAllSpaces))
        #expect(panel.collectionBehavior.contains(.fullScreenAuxiliary))
    }
}
