import Foundation

public struct CanvasLayoutOperation: Equatable {
  public var componentId: Int
  public var animationId: Int

  public init(componentId: Int, animationId: Int = -1) {
    self.componentId = componentId
    self.animationId = animationId
  }
}

extension CanvasLayoutOperation {
  static func read(_ reader: inout WireReader) throws -> RemoteOperation {
    let componentId = try reader.declareId()
    let animationId = try reader.declareId()
    return .canvasLayout(
      CanvasLayoutOperation(componentId: componentId, animationId: animationId)
    )
  }

  public func write(to writer: inout WireWriter) {
    writer.start(OpCode.layoutCanvas)
    writer.writeInt(componentId)
    writer.writeInt(animationId)
  }
}
