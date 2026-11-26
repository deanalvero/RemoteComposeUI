import Foundation

public struct TextLookupOperation: Equatable {
    public var textId: Int
    public var dataSetId: Int
    public var index: RemoteFloat
    
    public init(textId: Int, dataSetId: Int, index: RemoteFloat) {
        self.textId = textId
        self.dataSetId = dataSetId
        self.index = index
    }
    
    public func resolve(using variables: RemoteVariables) -> String? {
        let resolvedIndex = index.resolved(with: variables, default: .nan)
        guard resolvedIndex.isFinite else { return nil }
        let ids = variables.idLists[dataSetId] ?? []
        let index: Int
        if resolvedIndex >= Float(Int32.max) {
            index = Int(Int32.max)
        } else if resolvedIndex <= Float(Int32.min) {
            index = Int(Int32.min)
        } else {
            index = Int(resolvedIndex)
        }
        guard ids.indices.contains(index) else { return nil }
        return variables.texts[ids[index]]
    }
}

extension TextLookupOperation {
    static func read(_ reader: inout WireReader) throws -> RemoteOperation {
        .textLookup(
            TextLookupOperation(
                textId: try reader.readId(),
                dataSetId: try reader.readId(),
                index: try reader.readNanId()
            )
        )
    }
    
    public func write(to writer: inout WireWriter) {
        writer.start(OpCode.textLookup)
        writer.writeInt(textId)
        writer.writeInt(dataSetId)
        writer.writeNanId(index)
    }
}
