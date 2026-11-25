#if canImport(SwiftUI)
import SwiftUI

struct RemoteNodeView: View {
    let node: RemoteNode
    let context: RenderContext

    var body: some View {
        decorated(AnyView(content))
    }

    @ViewBuilder
    private var content: some View {
        switch node.kind {
        case .root, .content:
            ZStack(alignment: .topLeading) {
                ChildrenView(children: node.children, context: context)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        case let .row(row):
            RowNodeView(row: row, children: node.children, context: context)
        case let .column(column):
            ColumnNodeView(column: column, children: node.children, context: context)
        case let .text(text):
            TextNodeView(text: text, context: context)
        }
    }

    private func decorated(_ view: AnyView) -> AnyView {
        var result = view
        for modifier in node.modifiers.reversed() {
            switch modifier {
            case let .background(background):
                result = AnyView(
                    result.background(
                        BackgroundShapeView(
                            background: background,
                            context: context
                        )
                    )
                )
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
