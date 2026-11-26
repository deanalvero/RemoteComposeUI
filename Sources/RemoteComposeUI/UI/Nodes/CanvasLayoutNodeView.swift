#if canImport(SwiftUI)
import SwiftUI

struct CanvasLayoutNodeView: View {
    let children: [RemoteNode]
    let commands: [RemoteCanvasCommand]
    let context: RenderContext
    
    private var textDraws: [CanvasTextDraw] {
        var paint = PaintTextAttributes()
        var result: [CanvasTextDraw] = []
        for command in commands {
            switch command {
            case .paint(let operation):
                paint.merge(operation.textAttributes)
            case .drawTextAnchored(let operation):
                result.append(CanvasTextDraw(id: result.count, operation: operation, paint: paint))
            }
        }
        return result
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(textDraws) { draw in
                anchoredText(draw)
            }
            ChildrenView(children: children, context: context)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    @ViewBuilder
    private func anchoredText(_ draw: CanvasTextDraw) -> some View {
        let operation = draw.operation
        let x = CGFloat(context.float(operation.x, default: 0))
        let y = CGFloat(context.float(operation.y, default: 0))
        let panX = CGFloat(context.float(operation.panX, default: 0))
        let panY = CGFloat(context.float(operation.panY, default: 0))
        let safePanX = min(max(panX, -1), 1)
        let safePanY = min(max(panY, -1), 1)
        
        Text(context.string(for: operation.textId) ?? "")
            .font(font(for: draw.paint))
            .foregroundColor(color(for: draw.paint))
            .opacity(Double(draw.paint.alpha?.resolved(with: context.variables, default: 1) ?? 1))
            .multilineTextAlignment(operation.flags & DrawTextAnchoredOperation.anchorTextRTL != 0 ? .trailing : .center)
            .lineLimit(nil)
            .fixedSize()
            .alignmentGuide(.leading) { dimensions in
                dimensions.width * (1 + safePanX) / 2 - x
            }
            .alignmentGuide(.top) { dimensions in
                if operation.flags & DrawTextAnchoredOperation.baselineRelative != 0 {
                    return dimensions[.firstTextBaseline] - y - dimensions.height * safePanY / 2
                }
                return dimensions.height * (1 - safePanY) / 2 - y
            }
    }
    
    private func color(for paint: PaintTextAttributes) -> Color {
        if let argb = paint.colorARGB { return Color(argb: argb) }
        if let id = paint.colorId, let argb = context.variables.colors[id] { return Color(argb: argb) }
        return .black
    }
    
    private func font(for paint: PaintTextAttributes) -> Font {
        let size = max(Double(paint.textSize?.resolved(with: context.variables, default: 16) ?? 16), 1)
        let style = paint.fontStyle ?? 400
        let androidWeight = style & 0x3FF
        let isItalic = (style >> 10) > 0
        let weight: Font.Weight
        switch androidWeight {
        case ..<150: weight = .ultraLight
        case ..<250: weight = .thin
        case ..<350: weight = .light
        case ..<450: weight = .regular
        case ..<550: weight = .medium
        case ..<650: weight = .semibold
        case ..<750: weight = .bold
        case ..<850: weight = .heavy
        default: weight = .black
        }
        let design: Font.Design
        switch paint.fontFamily {
        case 2: design = .serif
        case 3: design = .monospaced
        default: design = .default
        }
        let base = Font.system(size: size, weight: weight, design: design)
        return isItalic ? base.italic() : base
    }
}

private struct CanvasTextDraw: Identifiable {
    let id: Int
    let operation: DrawTextAnchoredOperation
    let paint: PaintTextAttributes
}
#endif
