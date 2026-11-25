import Foundation

public enum RemoteComposeError: Error, Equatable, CustomStringConvertible {
    
    case truncated(offset: Int, needed: Int)
    case unsupportedOperation(opCode: Int, offset: Int)
    case invalidLength(offset: Int, length: Int)
    case compressedDocumentUnsupported

    public var description: String {
        switch self {
        case let .truncated(offset, needed):
            return "Truncated document: needed \(needed) more byte(s) at offset \(offset)"
        case let .unsupportedOperation(opCode, offset):
            if let name = OpCode.name(of: opCode) {
                return "Unsupported operation \(name) (\(opCode)) at byte offset \(offset)"
            }
            return "Unknown operation \(opCode) at byte offset \(offset)"
        case let .invalidLength(offset, length):
            return "Invalid length \(length) at byte offset \(offset)"
        case .compressedDocumentUnsupported:
            return "Compressed documents (opcode 0x78) are not supported yet"
        }
    }
}
