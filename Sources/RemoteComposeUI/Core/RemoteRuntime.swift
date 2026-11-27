import Foundation

public struct RemoteRuntimeFrame: Equatable, Sendable {
    public let timeSnapshot: RemoteTimeSnapshot
    public let animationTime: Float
    public let animationDeltaTime: Float
    public let variables: RemoteVariables
    
    public init(
        timeSnapshot: RemoteTimeSnapshot,
        animationTime: Float,
        animationDeltaTime: Float,
        variables: RemoteVariables
    ) {
        self.timeSnapshot = timeSnapshot
        self.animationTime = animationTime
        self.animationDeltaTime = animationDeltaTime
        self.variables = variables
    }
}

public final class RemoteRuntime {
    private let defaultDocument: RemoteDocument?
    public let clock: any RemoteClock
    public let apiLevel: Float?
    public let documentLoadTimeMillis: Int64
    
    private let startNanoseconds: UInt64
    private let frameLock = NSLock()
    private var previousFrameNanoseconds: UInt64
    
    public convenience init(
        clock: any RemoteClock = SystemRemoteClock(),
        apiLevel: Float? = nil
    ) {
        self.init(defaultDocument: nil, clock: clock, apiLevel: apiLevel)
    }
    
    public convenience init(
        document: RemoteDocument,
        clock: any RemoteClock = SystemRemoteClock(),
        apiLevel: Float? = nil
    ) {
        self.init(defaultDocument: document, clock: clock, apiLevel: apiLevel)
    }
    
    private init(
        defaultDocument: RemoteDocument?,
        clock: any RemoteClock,
        apiLevel: Float?
    ) {
        self.defaultDocument = defaultDocument
        self.clock = clock
        self.apiLevel = apiLevel
        self.documentLoadTimeMillis = clock.millis()
        let start = clock.nanoTime()
        self.startNanoseconds = start
        self.previousFrameNanoseconds = start
    }
    
    public func makeFrame(
        for document: RemoteDocument,
        overriding overrides: RemoteVariables? = nil,
        componentMetrics: [Int: RemoteComponentMetrics] = [:]
    ) -> RemoteRuntimeFrame {
        let wallClockMillis = clock.millis()
        
        frameLock.lock()
        let nowNanoseconds = clock.nanoTime()
        let elapsedNanoseconds = nowNanoseconds >= startNanoseconds
        ? nowNanoseconds - startNanoseconds : 0
        let deltaNanoseconds = nowNanoseconds >= previousFrameNanoseconds
        ? nowNanoseconds - previousFrameNanoseconds : 0
        previousFrameNanoseconds = nowNanoseconds
        frameLock.unlock()
        
        let snapshot = clock.snapshot(at: wallClockMillis)
        let animationTime = Float(Double(elapsedNanoseconds) / 1_000_000_000)
        let animationDeltaTime = Float(Double(deltaNanoseconds) / 1_000_000_000)
        let resolved = document.resolvedVariables(
            overriding: overrides,
            timeSnapshot: snapshot,
            animationTime: animationTime,
            animationDeltaTime: animationDeltaTime,
            apiLevel: apiLevel,
            componentMetrics: componentMetrics
        )
        
        return RemoteRuntimeFrame(
            timeSnapshot: snapshot,
            animationTime: animationTime,
            animationDeltaTime: animationDeltaTime,
            variables: resolved
        )
    }
    
    public func makeFrame(overriding overrides: RemoteVariables? = nil) -> RemoteRuntimeFrame {
        guard let defaultDocument else {
            preconditionFailure("Use makeFrame(for:overriding:) when no default document was supplied")
        }
        return makeFrame(for: defaultDocument, overriding: overrides)
    }
}
