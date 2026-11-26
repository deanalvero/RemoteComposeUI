import Foundation

public struct ComponentValueOperation: Equatable {
    public static let width = 0
    public static let height = 1
    public static let positionX = 2
    public static let positionY = 3
    public static let rootPositionX = 4
    public static let rootPositionY = 5
    public static let contentWidth = 6
    public static let contentHeight = 7
    
    public var type: Int
    public var componentId: Int
    public var valueId: Int
    
    public init(type: Int = ComponentValueOperation.width, componentId: Int, valueId: Int) {
        self.type = type
        self.componentId = componentId
        self.valueId = valueId
    }
}

extension ComponentValueOperation {
    static func read(_ reader: inout WireReader) throws -> RemoteOperation {
        ComponentValueOperation(
            type: try reader.readInt(),
            componentId: try reader.readId(),
            valueId: try reader.readId()
        ).asOperation
    }
    
    public func write(to writer: inout WireWriter) {
        writer.start(OpCode.componentValue)
        writer.writeInt(type)
        writer.writeInt(componentId)
        writer.writeInt(valueId)
    }
    
    private var asOperation: RemoteOperation { .componentValue(self) }
}
