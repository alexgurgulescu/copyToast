import AppKit
import CopyToastCore
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let pasteboard = NSPasteboard.general
    private let toasts = ToastController()
    private var lastChangeCount = NSPasteboard.general.changeCount
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    private var isPaused = false

    private let pauseItem = NSMenuItem(title: "Pause", action: #selector(togglePause), keyEquivalent: "")
    private let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")

    func applicationDidFinishLaunching(_ notification: Notification) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = ToastGlyph.image(height: 16)
        item.button?.toolTip = "copyToast"
        item.menu = makeMenu()
        statusItem = item
        startWatching()
    }

    // MARK: Menu

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        pauseItem.target = self
        loginItem.target = self
        menu.addItem(pauseItem)
        menu.addItem(loginItem)
        menu.addItem(.separator())

        let aboutItem = NSMenuItem(title: "About copyToast", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        // A custom action, because macOS adds an icon to the standard terminate: item.
        let quitItem = NSMenuItem(title: "Quit copyToast", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        return menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        pauseItem.state = isPaused ? .on : .off
        switch SMAppService.mainApp.status {
        case .enabled: loginItem.state = .on
        case .requiresApproval: loginItem.state = .mixed
        default: loginItem.state = .off
        }
    }

    @objc private func togglePause() {
        isPaused.toggle()
        statusItem?.button?.appearsDisabled = isPaused
        statusItem?.button?.toolTip = isPaused ? "copyToast (paused)" : "copyToast"
        if isPaused {
            timer?.invalidate()
            timer = nil
        } else {
            // Copies made while paused should not trigger a toast on resume.
            lastChangeCount = pasteboard.changeCount
            startWatching()
        }
    }

    @objc private func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled || service.status == .requiresApproval {
                try service.unregister()
            } else {
                try service.register()
                if service.status == .requiresApproval {
                    SMAppService.openSystemSettingsLoginItems()
                }
            }
        } catch {
            NSApp.activate()
            let alert = NSAlert()
            alert.messageText = "Couldn't change Launch at Login"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }

    @objc private func showAbout() {
        NSApp.activate()
        NSApp.orderFrontStandardAboutPanel(options: [
            .credits: NSAttributedString(
                string: "Confirms what you copy in Finder.",
                attributes: [.font: NSFont.systemFont(ofSize: 11), .foregroundColor: NSColor.secondaryLabelColor]
            ),
        ])
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    // MARK: Clipboard

    private func startWatching() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.poll() }
        }
    }

    private func poll() {
        let changeCount = pasteboard.changeCount
        guard changeCount != lastChangeCount else { return }
        lastChangeCount = changeCount

        guard NSWorkspace.shared.frontmostApplication?.bundleIdentifier == "com.apple.finder" else { return }

        if let toast = Toast(for: ClipboardInspector.inspect(pasteboard)) {
            toasts.show(toast)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
