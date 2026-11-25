#if canImport(SwiftUI)
import SwiftUI

public struct RemoteComposeView: View {
    private let document: RemoteDocument
    private let context: RenderContext

    public init(document: RemoteDocument, variables: RemoteVariables? = nil) {
        self.document = document
        self.context = RenderContext(variables: variables ?? document.variables)
    }

    public init(data: Data, variables: RemoteVariables? = nil) {
        self.init(document: RemoteDocument.parseLenient(data), variables: variables)
    }

    public var body: some View {
        if let root = document.root {
            RemoteNodeView(node: root, context: context)
        } else {
            EmptyView()
        }
    }
}
#endif
