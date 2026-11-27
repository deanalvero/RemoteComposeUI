import Testing
@testable import RemoteComposeUI

@Test func componentGeometryValuesResolveBeforeExpressions() {
    let document = RemoteDocument(operations: [
        .componentValue(ComponentValueOperation(
            type: ComponentValueOperation.width,
            componentId: -6,
            valueId: 42
        )),
        .componentValue(ComponentValueOperation(
            type: ComponentValueOperation.height,
            componentId: -6,
            valueId: 43
        )),
        .floatExpression(FloatExpressionOperation(
            id: 86,
            expression: [RemoteFloat(variableId: 43)]
        )),
        .floatExpression(FloatExpressionOperation(
            id: 88,
            expression: [RemoteFloat(variableId: 42)]
        ))
    ])

    let variables = document.resolvedVariables(
        componentMetrics: [
            -6: RemoteComponentMetrics(width: 320, height: 180)
        ]
    )

    #expect(variables.floats[42] == 320)
    #expect(variables.floats[43] == 180)
    #expect(variables.floats[86] == 180)
    #expect(variables.floats[88] == 320)
}

@Test func layoutContentNodesArePreservedForMeasurement() {
    let root = RemoteTreeBuilder.build(from: [
        .componentValue(ComponentValueOperation(
            type: ComponentValueOperation.width,
            componentId: -6,
            valueId: 42
        )),
        .rootLayout(RootLayoutOperation(componentId: 1)),
        .layoutContent(LayoutContentOperation(componentId: -6)),
        .canvasLayout(CanvasLayoutOperation(componentId: 2)),
        .containerEnd,
        .containerEnd,
        .containerEnd
    ])

    #expect(root != nil)
    guard let root else { return }
    #expect(root.children.count == 1)
    guard case .content(let content) = root.children[0].kind else {
        #expect(Bool(false))
        return
    }
    #expect(content.componentId == -6)
}
