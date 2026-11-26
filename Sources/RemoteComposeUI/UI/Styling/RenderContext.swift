#if canImport(SwiftUI)
import SwiftUI

struct RenderContext {
    var variables: RemoteVariables
    
    func string(for id: Int) -> String? {
        variables.texts[id]
    }
    
    func float(_ value: RemoteFloat, default fallback: Float) -> Float {
        value.resolved(with: variables, default: fallback)
    }
}
#endif
