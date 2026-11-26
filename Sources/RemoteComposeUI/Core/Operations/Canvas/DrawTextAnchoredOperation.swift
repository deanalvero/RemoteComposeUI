import Foundation

public struct DrawTextAnchoredOperation: Equatable {
    public static let anchorTextRTL = 1
    public static let anchorMonospaceMeasure = 2
    public static let measureEveryTime = 4
    public static let baselineRelative = 8
    
    public var textId: Int
    public var x: RemoteFloat
    public var y: RemoteFloat
    public var panX: RemoteFloat
    public var panY: RemoteFloat
    public var flags: Int
    
    public init(
        textId: Int,
        x: RemoteFloat,
        y: RemoteFloat,
        panX: RemoteFloat = RemoteFloat(0),
        panY: RemoteFloat = RemoteFloat(0),
        flags: Int = 0
    ) {
        self.textId = textId
        self.x = x
        self.y = y
        self.panX = panX
        self.panY = panY
        self.flags = flags
    }
}

extension DrawTextAnchoredOperation {
    static func read(_ reader: inout WireReader) throws -> RemoteOperation {
        .drawTextAnchored(
            DrawTextAnchoredOperation(
                textId: try reader.readId(),
                x: try reader.readNanId(),
                y: try reader.readNanId(),
                panX: try reader.readNanId(),
                panY: try reader.readNanId(),
                flags: try reader.readInt()
            )
        )
    }
    
    public func write(to writer: inout WireWriter) {
        writer.start(OpCode.drawTextAnchored)
        writer.writeInt(textId)
        writer.writeNanId(x)
        writer.writeNanId(y)
        writer.writeNanId(panX)
        writer.writeNanId(panY)
        writer.writeInt(flags)
    }
}
