import Foundation

public enum ShapeType {
    public static let rectangle = 0
    public static let circle = 1
}

public struct BackgroundModifierOperation: Equatable {
    public static let colorRef = 2

    public var flags: Int
    public var colorId: Int
    public var reserve1: Int
    public var reserve2: Int
    public var r: RemoteFloat
    public var g: RemoteFloat
    public var b: RemoteFloat
    public var a: RemoteFloat
    public var shapeType: Int

    public init(
        flags: Int = 0,
        colorId: Int = 0,
        reserve1: Int = 0,
        reserve2: Int = 0,
        r: RemoteFloat,
        g: RemoteFloat,
        b: RemoteFloat,
        a: RemoteFloat,
        shapeType: Int = ShapeType.rectangle
    ) {
        self.flags = flags
        self.colorId = colorId
        self.reserve1 = reserve1
        self.reserve2 = reserve2
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        self.shapeType = shapeType
    }

    public init(red: Float, green: Float, blue: Float, alpha: Float = 1, shapeType: Int = ShapeType.rectangle) {
        self.init(
            r: RemoteFloat(red),
            g: RemoteFloat(green),
            b: RemoteFloat(blue),
            a: RemoteFloat(alpha),
            shapeType: shapeType
        )
    }

    public init(colorId: Int, shapeType: Int = ShapeType.rectangle) {
        let zero = RemoteFloat(0)
        self.init(
            flags: BackgroundModifierOperation.colorRef,
            colorId: colorId,
            r: zero,
            g: zero,
            b: zero,
            a: zero,
            shapeType: shapeType
        )
    }

    public var usesColorId: Bool { flags == BackgroundModifierOperation.colorRef }
}

extension BackgroundModifierOperation {
    static func read(_ r: inout WireReader) throws -> RemoteOperation {
        let flags = try r.readInt()
        let colorId = try r.readInt()
        let reserve1 = try r.readInt()
        let reserve2 = try r.readInt()
        let red = try r.readNanId()
        let green = try r.readNanId()
        let blue = try r.readNanId()
        let alpha = try r.readNanId()
        let shapeType = try r.readInt()
        return .backgroundModifier(
            BackgroundModifierOperation(
                flags: flags,
                colorId: colorId,
                reserve1: reserve1,
                reserve2: reserve2,
                r: red,
                g: green,
                b: blue,
                a: alpha,
                shapeType: shapeType
            )
        )
    }

    public func write(to w: inout WireWriter) {
        w.start(OpCode.modifierBackground)
        w.writeInt(flags)
        w.writeInt(colorId)
        w.writeInt(reserve1)
        w.writeInt(reserve2)
        w.writeNanId(r)
        w.writeNanId(g)
        w.writeNanId(b)
        w.writeNanId(a)
        w.writeInt(shapeType)
    }
}
