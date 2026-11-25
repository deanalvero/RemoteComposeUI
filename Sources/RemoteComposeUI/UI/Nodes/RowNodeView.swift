#if canImport(SwiftUI)
import SwiftUI

struct RowNodeView: View {
    let row: RowLayoutOperation
    let children: [RemoteNode]
    let context: RenderContext

    private var slots: [StackSlot] {
        MainAxisArrangement(rowHorizontal: row.horizontalPositioning).slots(childCount: children.count)
    }

    private var gap: CGFloat { CGFloat(max(row.spacedBy, 0)) }

    var body: some View {
        HStack(alignment: row.swiftUIVerticalAlignment, spacing: 0) {
            ForEach(Array(slots.enumerated()), id: \.offset) { _, slot in
                switch slot {
                case .spacer:
                    Spacer(minLength: 0)
                case let .child(index):
                    RemoteNodeView(node: children[index], context: context)
                        .padding(.trailing, index < children.count - 1 ? gap : 0)
                }
            }
        }
    }
}
#endif
