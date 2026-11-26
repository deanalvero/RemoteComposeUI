#if canImport(SwiftUI)
import SwiftUI

struct TextNodeView: View {
    let text: TextLayoutOperation
    let context: RenderContext
    
    var body: some View {
        Text(context.string(for: text.textId) ?? "")
            .font(context.font(for: text))
            .foregroundColor(context.color(for: text))
            .multilineTextAlignment(text.swiftUIAlignment)
            .lineLimit(text.swiftUILineLimit)
            .truncationMode(text.swiftUITruncation)
    }
}
#endif
