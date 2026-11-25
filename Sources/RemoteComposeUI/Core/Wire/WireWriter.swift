import Foundation

public struct WireWriter {
    public private(set) var bytes: [UInt8] = []

    public init() {}

    public var data: Data { Data(bytes) }

    public mutating func start(_ opCode: Int) {
        writeByte(opCode)
    }

    public mutating func writeByte(_ value: Int) {
        bytes.append(UInt8(truncatingIfNeeded: value))
    }

    public mutating func writeShort(_ value: Int) {
        bytes.append(UInt8(truncatingIfNeeded: value >> 8))
        bytes.append(UInt8(truncatingIfNeeded: value))
    }

    public mutating func writeInt(_ value: Int) {
        writeUInt32(UInt32(truncatingIfNeeded: value))
    }

    public mutating func writeUInt32(_ value: UInt32) {
        bytes.append(UInt8(truncatingIfNeeded: value >> 24))
        bytes.append(UInt8(truncatingIfNeeded: value >> 16))
        bytes.append(UInt8(truncatingIfNeeded: value >> 8))
        bytes.append(UInt8(truncatingIfNeeded: value))
    }

    public mutating func writeLong(_ value: Int64) {
        let u = UInt64(bitPattern: value)
        writeUInt32(UInt32(truncatingIfNeeded: u >> 32))
        writeUInt32(UInt32(truncatingIfNeeded: u))
    }

    public mutating func writeFloat(_ value: Float) {
        writeUInt32(value.bitPattern)
    }

    public mutating func writeNanId(_ value: RemoteFloat) {
        writeUInt32(value.bits)
    }

    public mutating func writeUTF8(_ string: String) {
        let utf8 = Array(string.utf8)
        writeInt(utf8.count)
        bytes.append(contentsOf: utf8)
    }
}
