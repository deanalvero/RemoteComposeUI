#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct RemoteComposeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RemoteComposeView(document: SampleDocuments.card())
                .previewDisplayName("Card")
            RemoteComposeView(document: SampleDocuments.rowArrangements())
                .previewDisplayName("Row arrangements")
            RemoteComposeView(document: SampleDocuments.columnAlignment())
                .previewDisplayName("Column alignment")
        }
        .padding()
    }
}
#endif
