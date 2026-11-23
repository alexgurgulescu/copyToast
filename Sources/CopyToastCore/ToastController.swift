import AppKit
import SwiftUI

/// Shows one toast at a time. Showing again while visible updates the same panel.
@MainActor
public final class ToastController {
    private static let slideDuration: TimeInterval = 0.22
    private static let holdDuration: Duration = .milliseconds(1400)
    private static let bottomInset: CGFloat = 64
    private static let slideDistance: CGFloat = 20

    let panel = ToastPanel()
    private let hostingView = NSHostingView(rootView: ToastView(toast: nil))
    private var hideTask: Task<Void, Never>?
    private var generation = 0

    public init() {
        panel.contentView = hostingView
    }

    public func show(_ toast: Toast) {
        hostingView.rootView = ToastView(toast: toast)
        hostingView.layoutSubtreeIfNeeded()
        // Without a display, leave any pending hide in place so a visible toast can't get stuck.
        guard let restingFrame = restingFrame(size: hostingView.fittingSize) else { return }

        generation += 1
        hideTask?.cancel()

        if !panel.isVisible {
            panel.setFrame(restingFrame.offsetBy(dx: 0, dy: -Self.slideDistance), display: false)
            panel.alphaValue = 0
            panel.orderFrontRegardless()
        }
        animate(to: restingFrame, alpha: 1)

        hideTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(Int(Self.slideDuration * 1000)) + Self.holdDuration)
            guard !Task.isCancelled else { return }
            self?.hide()
        }
    }

    private func hide() {
        let hidingGeneration = generation
        animate(to: panel.frame.offsetBy(dx: 0, dy: -Self.slideDistance), alpha: 0) { [weak self] in
            // A newer toast may have arrived during the slide-out.
            guard let self, self.generation == hidingGeneration else { return }
            self.panel.orderOut(nil)
        }
    }

    private func animate(to frame: NSRect, alpha: CGFloat, completion: (@MainActor () -> Void)? = nil) {
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            panel.setFrame(frame, display: true)
            panel.alphaValue = alpha
            panel.invalidateShadow()
            completion?()
            return
        }
        let panel = panel
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Self.slideDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().setFrame(frame, display: true)
            panel.animator().alphaValue = alpha
        } completionHandler: {
            Task { @MainActor in
                panel.invalidateShadow()
                completion?()
            }
        }
    }

    private func restingFrame(size: NSSize) -> NSRect? {
        let mouse = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(mouse, $0.frame, false) })
            ?? NSScreen.main else { return nil }
        let area = screen.visibleFrame
        let origin = NSPoint(x: (area.midX - size.width / 2).rounded(), y: area.minY + Self.bottomInset - ToastView.shadowMargin)
        return NSRect(origin: origin, size: size)
    }
}

/// Never takes focus, passes clicks through, and is excluded from screen capture.
final class ToastPanel: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 48),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        ignoresMouseEvents = true
        sharingType = .none
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        animationBehavior = .none
        isOpaque = false
        backgroundColor = .clear
        // The system window shadow adds an outline, so ToastView draws its own.
        hasShadow = false
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

struct ToastView: View {
    /// Transparent space around the card so its shadow isn't clipped by the window.
    static let shadowMargin: CGFloat = 16

    let toast: Toast?
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    @ViewBuilder private var icon: some View {
        switch toast?.icon ?? .logo {
        case .logo:
            Image(nsImage: ToastGlyph.image(height: 13)).renderingMode(.template)
        case .folder:
            Image(systemName: "folder").font(.system(size: 11, weight: .medium))
        case .path:
            Image(systemName: "link").font(.system(size: 11, weight: .medium))
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            icon
            Text(toast?.text ?? "")
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(isDark ? Color.black : Color.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .fixedSize()
        .background(
            isDark ? Color.white : Color(white: 0.07),
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
        .shadow(
            color: isDark ? .white.opacity(0.22) : .black.opacity(0.28),
            radius: 8,
            y: isDark ? 0 : 3
        )
        .padding(Self.shadowMargin)
        .accessibilityElement(children: .combine)
    }
}
