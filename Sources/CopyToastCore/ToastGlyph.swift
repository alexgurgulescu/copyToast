import AppKit

/// The copyToast mark, two overlapping toasts, as a template image so macOS tints it.
/// Uses the same geometry as scripts/make-icon.swift, in its 1024-point space.
public enum ToastGlyph {
    private static let bounds = CGRect(x: 217, y: 237, width: 590, height: 550)

    public static func image(height: CGFloat) -> NSImage {
        let scale = height / bounds.height
        let size = NSSize(width: bounds.width * scale, height: height)
        let image = NSImage(size: size, flipped: false) { _ in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.scaleBy(x: scale, y: scale)
            ctx.translateBy(x: -bounds.minX, y: -bounds.minY)

            let back = slicePath(center: CGPoint(x: 437, y: 577))
            let front = slicePath(center: CGPoint(x: 587, y: 447))

            ctx.beginTransparencyLayer(auxiliaryInfo: nil)
            ctx.setStrokeColor(.black)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            ctx.addPath(back)
            ctx.setLineWidth(44)
            ctx.strokePath()

            // Clear a gap around the front toast so it sits on top of the back one.
            ctx.setBlendMode(.clear)
            ctx.addPath(front)
            ctx.fillPath()
            ctx.addPath(front)
            ctx.setLineWidth(104)
            ctx.strokePath()

            ctx.setBlendMode(.normal)
            ctx.addPath(front)
            ctx.setLineWidth(44)
            ctx.strokePath()
            ctx.endTransparencyLayer()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "copyToast"
        return image
    }

    private static func slicePath(center: CGPoint) -> CGPath {
        var place = CGAffineTransform(translationX: center.x, y: center.y)
            .scaledBy(x: 0.66, y: 0.66)
            .translatedBy(x: -512, y: -516)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 330, y: 232))
        path.addLine(to: CGPoint(x: 694, y: 232))
        path.addCurve(to: CGPoint(x: 762, y: 300), control1: CGPoint(x: 732, y: 232), control2: CGPoint(x: 762, y: 262))
        path.addLine(to: CGPoint(x: 762, y: 560))
        path.addCurve(to: CGPoint(x: 812, y: 672), control1: CGPoint(x: 800, y: 590), control2: CGPoint(x: 812, y: 630))
        path.addCurve(to: CGPoint(x: 650, y: 800), control1: CGPoint(x: 812, y: 750), control2: CGPoint(x: 740, y: 800))
        path.addLine(to: CGPoint(x: 374, y: 800))
        path.addCurve(to: CGPoint(x: 212, y: 672), control1: CGPoint(x: 284, y: 800), control2: CGPoint(x: 212, y: 750))
        path.addCurve(to: CGPoint(x: 262, y: 560), control1: CGPoint(x: 212, y: 630), control2: CGPoint(x: 224, y: 590))
        path.addLine(to: CGPoint(x: 262, y: 300))
        path.addCurve(to: CGPoint(x: 330, y: 232), control1: CGPoint(x: 262, y: 262), control2: CGPoint(x: 292, y: 232))
        path.closeSubpath()
        return path.copy(using: &place)!
    }
}
