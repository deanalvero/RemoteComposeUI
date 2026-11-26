import Foundation

public enum RemoteOperation: Equatable {
    case header(HeaderOperation)
    case textData(TextDataOperation)
    case dataListIds(DataListIdsOperation)
    case floatExpression(FloatExpressionOperation)
    case componentValue(ComponentValueOperation)
    case textFromFloat(TextFromFloatOperation)
    case textMerge(TextMergeOperation)
    case textLookup(TextLookupOperation)
    case paintData(PaintDataOperation)
    case drawTextAnchored(DrawTextAnchoredOperation)
    case rootLayout(RootLayoutOperation)
    case layoutContent(LayoutContentOperation)
    case rowLayout(RowLayoutOperation)
    case columnLayout(ColumnLayoutOperation)
    case canvasLayout(CanvasLayoutOperation)
    case textLayout(TextLayoutOperation)
    case backgroundModifier(BackgroundModifierOperation)
    case widthModifier(WidthModifierOperation)
    case heightModifier(HeightModifierOperation)
    case containerEnd
    
    public var opCode: Int {
        switch self {
        case .header: return OpCode.header
        case .textData: return OpCode.dataText
        case .dataListIds: return OpCode.dataListIds
        case .floatExpression: return OpCode.floatExpression
        case .componentValue: return OpCode.componentValue
        case .textFromFloat: return OpCode.textFromFloat
        case .textMerge: return OpCode.textMerge
        case .textLookup: return OpCode.textLookup
        case .paintData: return OpCode.paintData
        case .drawTextAnchored: return OpCode.drawTextAnchored
        case .rootLayout: return OpCode.layoutRoot
        case .layoutContent: return OpCode.layoutContent
        case .rowLayout: return OpCode.layoutRow
        case .columnLayout: return OpCode.layoutColumn
        case .canvasLayout: return OpCode.layoutCanvas
        case .textLayout: return OpCode.layoutText
        case .backgroundModifier: return OpCode.modifierBackground
        case .widthModifier: return OpCode.modifierWidth
        case .heightModifier: return OpCode.modifierHeight
        case .containerEnd: return OpCode.containerEnd
        }
    }
    
    public var name: String { OpCode.name(of: opCode) ?? "UNKNOWN" }
}
