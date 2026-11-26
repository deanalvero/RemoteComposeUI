import Foundation

public struct DataListIdsOperation: Equatable {
  public static let maximumCount = 2_000

  public var id: Int
  public var ids: [Int]

  public init(id: Int, ids: [Int]) {
    self.id = id
    self.ids = ids
  }
}

extension DataListIdsOperation {
  static func read(_ reader: inout WireReader) throws -> RemoteOperation {
    let id = try reader.declareId()
    let lengthOffset = reader.offset
    let count = try reader.readInt()
    guard (0...Self.maximumCount).contains(count) else {
      throw RemoteComposeError.invalidLength(offset: lengthOffset, length: count)
    }

    var ids: [Int] = []
    ids.reserveCapacity(count)
    for _ in 0..<count {
      ids.append(try reader.readId())
    }
    return .dataListIds(DataListIdsOperation(id: id, ids: ids))
  }

  public func write(to writer: inout WireWriter) {
    writer.start(OpCode.dataListIds)
    writer.writeInt(id)
    writer.writeInt(ids.count)
    for id in ids {
      writer.writeInt(id)
    }
  }
}
