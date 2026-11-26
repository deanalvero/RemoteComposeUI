import Foundation

public struct PaintDataOperation: Equatable {
    public static let maximumWordCount = 65_536
    public var paintBundle: [Int]
    
    public init(paintBundle: [Int]) {
        self.paintBundle = paintBundle
    }
    
    public var textAttributes: PaintTextAttributes {
        var result = PaintTextAttributes()
        var index = 0
        while index < paintBundle.count {
            let command = paintBundle[index]
            index += 1
            let type = command & 0xFFFF
            let argument = command >> 16
            
            switch type {
            case 1: // TEXT_SIZE
                guard index < paintBundle.count else { return result }
                result.textSize = RemoteFloat(bits: UInt32(bitPattern: Int32(truncatingIfNeeded: paintBundle[index])))
                index += 1
            case 4: // COLOR
                guard index < paintBundle.count else { return result }
                result.colorARGB = UInt32(bitPattern: Int32(truncatingIfNeeded: paintBundle[index]))
                index += 1
            case 5, 6, 9, 12, 13, 19, 20, 22, 26:
                guard index < paintBundle.count else { return result }
                if type == 12 {
                    result.alpha = RemoteFloat(bits: UInt32(bitPattern: Int32(truncatingIfNeeded: paintBundle[index])))
                } else if type == 19 {
                    result.colorId = paintBundle[index]
                } else if type == 26 {
                    result.fontFamily = paintBundle[index]
                }
                index += 1
            case 7, 8, 10, 14, 15, 17, 18, 21:
                break
            case 16: // TYPEFACE
                guard index < paintBundle.count else { return result }
                result.fontStyle = argument
                result.fontFamily = paintBundle[index]
                index += 1
            case 23: // FONT_AXIS
                let count = max(argument, 0)
                guard count <= (paintBundle.count - index) / 2 else { return result }
                index += count * 2
            case 24: // TEXTURE
                guard paintBundle.count - index >= 3 else { return result }
                index += 3
            case 25: // PATH_EFFECT
                let count = max(argument, 0)
                guard count <= paintBundle.count - index else { return result }
                index += count
            case 11:
                return result
            default:
                return result
            }
        }
        return result
    }
}

public struct PaintTextAttributes: Equatable {
    public var textSize: RemoteFloat?
    public var colorARGB: UInt32?
    public var colorId: Int?
    public var alpha: RemoteFloat?
    public var fontFamily: Int?
    public var fontStyle: Int?
    
    public init() {}
    
    public mutating func merge(_ update: PaintTextAttributes) {
        if let value = update.textSize { textSize = value }
        if let value = update.colorARGB { colorARGB = value; colorId = nil }
        if let value = update.colorId { colorId = value; colorARGB = nil }
        if let value = update.alpha { alpha = value }
        if let value = update.fontFamily { fontFamily = value }
        if let value = update.fontStyle { fontStyle = value }
    }
}

extension PaintDataOperation {
    static func read(_ reader: inout WireReader) throws -> RemoteOperation {
        let lengthOffset = reader.offset
        let count = try reader.readInt()
        guard count >= 0, count <= maximumWordCount else {
            throw RemoteComposeError.invalidLength(offset: lengthOffset, length: count)
        }
        guard count <= reader.remainingByteCount / 4 else {
            throw RemoteComposeError.truncated(offset: reader.offset, needed: count * 4)
        }
        var words: [Int] = []
        words.reserveCapacity(count)
        for _ in 0..<count { words.append(try reader.readInt()) }
        return .paintData(PaintDataOperation(paintBundle: words))
    }
    
    public func write(to writer: inout WireWriter) {
        writer.start(OpCode.paintData)
        writer.writeInt(paintBundle.count)
        for word in paintBundle { writer.writeInt(word) }
    }
}
