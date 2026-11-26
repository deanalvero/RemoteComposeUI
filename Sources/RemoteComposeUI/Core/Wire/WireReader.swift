import Foundation

public struct WireReader {
    private let bytes: [UInt8]
    public private(set) var offset: Int
    
    public init(_ data: Data, offset: Int = 0) {
        self.bytes = [UInt8](data)
        self.offset = offset
    }
    
    public init(bytes: [UInt8], offset: Int = 0) {
        self.bytes = bytes
        self.offset = offset
    }
    
    public var isAtEnd: Bool { offset >= bytes.count }
    public var count: Int { bytes.count }
    public var remainingByteCount: Int { max(0, bytes.count - offset) }
    
    private mutating func take(_ n: Int) throws -> Int {
        guard n >= 0, offset <= bytes.count, bytes.count - offset >= n else {
            throw RemoteComposeError.truncated(offset: offset, needed: n)
        }
        let start = offset
        offset += n
        return start
    }
    
    public mutating func readByte() throws -> Int {
        let i = try take(1)
        return Int(bytes[i])
    }
    
    public mutating func readShort() throws -> Int {
        let i = try take(2)
        let hi = Int(bytes[i])
        let lo = Int(bytes[i + 1])
        return (hi << 8) | lo
    }
    
    public mutating func readUInt32() throws -> UInt32 {
        let i = try take(4)
        let b0 = UInt32(bytes[i])
        let b1 = UInt32(bytes[i + 1])
        let b2 = UInt32(bytes[i + 2])
        let b3 = UInt32(bytes[i + 3])
        return (b0 << 24) | (b1 << 16) | (b2 << 8) | b3
    }
    
    public mutating func readInt() throws -> Int {
        let u = try readUInt32()
        return Int(Int32(bitPattern: u))
    }
    
    public mutating func readLong() throws -> Int64 {
        let hi = try readUInt32()
        let lo = try readUInt32()
        return Int64(bitPattern: (UInt64(hi) << 32) | UInt64(lo))
    }
    
    public mutating func readFloat() throws -> Float {
        let bits = try readUInt32()
        return Float(bitPattern: bits)
    }
    
    public mutating func readId() throws -> Int { try readInt() }
    
    public mutating func declareId() throws -> Int { try readInt() }
    
    public mutating func readNanId() throws -> RemoteFloat {
        RemoteFloat(bits: try readUInt32())
    }
    
    public mutating func readUTF8() throws -> String {
        let length = try readInt()
        guard length >= 0 else {
            throw RemoteComposeError.invalidLength(offset: offset - 4, length: length)
        }
        let start = try take(length)
        return String(decoding: bytes[start..<(start + length)], as: UTF8.self)
    }
    
    public mutating func readBytes(_ count: Int) throws -> [UInt8] {
        guard count >= 0 else {
            throw RemoteComposeError.invalidLength(offset: offset, length: count)
        }
        let start = try take(count)
        return Array(bytes[start..<(start + count)])
    }
}
