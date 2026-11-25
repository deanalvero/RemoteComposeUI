import Foundation

public struct RemoteFloat: Equatable, Hashable {
    public let bits: UInt32

    public init(bits: UInt32) { self.bits = bits }
    public init(_ value: Float) { self.bits = value.bitPattern }
    public init(variableId: Int) {
        self.bits = 0xFF80_0000 | (UInt32(truncatingIfNeeded: variableId) & 0x3F_FFFF)
    }

    public var value: Float { Float(bitPattern: bits) }
    
    public var isVariable: Bool {
        (bits & 0x7F80_0000) == 0x7F80_0000 && (bits & 0x007F_FFFF) != 0
    }

    public var variableId: Int? { isVariable ? Int(bits & 0x3F_FFFF) : nil }

    public func resolved(with variables: RemoteVariables, default fallback: Float = 0) -> Float {
        if let id = variableId {
            return variables.floats[id] ?? fallback
        }
        return value
    }
}
