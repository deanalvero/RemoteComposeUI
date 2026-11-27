#if canImport(SwiftUI)
import SwiftUI

struct RemoteNodeView: View {
    let node: RemoteNode
    let context: RenderContext
    
    var body: some View {
        decorated(AnyView(content))
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ComponentMetricsPreferenceKey.self,
                        value: [
                            node.componentId: RemoteComponentMetrics(
                                width: Float(geometry.size.width),
                                height: Float(geometry.size.height)
                            )
                        ]
                    )
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch node.kind {
        case .root, .content:
            ZStack(alignment: .topLeading) {
                ChildrenView(children: node.children, context: context)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        case .row(let row):
            RowNodeView(row: row, children: node.children, context: context)
        case .column(let column):
            ColumnNodeView(column: column, children: node.children, context: context)
        case .canvas:
            CanvasLayoutNodeView(
                children: node.children,
                commands: node.canvasCommands,
                context: context
            )
        case .text(let text):
            TextNodeView(text: text, context: context)
        }
    }
    
    private func decorated(_ view: AnyView) -> AnyView {
        var result = view
        for modifier in node.modifiers.reversed() {
            switch modifier {
            case .background(let background):
                result = AnyView(
                    result.background(
                        BackgroundShapeView(
                            background: background,
                            context: context
                        )
                    )
                )
            case .width(let width):
                result = result.applying(width: width, context: context)
            case .height(let height):
                result = result.applying(height: height, context: context)
            }
        }
        return result
    }
}

struct ChildrenView: View {
    let children: [RemoteNode]
    let context: RenderContext
    
    var body: some View {
        ForEach(children) { child in
            RemoteNodeView(node: child, context: context)
        }
    }
}
#endif
