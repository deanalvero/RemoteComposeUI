import Foundation

public struct RemoteComponentMetrics: Equatable, Sendable {
    public let width: Float
    public let height: Float

    public init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }
}
