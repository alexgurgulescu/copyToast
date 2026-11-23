#!/usr/bin/env swift
// Generates Config/AppIcon.icns. Run from the repo root: swift scripts/make-icon.swift
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// The macOS icon shape: a superellipse on the standard 824-point grid.
func squirclePath(in rect: CGRect, exponent: CGFloat = 5) -> CGPath {
    let path = CGMutablePath()
    let steps = 720
    for step in 0..<steps {
        let angle = CGFloat(step) / CGFloat(steps) * 2 * .pi
        let (c, s) = (cos(angle), sin(angle))
        let x = rect.midX + rect.width / 2 * copysign(pow(abs(c), 2 / exponent), c)
        let y = rect.midY + rect.height / 2 * copysign(pow(abs(s), 2 / exponent), s)
        if step == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
    }
    path.closeSubpath()
    return path
}

/// A slice of toast. Sources/CopyToastCore/ToastGlyph.swift uses the same outline.
func slicePath() -> CGPath {
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
    return path
}

func placedSlice(center: CGPoint) -> CGPath {
    var place = CGAffineTransform(translationX: center.x, y: center.y)
        .scaledBy(x: 0.66, y: 0.66)
        .translatedBy(x: -512, y: -516)
    return slicePath().copy(using: &place)!
}

func render(pixels: Int) -> CGImage {
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    let ctx = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
                        space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)

    // Background, with a soft drop shadow.
    let shape = squirclePath(in: CGRect(x: 100, y: 100, width: 824, height: 824))
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: CGColor(gray: 0, alpha: 0.35))
    ctx.addPath(shape)
    ctx.setFillColor(CGColor(gray: 0.07, alpha: 1))
    ctx.fillPath()
    ctx.restoreGState()

    ctx.saveGState()
    ctx.addPath(shape)
    ctx.clip()
    let colors = [CGColor(gray: 0.19, alpha: 1), CGColor(gray: 0.05, alpha: 1)] as CFArray
    let gradient = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.genericGrayGamma2_2), colors: colors, locations: [0, 1])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 100), options: [])
    ctx.restoreGState()

    // Two overlapping white toast outlines, forming a copy symbol.
    let back = placedSlice(center: CGPoint(x: 437, y: 577))
    let front = placedSlice(center: CGPoint(x: 587, y: 447))

    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
    ctx.setStrokeColor(CGColor(gray: 1, alpha: 1))
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

    return ctx.makeImage()!
}

func writePNG(_ image: CGImage, to url: URL) {
    let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    precondition(CGImageDestinationFinalize(destination), "Could not write \(url.lastPathComponent)")
}

let fileManager = FileManager.default
let workDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
let iconset = workDir.appendingPathComponent("AppIcon.iconset")
try fileManager.createDirectory(at: iconset, withIntermediateDirectories: true)
defer { try? fileManager.removeItem(at: workDir) }

for size in [16, 32, 128, 256, 512] {
    writePNG(render(pixels: size), to: iconset.appendingPathComponent("icon_\(size)x\(size).png"))
    writePNG(render(pixels: size * 2), to: iconset.appendingPathComponent("icon_\(size)x\(size)@2x.png"))
}

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = ["-c", "icns", iconset.path, "-o", "Config/AppIcon.icns"]
try iconutil.run()
iconutil.waitUntilExit()
precondition(iconutil.terminationStatus == 0, "iconutil failed")
print("Wrote Config/AppIcon.icns")
