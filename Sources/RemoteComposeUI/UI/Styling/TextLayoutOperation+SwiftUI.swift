#if canImport(SwiftUI)
import SwiftUI

extension TextLayoutOperation {
    var swiftUIAlignment: TextAlignment {
        switch alignment {
        case TextAlign.right, TextAlign.end: return .trailing
        case TextAlign.center: return .center
        default: return .leading
        }
    }
    
    var swiftUILineLimit: Int? {
        (maxLines > 0 && maxLines < Int(Int32.max)) ? maxLines : nil
    }
    
    var swiftUITruncation: Text.TruncationMode {
        switch overflow {
        case TextOverflow.startEllipsis: return .head
        case TextOverflow.middleEllipsis: return .middle
        default: return .tail
        }
    }
}
#endif
