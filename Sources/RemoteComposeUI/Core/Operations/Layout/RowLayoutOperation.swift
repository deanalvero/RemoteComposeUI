import Foundation

public struct RowLayoutOperation: Equatable {
    public var componentId: Int
    public var animationId: Int
    public var horizontalPositioning: Int
    public var verticalPositioning: Int
    public var spacedBy: Float

    public init(
        componentId: Int,
        animationId: Int = -1,
        horizontalPositioning: Int = Positioning.start,
        verticalPositioning: Int = Positioning.top,
        spacedBy: Float = 0
    ) {
        self.componentId = componentId
        self.animationId = animationId
        self.horizontalPositioning = horizontalPositioning
        self.verticalPositioning = verticalPositioning
        self.spacedBy = spacedBy
    }
}

extension RowLayoutOperation {
    static func read(_ r: inout WireReader) throws -> RemoteOperation {
        let componentId = try r.declareId()
        let animationId = try r.declareId()
        let horizontal = try r.readInt()
        let vertical = try r.readInt()
        let spacedBy = try r.readFloat()
        return .rowLayout(
            RowLayoutOperation(
                componentId: componentId,
                animationId: animationId,
                horizontalPositioning: horizontal,
                verticalPositioning: vertical,
                spacedBy: spacedBy
            )
        )
    }

    public func write(to w: inout WireWriter) {
        w.start(OpCode.layoutRow)
        w.writeInt(componentId)
        w.writeInt(animationId)
        w.writeInt(horizontalPositioning)
        w.writeInt(verticalPositioning)
        w.writeFloat(spacedBy)
    }
}