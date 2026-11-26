import Foundation

public enum DimensionModifierType: Int, Equatable, CaseIterable {
    case exact = 0
    case fill = 1
    case wrap = 2
    case weight = 3
    case intrinsicMin = 4
    case intrinsicMax = 5
    case exactDP = 6
    case fillParentMaxWidth = 7
    case fillParentMaxHeight = 8
    
    
    public init(wireValue: Int) {
        self = DimensionModifierType(rawValue: wireValue) ?? .exact
    }
}

public struct WidthModifierOperation: Equatable {
    public var type: DimensionModifierType
    public var value: RemoteFloat
    
    public init(type: DimensionModifierType = .exact, value: RemoteFloat) {
        self.type = type
        self.value = value
    }
    
    public init(_ value: Float, type: DimensionModifierType = .exact) {
        self.init(type: type, value: RemoteFloat(value))
    }
}

public struct HeightModifierOperation: Equatable {
    public var type: DimensionModifierType
    public var value: RemoteFloat
    
    public init(type: DimensionModifierType = .exact, value: RemoteFloat) {
        self.type = type
        self.value = value
    }
    
    public init(_ value: Float, type: DimensionModifierType = .exact) {
        self.init(type: type, value: RemoteFloat(value))
    }
}

extension WidthModifierOperation {
    static func read(_ reader: inout WireReader) throws -> RemoteOperation {
        let type = DimensionModifierType(wireValue: try reader.readInt())
        let value = try reader.readNanId()
        return .widthModifier(WidthModifierOperation(type: type, value: value))
    }
    
    public func write(to writer: inout WireWriter) {
        writer.start(OpCode.modifierWidth)
        writer.writeInt(type.rawValue)
        writer.writeNanId(value)
    }
}

extension HeightModifierOperation {
    static func read(_ reader: inout WireReader) throws -> RemoteOperation {
        let type = DimensionModifierType(wireValue: try reader.readInt())
        let value = try reader.readNanId()
        return .heightModifier(HeightModifierOperation(type: type, value: value))
    }
    
    public func write(to writer: inout WireWriter) {
        writer.start(OpCode.modifierHeight)
        writer.writeInt(type.rawValue)
        writer.writeNanId(value)
    }
}
