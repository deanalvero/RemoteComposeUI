#if canImport(SwiftUI)
import SwiftUI

struct BackgroundShapeView: View {
    let background: BackgroundModifierOperation
    let context: RenderContext

    var body: some View {
        if let color = context.color(for: background) {
            switch background.shapeType {
            case ShapeType.rectangle:
                Rectangle().fill(color)
            case ShapeType.circle:
                Circle().fill(color)
            default:
                EmptyView()
            }
        }
    }
}
#endif
