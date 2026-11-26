import Foundation

public struct RemoteVariables: Equatable {
    public var floats: [Int: Float]
    public var colors: [Int: UInt32]
    public var texts: [Int: String]
    public var idLists: [Int: [Int]]
    
    public init(
        floats: [Int: Float] = [:],
        colors: [Int: UInt32] = [:],
        texts: [Int: String] = [:],
        idLists: [Int: [Int]] = [:]
    ) {
        self.floats = floats
        self.colors = colors
        self.texts = texts
        self.idLists = idLists
    }
}
