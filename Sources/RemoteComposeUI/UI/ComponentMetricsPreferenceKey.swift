#if canImport(SwiftUI)
import SwiftUI

struct ComponentMetricsPreferenceKey: PreferenceKey {
    static let defaultValue: [Int: RemoteComponentMetrics] = [:]

    static func reduce(
        value: inout [Int: RemoteComponentMetrics],
        nextValue: () -> [Int: RemoteComponentMetrics]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { _, next in next })
    }
}
#endif
