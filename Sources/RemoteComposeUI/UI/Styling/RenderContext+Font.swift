#if canImport(SwiftUI)
import SwiftUI

extension RenderContext {
    func font(for text: TextLayoutOperation) -> Font {
        let size = max(CGFloat(float(text.fontSize, default: 16)), 1)
        let weight = Self.fontWeight(float(text.fontWeight, default: 400))
        
        var design = Font.Design.default
        if text.fontFamilyId != -1, let family = string(for: text.fontFamilyId) {
            switch family.lowercased() {
            case "serif": design = .serif
            case "monospace": design = .monospaced
            default: design = .default
            }
        }
        
        var font = Font.system(size: size, weight: weight, design: design)
        if text.fontStyle == 1 { font = font.italic() }
        return font
    }
    
    static func fontWeight(_ value: Float) -> Font.Weight {
        switch value {
        case ..<150: return .ultraLight
        case ..<250: return .thin
        case ..<350: return .light
        case ..<450: return .regular
        case ..<550: return .medium
        case ..<650: return .semibold
        case ..<750: return .bold
        case ..<850: return .heavy
        default: return .black
        }
    }
}
#endif
