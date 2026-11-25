import Foundation

public typealias OperationReader = (inout WireReader) throws -> RemoteOperation

public struct OperationRegistry {
    private var readers: [Int: OperationReader]

    public init(readers: [Int: OperationReader] = [:]) {
        self.readers = readers
    }

    public mutating func register(_ opCode: Int, _ reader: @escaping OperationReader) {
        readers[opCode] = reader
    }

    public func reader(for opCode: Int) -> OperationReader? {
        readers[opCode]
    }

    public static var standard: OperationRegistry {
        var registry = OperationRegistry()
        registry.register(OpCode.header, HeaderOperation.read)
        registry.register(OpCode.dataText, TextDataOperation.read)
        registry.register(OpCode.layoutRoot, RootLayoutOperation.read)
        registry.register(OpCode.layoutContent, LayoutContentOperation.read)
        registry.register(OpCode.layoutRow, RowLayoutOperation.read)
        registry.register(OpCode.layoutColumn, ColumnLayoutOperation.read)
        registry.register(OpCode.layoutText, TextLayoutOperation.read)
        registry.register(OpCode.modifierBackground, BackgroundModifierOperation.read)
        registry.register(OpCode.containerEnd) { _ in .containerEnd }
        return registry
    }
}
