import Foundation

public struct RemoteDocument {
    
    public let operations: [RemoteOperation]
    public let header: HeaderOperation?
    public let texts: [Int: String]
    public let idLists: [Int: [Int]]
    public let componentValues: [ComponentValueOperation]
    public let root: RemoteNode?
    public let diagnostics: [RemoteComposeError]
    
    public var variables: RemoteVariables { resolvedVariables() }
    
    public var timeRefreshInterval: TimeInterval? {
        let references = referencedClockVariableIDs
        guard !references.isEmpty else { return nil }
        if references.contains(RemoteContextVariableID.continuousSeconds)
            || references.contains(RemoteContextVariableID.animationTime)
            || references.contains(RemoteContextVariableID.animationDeltaTime) {
            return 1.0 / 30.0
        }
        return 1.0
    }
    
    public var hasContinuousTimeDependencies: Bool {
        let references = referencedClockVariableIDs
        return references.contains(RemoteContextVariableID.continuousSeconds)
        || references.contains(RemoteContextVariableID.animationTime)
        || references.contains(RemoteContextVariableID.animationDeltaTime)
    }
    
    public func resolvedVariables(
        overriding overrides: RemoteVariables? = nil,
        timeSnapshot: RemoteTimeSnapshot? = nil,
        animationTime: Float? = nil,
        animationDeltaTime: Float? = nil,
        apiLevel: Float? = nil,
        componentMetrics: [Int: RemoteComponentMetrics] = [:]
    ) -> RemoteVariables {
        var result = RemoteVariables(
            floats: overrides?.floats ?? [:],
            integers: overrides?.integers ?? [:],
            colors: overrides?.colors ?? [:],
            texts: texts,
            idLists: idLists
        )
        if let overrides {
            result.integers.merge(overrides.integers) { _, supplied in supplied }
            result.colors.merge(overrides.colors) { _, supplied in supplied }
            result.texts.merge(overrides.texts) { _, supplied in supplied }
            result.idLists.merge(overrides.idLists) { _, supplied in supplied }
        }
        
        if let timeSnapshot {
            TimeVariables(apiLevel: apiLevel).updateTime(into: &result, snapshot: timeSnapshot)
        } else if let apiLevel {
            result.floats[RemoteContextVariableID.apiLevel] = apiLevel
        }
        if let animationTime {
            result.floats[RemoteContextVariableID.animationTime] = animationTime
        }
        if let animationDeltaTime {
            result.floats[RemoteContextVariableID.animationDeltaTime] = animationDeltaTime
        }
        
        for componentValue in componentValues {
            guard let metrics = componentMetrics[componentValue.componentId] else {
                continue
            }

            let value: Float
            switch componentValue.type {
            case ComponentValueOperation.width:
                value = metrics.width
            case ComponentValueOperation.height:
                value = metrics.height
            default:
                continue
            }

            guard value.isFinite else {
                continue
            }
            result.floats[componentValue.valueId] = value
        }

        for operation in operations {
            switch operation {
            case .floatExpression(let expression):
                if let value = expression.evaluate(using: result) {
                    result.floats[expression.id] = value
                }
            case .textFromFloat(let text):
                if let value = text.formattedText(using: result) {
                    result.texts[text.textId] = value
                }
            case .textMerge(let text):
                if let value = text.resolve(using: result) {
                    result.texts[text.textId] = value
                }
            case .textLookup(let text):
                if let value = text.resolve(using: result) {
                    result.texts[text.textId] = value
                }
            default:
                break
            }
        }
        return result
    }
    
    private var referencedClockVariableIDs: Set<Int> {
        var result = Set<Int>()
        
        func collect(_ value: RemoteFloat) {
            guard let id = value.variableId,
                  RemoteContextVariableID.clockDrivenFloatIDs.contains(id)
                    else { return }
            result.insert(id)
        }
        
        for operation in operations {
            switch operation {
            case .floatExpression(let expression):
                expression.expression.forEach(collect)
            case .textFromFloat(let text):
                collect(text.value)
            case .textLookup(let text):
                collect(text.index)
            case .paintData(let paint):
                let attributes = paint.textAttributes
                if let value = attributes.textSize { collect(value) }
                if let value = attributes.alpha { collect(value) }
            case .drawTextAnchored(let draw):
                collect(draw.x)
                collect(draw.y)
                collect(draw.panX)
                collect(draw.panY)
            case .textLayout(let text):
                collect(text.fontSize)
                collect(text.fontWeight)
            case .backgroundModifier(let background):
                collect(background.r)
                collect(background.g)
                collect(background.b)
                collect(background.a)
            case .widthModifier(let width):
                collect(width.value)
            case .heightModifier(let height):
                collect(height.value)
            default:
                break
            }
        }
        return result
    }
    
    public init(operations: [RemoteOperation], diagnostics: [RemoteComposeError] = []) {
        self.operations = operations
        self.diagnostics = diagnostics
        
        var header: HeaderOperation?
        var texts: [Int: String] = [:]
        var idLists: [Int: [Int]] = [:]
        var componentValues: [ComponentValueOperation] = []
        for op in operations {
            switch op {
            case .header(let h):
                if header == nil { header = h }
            case .textData(let t):
                texts[t.textId] = t.text
            case .dataListIds(let list):
                idLists[list.id] = list.ids
            case .componentValue(let value):
                componentValues.append(value)
            default:
                break
            }
        }
        self.header = header
        self.texts = texts
        self.idLists = idLists
        self.componentValues = componentValues
        self.root = RemoteTreeBuilder.build(from: operations)
    }
    
    // MARK: Parsing
    
    public static func parse(
        _ data: Data,
        registry: OperationRegistry = .standard
    ) throws -> RemoteDocument {
        let result = decode(data, registry: registry)
        if let error = result.error { throw error }
        return RemoteDocument(operations: result.operations)
    }
    
    public static func parseLenient(
        _ data: Data,
        registry: OperationRegistry = .standard
    ) -> RemoteDocument {
        let result = decode(data, registry: registry)
        return RemoteDocument(
            operations: result.operations,
            diagnostics: result.error.map { [$0] } ?? []
        )
    }
    
    private static let compressedMarker = 0x78
    
    private static func decode(_ data: Data, registry: OperationRegistry)
    -> (operations: [RemoteOperation], error: RemoteComposeError?)
    {
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
                let wireError =
                (error as? RemoteComposeError)
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
            let canvas = node.canvasCommands.isEmpty ? "" : "  canvasCommands: \(node.canvasCommands)"
            lines.append("\(indent)\(node.kind)\(mods)\(canvas)")
            for child in node.children { visit(child, depth: depth + 1) }
        }
        visit(root, depth: 0)
        return lines.joined(separator: "\n")
    }
}
