import Foundation

public enum StackSlot: Equatable {
    case spacer
    case child(Int)
}

public enum MainAxisArrangement {
    case start, center, end, spaceBetween, spaceEvenly, spaceAround

    public init(rowHorizontal positioning: Int) {
        switch positioning {
        case Positioning.center: self = .center
        case Positioning.end: self = .end
        case Positioning.spaceBetween: self = .spaceBetween
        case Positioning.spaceEvenly: self = .spaceEvenly
        case Positioning.spaceAround: self = .spaceAround
        default: self = .start
        }
    }

    public init(columnVertical positioning: Int) {
        switch positioning {
        case Positioning.center: self = .center
        case Positioning.bottom: self = .end
        case Positioning.spaceBetween: self = .spaceBetween
        case Positioning.spaceEvenly: self = .spaceEvenly
        case Positioning.spaceAround: self = .spaceAround
        default: self = .start
        }
    }

    public func slots(childCount n: Int) -> [StackSlot] {
        guard n > 0 else { return [] }
        let children = (0..<n).map { StackSlot.child($0) }
        switch self {
        case .start:
            return children
        case .center:
            return [.spacer] + children + [.spacer]
        case .end:
            return [.spacer] + children
        case .spaceBetween:
            if n == 1 { return [.spacer, .child(0), .spacer] }
            var slots: [StackSlot] = []
            for i in 0..<n {
                if i > 0 { slots.append(.spacer) }
                slots.append(.child(i))
            }
            return slots
        case .spaceEvenly:
            var slots: [StackSlot] = [.spacer]
            for i in 0..<n {
                slots.append(.child(i))
                slots.append(.spacer)
            }
            return slots
        case .spaceAround:
            var slots: [StackSlot] = [.spacer]
            for i in 0..<n {
                if i > 0 {
                    slots.append(.spacer)
                    slots.append(.spacer)
                }
                slots.append(.child(i))
            }
            slots.append(.spacer)
            return slots
        }
    }
}
