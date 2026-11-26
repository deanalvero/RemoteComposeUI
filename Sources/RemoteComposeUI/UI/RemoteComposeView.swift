#if canImport(SwiftUI)
import SwiftUI

public struct RemoteComposeView: View {
    private let document: RemoteDocument
    private let variables: RemoteVariables?
    private let refreshInterval: TimeInterval?
    private let usesContinuousSchedule: Bool
    @State private var runtime: RemoteRuntime
    
    public init(
        document: RemoteDocument,
        variables: RemoteVariables? = nil,
        clock: any RemoteClock = SystemRemoteClock(),
        apiLevel: Float? = nil,
        continuousUpdatesPerSecond: Double = 30
    ) {
        self.document = document
        self.variables = variables
        let rate = continuousUpdatesPerSecond.isFinite
        ? min(max(continuousUpdatesPerSecond, 1), 60) : 30
        let computedInterval = document.timeRefreshInterval
        self.refreshInterval = document.hasContinuousTimeDependencies
        ? 1.0 / rate : computedInterval
        self.usesContinuousSchedule = document.hasContinuousTimeDependencies
        _runtime = State(
            initialValue: RemoteRuntime(clock: clock, apiLevel: apiLevel)
        )
    }
    
    public init(
        data: Data,
        variables: RemoteVariables? = nil,
        clock: any RemoteClock = SystemRemoteClock(),
        apiLevel: Float? = nil,
        continuousUpdatesPerSecond: Double = 30
    ) {
        self.init(
            document: RemoteDocument.parseLenient(data),
            variables: variables,
            clock: clock,
            apiLevel: apiLevel,
            continuousUpdatesPerSecond: continuousUpdatesPerSecond
        )
    }
    
    @ViewBuilder
    public var body: some View {
        if let refreshInterval {
            if usesContinuousSchedule {
                TimelineView(.animation(minimumInterval: refreshInterval, paused: false)) { _ in
                    renderedContent
                }
            } else {
                TimelineView(.periodic(from: .now, by: refreshInterval)) { _ in
                    renderedContent
                }
            }
        } else {
            renderedContent
        }
    }
    
    @ViewBuilder
    private var renderedContent: some View {
        let frame = runtime.makeFrame(for: document, overriding: variables)
        if let root = document.root {
            RemoteNodeView(node: root, context: RenderContext(variables: frame.variables))
        } else {
            EmptyView()
        }
    }
}
#endif
