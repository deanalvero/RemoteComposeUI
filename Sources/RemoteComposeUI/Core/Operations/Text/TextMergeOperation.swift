import Foundation

public struct TextMergeOperation: Equatable {
    public var textId: Int
    public var sourceId1: Int
    public var sourceId2: Int
    
    public init(textId: Int, sourceId1: Int, sourceId2: Int) {
        self.textId = textId
        self.sourceId1 = sourceId1
        self.sourceId2 = sourceId2
    }
    
    public func resolve(using variables: RemoteVariables) -> String? {
        guard let lhs = variables.texts[sourceId1], let rhs = variables.texts[sourceId2] else { return nil }
        return lhs + rhs
    }
}

extension TextMergeOperation {
    static func read(_ reader: inout WireReader) throws -> RemoteOperation {
        .textMerge(
            TextMergeOperation(
                textId: try reader.readId(),
                sourceId1: try reader.readId(),
                sourceId2: try reader.readId()
            )
        )
    }
    
    public func write(to writer: inout WireWriter) {
        writer.start(OpCode.textMerge)
        writer.writeInt(textId)
        writer.writeInt(sourceId1)
        writer.writeInt(sourceId2)
    }
}
