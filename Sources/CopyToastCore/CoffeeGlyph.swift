import AppKit

/// The Lucide "coffee" icon, drawn natively. See THIRD_PARTY_NOTICES.md for its license.
public enum CoffeeGlyph {
    public static func image(size: CGFloat, color: NSColor) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: true) { _ in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.scaleBy(x: size / 24, y: size / 24)
            color.setStroke()
            ctx.setLineWidth(2)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            ctx.addPath(path())
            ctx.strokePath()
            return true
        }
        // Redraw each time so a dynamic color follows light and dark mode.
        image.cacheMode = .never
        image.accessibilityDescription = "Coffee"
        return image
    }

    /// The icon's SVG paths, on its 24-point grid with y pointing down.
    private static func path() -> CGPath {
        let path = CGMutablePath()
        for x in [6, 10, 14] as [CGFloat] {
            path.move(to: CGPoint(x: x, y: 2))
            path.addLine(to: CGPoint(x: x, y: 4))
        }

        path.move(to: CGPoint(x: 16, y: 8))
        path.addArc(center: CGPoint(x: 16, y: 9), radius: 1, startAngle: -.pi / 2, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: 17, y: 17))
        path.addArc(center: CGPoint(x: 13, y: 17), radius: 4, startAngle: 0, endAngle: .pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: 7, y: 21))
        path.addArc(center: CGPoint(x: 7, y: 17), radius: 4, startAngle: .pi / 2, endAngle: .pi, clockwise: false)
        path.addLine(to: CGPoint(x: 3, y: 9))
        path.addArc(center: CGPoint(x: 4, y: 9), radius: 1, startAngle: .pi, endAngle: .pi * 1.5, clockwise: false)
        path.addLine(to: CGPoint(x: 18, y: 8))
        path.addArc(center: CGPoint(x: 18, y: 12), radius: 4, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: 17, y: 16))
        return path
    }
}
