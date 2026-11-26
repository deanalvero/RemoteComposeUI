import Foundation

public struct HeaderOperation: Equatable {
    public enum PropertyKey {
        public static let docWidth: Int = 5
        public static let docHeight: Int = 6
        public static let docDensityAtGeneration: Int = 7
        public static let docDesiredFps: Int = 8
        public static let docContentDescription: Int = 9
        public static let docSource: Int = 11
        public static let docDataUpdate: Int = 12
        public static let hostExceptionHandler: Int = 13
        public static let docProfiles: Int = 14
        public static let compress: Int = 31
        public static let docScroll: Int = 32
    }
    
    public enum PropertyValue: Equatable {
        case int(Int)
        case float(Float)
        case long(Int64)
        case string(String)
    }
    
    public static let magicNumber: UInt32 = 0x048C_0000
    public static let maxTableSize: Int = 10_000
    public static let maxStringSize: Int = 1_000_000
    
    private static let dataTypeInt: Int = 0
    private static let dataTypeFloat: Int = 1
    private static let dataTypeLong: Int = 2
    private static let dataTypeString: Int = 3
    
    public var majorVersion: Int
    public var minorVersion: Int
    public var patchVersion: Int
    public var width: Int
    public var height: Int
    public var capabilities: Int64
    public var properties: [Int: PropertyValue]
    
    public init(
        majorVersion: Int = 1,
        minorVersion: Int = 1,
        patchVersion: Int = 0,
        width: Int = 0,
        height: Int = 0,
        capabilities: Int64 = 0,
        properties: [Int: PropertyValue] = [:]
    ) {
        self.majorVersion = majorVersion
        self.minorVersion = minorVersion
        self.patchVersion = patchVersion
        self.capabilities = capabilities
        self.properties = properties
        
        if case .int(let w) = properties[PropertyKey.docWidth], width == 0 {
            self.width = w
        } else {
            self.width = width
        }
        
        if case .int(let h) = properties[PropertyKey.docHeight], height == 0 {
            self.height = h
        } else {
            self.height = height
        }
    }
}

extension HeaderOperation {
    static func read(_ r: inout WireReader) throws -> RemoteOperation {
        let rawMajorUInt = try r.readUInt32()
        let minor = try r.readInt()
        let patch = try r.readInt()
        
        if rawMajorUInt < 0x0001_0000 {
            let major = Int(Int32(bitPattern: rawMajorUInt))
            let width = try r.readInt()
            let height = try r.readInt()
            let capabilities = try r.readLong()
            return .header(
                HeaderOperation(
                    majorVersion: major,
                    minorVersion: minor,
                    patchVersion: patch,
                    width: width,
                    height: height,
                    capabilities: capabilities
                )
            )
        }
        
        let major = Int(rawMajorUInt & 0x0000_FFFF)
        let countOffset = r.offset
        let count = try r.readInt()
        guard (0...Self.maxTableSize).contains(count) else {
            throw RemoteComposeError.invalidLength(offset: countOffset, length: count)
        }
        
        var props: [Int: PropertyValue] = [:]
        props.reserveCapacity(count)
        
        for _ in 0..<count {
            let tag = try r.readShort()
            _ = try r.readShort()
            let dataType = (tag >> 10) & 0x3F
            let key = tag & 0x3F
            
            switch dataType {
            case Self.dataTypeInt:
                props[key] = .int(try r.readInt())
            case Self.dataTypeFloat:
                props[key] = .float(try r.readFloat())
            case Self.dataTypeLong:
                props[key] = .long(try r.readLong())
            case Self.dataTypeString:
                let lenOffset = r.offset
                let strLen = try r.readInt()
                guard (0...Self.maxStringSize).contains(strLen) else {
                    throw RemoteComposeError.invalidLength(offset: lenOffset, length: strLen)
                }
                let rawBytes = try r.readBytes(strLen)
                props[key] = .string(String(decoding: rawBytes, as: UTF8.self))
            default:
                break
            }
        }
        
        let width: Int = {
            if case .int(let v) = props[PropertyKey.docWidth] { return v }
            return 0
        }()
        let height: Int = {
            if case .int(let v) = props[PropertyKey.docHeight] { return v }
            return 0
        }()
        
        return .header(
            HeaderOperation(
                majorVersion: major,
                minorVersion: minor,
                patchVersion: patch,
                width: width,
                height: height,
                capabilities: 0,
                properties: props
            )
        )
    }
    
    public func write(to w: inout WireWriter) {
        w.start(OpCode.header)
        if properties.isEmpty {
            w.writeInt(majorVersion)
            w.writeInt(minorVersion)
            w.writeInt(patchVersion)
            w.writeInt(width)
            w.writeInt(height)
            w.writeLong(capabilities)
        } else {
            let encodedMajor = UInt32(truncatingIfNeeded: majorVersion & 0xFFFF) | Self.magicNumber
            w.writeUInt32(encodedMajor)
            w.writeInt(minorVersion)
            w.writeInt(patchVersion)
            
            let sortedKeys = properties.keys.sorted()
            w.writeInt(sortedKeys.count)
            
            for key in sortedKeys {
                guard let value = properties[key] else { continue }
                let maskedKey = key & 0x3F
                switch value {
                case .int(let v):
                    w.writeShort((Self.dataTypeInt << 10) | maskedKey)
                    w.writeShort(4)
                    w.writeInt(v)
                case .float(let v):
                    w.writeShort((Self.dataTypeFloat << 10) | maskedKey)
                    w.writeShort(4)
                    w.writeFloat(v)
                case .long(let v):
                    w.writeShort((Self.dataTypeLong << 10) | maskedKey)
                    w.writeShort(8)
                    w.writeLong(v)
                case .string(let s):
                    let utf8 = Array(s.utf8)
                    w.writeShort((Self.dataTypeString << 10) | maskedKey)
                    w.writeShort(utf8.count + 4)
                    w.writeUTF8(s)
                }
            }
        }
    }
}
