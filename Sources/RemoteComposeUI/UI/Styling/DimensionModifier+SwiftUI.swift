#if canImport(SwiftUI)
  import SwiftUI

  extension AnyView {
    func applying(width operation: WidthModifierOperation, context: RenderContext) -> AnyView {
      applyingDimension(
        type: operation.type, value: operation.value, horizontal: true, context: context)
    }

    func applying(height operation: HeightModifierOperation, context: RenderContext) -> AnyView {
      applyingDimension(
        type: operation.type, value: operation.value, horizontal: false, context: context)
    }

    private func applyingDimension(
      type: DimensionModifierType,
      value: RemoteFloat,
      horizontal: Bool,
      context: RenderContext
    ) -> AnyView {
      let resolved = context.float(value, default: 0)
      let dimension = CGFloat(resolved.isFinite ? max(resolved, 0) : 0)

      switch type {
      case .exact, .exactDP:
        return horizontal
          ? AnyView(frame(width: dimension))
          : AnyView(frame(height: dimension))

      case .fill, .fillParentMaxWidth, .fillParentMaxHeight:
        return horizontal
          ? AnyView(frame(maxWidth: .infinity))
          : AnyView(frame(maxHeight: .infinity))

      case .weight:
        // SwiftUI does not expose weighted dimensions directly. Expansion plus
        // layoutPriority provides the closest stack-layout equivalent.
        let priority = Double(resolved.isFinite ? max(resolved, 1) : 1)
        return horizontal
          ? AnyView(frame(maxWidth: .infinity).layoutPriority(priority))
          : AnyView(frame(maxHeight: .infinity).layoutPriority(priority))

      case .wrap, .intrinsicMin, .intrinsicMax:
        return horizontal
          ? AnyView(fixedSize(horizontal: true, vertical: false))
          : AnyView(fixedSize(horizontal: false, vertical: true))
      }
    }
  }
#endif
