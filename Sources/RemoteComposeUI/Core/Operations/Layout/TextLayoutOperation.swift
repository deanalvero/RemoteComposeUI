import Foundation

public enum TextAlign {
    public static let left = 1
    public static let right = 2
    public static let center = 3
    public static let justify = 4
    public static let start = 5
    public static let end = 6
}

public enum TextOverflow {
    public static let clip = 1
    public static let visible = 2
    public static let ellipsis = 3
    public static let startEllipsis = 4
    public static let middleEllipsis = 5
}

public struct TextLayoutOperation: Equatable {
    public static let flagIsDynamicColor = 1
    
    public var componentId: Int
    public var animationId: Int
    public var textId: Int
    public var color: Int
    public var fontSize: RemoteFloat
    public var fontStyle: Int
    public var fontWeight: RemoteFloat
    public var fontFamilyId: Int
    public var textAlign: Int
    public var overflow: Int
    public var maxLines: Int
    
    public init(
        componentId: Int,
        animationId: Int = -1,
        textId: Int,
        color: Int = Int(Int32(bitPattern: 0xFF00_0000)),
        fontSize: RemoteFloat = RemoteFloat(16),
        fontStyle: Int = 0,
        fontWeight: RemoteFloat = RemoteFloat(400),
        fontFamilyId: Int = -1,
        textAlign: Int = TextAlign.start,
        overflow: Int = TextOverflow.clip,
        maxLines: Int = Int(Int32.max)
    ) {
        self.componentId = componentId
        self.animationId = animationId
        self.textId = textId
        self.color = color
        self.fontSize = fontSize
        self.fontStyle = fontStyle
        self.fontWeight = fontWeight
        self.fontFamilyId = fontFamilyId
        self.textAlign = textAlign
        self.overflow = overflow
        self.maxLines = maxLines
    }
    
    public var alignment: Int { textAlign & 0xFFFF }
    public var flags: Int { (textAlign >> 16) & 0xFFFF }
    public var usesDynamicColor: Bool { (flags & TextLayoutOperation.flagIsDynamicColor) != 0 }
}

extension TextLayoutOperation {
    static func read(_ r: inout WireReader) throws -> RemoteOperation {
        let componentId = try r.declareId()
        let animationId = try r.declareId()
        let textId = try r.readId()
        let color = try r.readInt()
        let fontSize = try r.readNanId()
        let fontStyle = try r.readInt()
        let fontWeight = try r.readNanId()
        let fontFamilyId = try r.readId()
        let textAlign = try r.readInt()
        let overflow = try r.readInt()
        let maxLines = try r.readInt()
        return .textLayout(
            TextLayoutOperation(
                componentId: componentId,
                animationId: animationId,
                textId: textId,
                color: color,
                fontSize: fontSize,
                fontStyle: fontStyle,
                fontWeight: fontWeight,
                fontFamilyId: fontFamilyId,
                textAlign: textAlign,
                overflow: overflow,
                maxLines: maxLines
            )
        )
    }
    
    public func write(to w: inout WireWriter) {
        w.start(OpCode.layoutText)
        w.writeInt(componentId)
        w.writeInt(animationId)
        w.writeInt(textId)
        w.writeInt(color)
        w.writeNanId(fontSize)
        w.writeInt(fontStyle)
        w.writeNanId(fontWeight)
        w.writeInt(fontFamilyId)
        w.writeInt(textAlign)
        w.writeInt(overflow)
        w.writeInt(maxLines)
    }
}
