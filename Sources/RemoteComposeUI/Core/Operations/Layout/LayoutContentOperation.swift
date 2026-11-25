import Foundation

public struct LayoutContentOperation: Equatable {
    public var componentId: Int
    public init(componentId: Int) { self.componentId = componentId }
}

extension LayoutContentOperation {
    static func read(_ r: inout WireReader) throws -> RemoteOperation {
        .layoutContent(LayoutContentOperation(componentId: try r.declareId()))
    }

    public func write(to w: inout WireWriter) {
        w.start(OpCode.layoutContent)
        w.writeInt(componentId)
    }
}
