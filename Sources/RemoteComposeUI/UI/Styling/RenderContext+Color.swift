#if canImport(SwiftUI)
import SwiftUI

extension RenderContext {
    func color(for background: BackgroundModifierOperation) -> Color? {
        if background.usesColorId {
            guard let argb = variables.colors[background.colorId] else { return nil }
            return Color(argb: argb)
        }
        let r = Double(float(background.r, default: 0))
        let g = Double(float(background.g, default: 0))
        let b = Double(float(background.b, default: 0))
        let a = Double(float(background.a, default: 1))
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    func color(for text: TextLayoutOperation) -> Color {
        if text.usesDynamicColor {
            if let argb = variables.colors[text.color] { return Color(argb: argb) }
            return .primary
        }
        return Color(argb: UInt32(truncatingIfNeeded: text.color))
    }
}
#endif
