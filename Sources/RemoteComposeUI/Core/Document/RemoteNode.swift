import Foundation

public enum RemoteModifier: Equatable {
    case background(BackgroundModifierOperation)
    case width(WidthModifierOperation)
    case height(HeightModifierOperation)
}

public enum RemoteCanvasCommand: Equatable {
    case paint(PaintDataOperation)
    case drawTextAnchored(DrawTextAnchoredOperation)
}

public struct RemoteNode: Identifiable, Equatable {
    public enum Kind: Equatable {
        case root(RootLayoutOperation)
        case content(LayoutContentOperation)
        case row(RowLayoutOperation)
        case column(ColumnLayoutOperation)
        case canvas(CanvasLayoutOperation)
        case text(TextLayoutOperation)
    }
    
    public let id: Int
    public var kind: Kind
    public var modifiers: [RemoteModifier]
    public var children: [RemoteNode]
    public var canvasCommands: [RemoteCanvasCommand]
    
    public init(
        id: Int,
        kind: Kind,
        modifiers: [RemoteModifier] = [],
        children: [RemoteNode] = [],
        canvasCommands: [RemoteCanvasCommand] = []
    ) {
        self.id = id
        self.kind = kind
        self.modifiers = modifiers
        self.children = children
        self.canvasCommands = canvasCommands
    }
}
