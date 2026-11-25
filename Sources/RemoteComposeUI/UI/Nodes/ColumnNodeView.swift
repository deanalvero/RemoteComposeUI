#if canImport(SwiftUI)
import SwiftUI

struct ColumnNodeView: View {
    let column: ColumnLayoutOperation
    let children: [RemoteNode]
    let context: RenderContext

    private var slots: [StackSlot] {
        MainAxisArrangement(columnVertical: column.verticalPositioning).slots(childCount: children.count)
    }

    private var gap: CGFloat { CGFloat(max(column.spacedBy, 0)) }

    var body: some View {
        VStack(alignment: column.swiftUIHorizontalAlignment, spacing: 0) {
            ForEach(Array(slots.enumerated()), id: \.offset) { _, slot in
                switch slot {
                case .spacer:
                    Spacer(minLength: 0)
                case let .child(index):
                    RemoteNodeView(node: children[index], context: context)
                        .padding(.bottom, index < children.count - 1 ? gap : 0)
                }
            }
        }
    }
}
#endif
