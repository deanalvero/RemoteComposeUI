import Foundation

public struct RemoteDocument {
    
    public let operations: [RemoteOperation]
    public let header: HeaderOperation?
    public let texts: [Int: String]
    public let root: RemoteNode?
    public let diagnostics: [RemoteComposeError]

    public var variables: RemoteVariables { RemoteVariables(texts: texts) }

    public init(operations: [RemoteOperation], diagnostics: [RemoteComposeError] = []) {
        self.operations = operations
        self.diagnostics = diagnostics

        var header: HeaderOperation?
        var texts: [Int: String] = [:]
        for op in operations {
            switch op {
            case let .header(h):
                if header == nil { header = h }
            case let .textData(t):
                texts[t.textId] = t.text
            default:
                break
            }
        }
        self.header = header
        self.texts = texts
        self.root = RemoteTreeBuilder.build(from: operations)
    }

    // MARK: Parsing
    
    public static func parse(_ data: Data,
                             registry: OperationRegistry = .standard) throws -> RemoteDocument {
        let result = decode(data, registry: registry)
        if let error = result.error { throw error }
        return RemoteDocument(operations: result.operations)
    }

    public static func parseLenient(_ data: Data,
                                    registry: OperationRegistry = .standard) -> RemoteDocument {
        let result = decode(data, registry: registry)
        return RemoteDocument(
            operations: result.operations,
            diagnostics: result.error.map { [$0] } ?? []
        )
    }

    private static let compressedMarker = 0x78

    private static func decode(_ data: Data, registry: OperationRegistry)
        -> (operations: [RemoteOperation], error: RemoteComposeError?) {
        var reader = WireReader(data)
        var operations: [RemoteOperation] = []
        while !reader.isAtEnd {
            let opOffset = reader.offset
            do {
                let opCode = try reader.readByte()
                guard let read = registry.reader(for: opCode) else {
                    if opCode == compressedMarker {
                        return (operations, .compressedDocumentUnsupported)
                    }
                    return (operations, .unsupportedOperation(opCode: opCode, offset: opOffset))
                }
                operations.append(try read(&reader))
            } catch {
                let wireError = (error as? RemoteComposeError)
                    ?? .truncated(offset: reader.offset, needed: 0)
                return (operations, wireError)
            }
        }
        return (operations, nil)
    }

    // MARK: Debug output

    public func dumpOperations() -> String {
        var lines: [String] = []
        for (index, op) in operations.enumerated() {
            lines.append("[\(index)] \(op.name) (\(op.opCode)): \(op)")
        }
        for problem in diagnostics {
            lines.append("!! \(problem)")
        }
        return lines.joined(separator: "\n")
    }

    public func dumpTree() -> String {
        guard let root = root else { return "(empty)" }
        var lines: [String] = []
        func visit(_ node: RemoteNode, depth: Int) {
            let indent = String(repeating: "  ", count: depth)
            let mods = node.modifiers.isEmpty ? "" : "  modifiers: \(node.modifiers)"
            lines.append("\(indent)\(node.kind)\(mods)")
            for child in node.children { visit(child, depth: depth + 1) }
        }
        visit(root, depth: 0)
        return lines.joined(separator: "\n")
    }
}
