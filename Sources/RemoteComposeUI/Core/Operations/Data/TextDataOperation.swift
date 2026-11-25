import Foundation

public struct TextDataOperation: Equatable {
    public var textId: Int
    public var text: String
    public init(textId: Int, text: String) {
        self.textId = textId
        self.text = text
    }
}

extension TextDataOperation {
    static func read(_ r: inout WireReader) throws -> RemoteOperation {
        let id = try r.declareId()
        let text = try r.readUTF8()
        return .textData(TextDataOperation(textId: id, text: text))
    }

    public func write(to w: inout WireWriter) {
        w.start(OpCode.dataText)
        w.writeInt(textId)
        w.writeUTF8(text)
    }
}
