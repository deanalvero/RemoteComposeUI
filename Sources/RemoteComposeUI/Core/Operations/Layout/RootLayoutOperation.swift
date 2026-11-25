import Foundation

public struct RootLayoutOperation: Equatable {
    public var componentId: Int
    public init(componentId: Int) { self.componentId = componentId }
}

extension RootLayoutOperation {
    static func read(_ r: inout WireReader) throws -> RemoteOperation {
        .rootLayout(RootLayoutOperation(componentId: try r.declareId()))
    }

    public func write(to w: inout WireWriter) {
        w.start(OpCode.layoutRoot)
        w.writeInt(componentId)
    }
}
