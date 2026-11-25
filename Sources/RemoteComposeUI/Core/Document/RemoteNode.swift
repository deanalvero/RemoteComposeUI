import Foundation

public enum RemoteModifier: Equatable {
    case background(BackgroundModifierOperation)
}

public struct RemoteNode: Identifiable, Equatable {
    public enum Kind: Equatable {
        case root(RootLayoutOperation)
        case content(LayoutContentOperation)
        case row(RowLayoutOperation)
        case column(ColumnLayoutOperation)
        case text(TextLayoutOperation)
    }

    public let id: Int
    public var kind: Kind
    public var modifiers: [RemoteModifier]
    public var children: [RemoteNode]

    public init(id: Int, kind: Kind, modifiers: [RemoteModifier] = [], children: [RemoteNode] = []) {
        self.id = id
        self.kind = kind
        self.modifiers = modifiers
        self.children = children
    }
}
