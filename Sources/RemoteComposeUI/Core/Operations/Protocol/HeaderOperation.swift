import Foundation

public struct HeaderOperation: Equatable {
    public var majorVersion: Int
    public var minorVersion: Int
    public var patchVersion: Int
    public var width: Int
    public var height: Int
    public var capabilities: Int64
    
    public init(
        majorVersion: Int = 1,
        minorVersion: Int = 1,
        patchVersion: Int = 0,
        width: Int = 0,
        height: Int = 0,
        capabilities: Int64 = 0
    ) {
        self.majorVersion = majorVersion
        self.minorVersion = minorVersion
        self.patchVersion = patchVersion
        self.width = width
        self.height = height
        self.capabilities = capabilities
    }
}

extension HeaderOperation {
    static func read(_ r: inout WireReader) throws -> RemoteOperation {
        let major = try r.readInt()
        let minor = try r.readInt()
        let patch = try r.readInt()
        let width = try r.readInt()
        let height = try r.readInt()
        let capabilities = try r.readLong()
        return .header(
            HeaderOperation(
                majorVersion: major,
                minorVersion: minor,
                patchVersion: patch,
                width: width,
                height: height,
                capabilities: capabilities
            )
        )
    }
    
    public func write(to w: inout WireWriter) {
        w.start(OpCode.header)
        w.writeInt(majorVersion)
        w.writeInt(minorVersion)
        w.writeInt(patchVersion)
        w.writeInt(width)
        w.writeInt(height)
        w.writeLong(capabilities)
    }
}
