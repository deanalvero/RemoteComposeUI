#if canImport(SwiftUI)
import SwiftUI

extension RowLayoutOperation {
    var swiftUIVerticalAlignment: VerticalAlignment {
        switch verticalPositioning {
        case Positioning.center: return .center
        case Positioning.bottom: return .bottom
        default: return .top
        }
    }
}

extension ColumnLayoutOperation {
    var swiftUIHorizontalAlignment: HorizontalAlignment {
        switch horizontalPositioning {
        case Positioning.center: return .center
        case Positioning.end: return .trailing
        default: return .leading
        }
    }
}
#endif
