#!/usr/bin/env swift
// Draws the DMG window background. Usage: swift scripts/make-dmg-background.swift <out.png> <scale>
import AppKit

let width: CGFloat = 660
let height: CGFloat = 420
let appX: CGFloat = 175
let applicationsX: CGFloat = 485
let iconY: CGFloat = 200

let output = CommandLine.arguments[1]
let scale = CGFloat(Int(CommandLine.arguments[2])!)
let ink = NSColor(srgbRed: 0.09, green: 0.09, blue: 0.09, alpha: 1)
let muted = NSColor(srgbRed: 0.40, green: 0.40, blue: 0.40, alpha: 1)

let ctx = CGContext(data: nil, width: Int(width * scale), height: Int(height * scale), bitsPerComponent: 8,
                    bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.translateBy(x: 0, y: height * scale)
ctx.scaleBy(x: scale, y: -scale)
NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true)

ctx.setFillColor(NSColor.white.cgColor)
ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

func drawCentered(_ text: String, y: CGFloat, font: NSFont, color: NSColor) {
    let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
    let size = (text as NSString).size(withAttributes: attributes)
    (text as NSString).draw(at: CGPoint(x: (width - size.width) / 2, y: y), withAttributes: attributes)
}

drawCentered("Drag copyToast to Applications", y: 42, font: .systemFont(ofSize: 24, weight: .semibold), color: ink)

// A solid arc with an open head, leading from the app to Applications.
let start = CGPoint(x: appX + 84, y: iconY - 4)
let tip = CGPoint(x: applicationsX - 88, y: iconY - 4)
let control = CGPoint(x: width / 2, y: iconY - 42)
ctx.setStrokeColor(ink.cgColor)
ctx.setLineWidth(3)
ctx.setLineCap(.round)
ctx.setLineJoin(.round)
ctx.move(to: start)
ctx.addQuadCurve(to: tip, control: control)
ctx.strokePath()

let angle = atan2(tip.y - control.y, tip.x - control.x)
for side in [CGFloat.pi * 0.8, -CGFloat.pi * 0.8] {
    ctx.move(to: tip)
    ctx.addLine(to: CGPoint(x: tip.x + 15 * cos(angle + side), y: tip.y + 15 * sin(angle + side)))
}
ctx.strokePath()

drawCentered("First launch: if macOS blocks the app, open System Settings,", y: 342,
             font: .systemFont(ofSize: 12), color: muted)
drawCentered("then Privacy & Security, and click Open Anyway.", y: 360,
             font: .systemFont(ofSize: 12), color: muted)

let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
rep.size = NSSize(width: width, height: height)
try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: output))
