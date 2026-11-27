import Foundation

enum RemoteTreeBuilder {
    static func build(from operations: [RemoteOperation]) -> RemoteNode? {
        var stack: [RemoteNode] = []
        var topLevel: [RemoteNode] = []
        
        func close(_ node: RemoteNode) {
            if stack.isEmpty {
                topLevel.append(node)
            } else {
                stack[stack.count - 1].children.append(node)
            }
        }
        
        for (index, op) in operations.enumerated() {
            switch op {
            case .rootLayout(let o): stack.append(RemoteNode(id: index, kind: .root(o)))
            case .layoutContent(let o): stack.append(RemoteNode(id: index, kind: .content(o)))
            case .rowLayout(let o): stack.append(RemoteNode(id: index, kind: .row(o)))
            case .columnLayout(let o): stack.append(RemoteNode(id: index, kind: .column(o)))
            case .canvasLayout(let o): stack.append(RemoteNode(id: index, kind: .canvas(o)))
            case .textLayout(let o): stack.append(RemoteNode(id: index, kind: .text(o)))
            case .containerEnd:
                if let finished = stack.popLast() { close(finished) }
            case .backgroundModifier(let m):
                if !stack.isEmpty { stack[stack.count - 1].modifiers.append(.background(m)) }
            case .widthModifier(let m):
                if !stack.isEmpty { stack[stack.count - 1].modifiers.append(.width(m)) }
            case .heightModifier(let m):
                if !stack.isEmpty { stack[stack.count - 1].modifiers.append(.height(m)) }
            case .paintData(let paint):
                if let canvasIndex = stack.lastIndex(where: { if case .canvas = $0.kind { return true }; return false }) {
                    stack[canvasIndex].canvasCommands.append(.paint(paint))
                }
            case .drawTextAnchored(let draw):
                if let canvasIndex = stack.lastIndex(where: { if case .canvas = $0.kind { return true }; return false }) {
                    stack[canvasIndex].canvasCommands.append(.drawTextAnchored(draw))
                }
            case .header, .textData, .dataListIds, .floatExpression, .componentValue,
                    .textFromFloat, .textMerge, .textLookup:
                break
            }
        }
        
        while let unfinished = stack.popLast() { close(unfinished) }
        
        guard !topLevel.isEmpty else { return nil }
        
        let root: RemoteNode
        if topLevel.count == 1, case .root = topLevel[0].kind {
            root = topLevel[0]
        } else {
            root = RemoteNode(
                id: -1, kind: .root(RootLayoutOperation(componentId: -1)),
                children: topLevel)
        }
        let componentIDs = Set(operations.compactMap { operation -> Int? in
            guard case .componentValue(let value) = operation else { return nil }
            return value.componentId
        })
        return flattenContent(root, preserving: componentIDs)
    }
    
    private static func flattenContent(
        _ node: RemoteNode,
        preserving componentIDs: Set<Int>
    ) -> RemoteNode {
        var result = node
        result.children = []
        for child in node.children {
            let flattened = flattenContent(child, preserving: componentIDs)
            if case .content(let operation) = flattened.kind,
               !componentIDs.contains(operation.componentId) {
                result.children.append(contentsOf: flattened.children)
            } else {
                result.children.append(flattened)
            }
        }
        return result
    }
}
