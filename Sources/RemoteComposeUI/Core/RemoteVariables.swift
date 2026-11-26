import Foundation

public struct RemoteVariables: Equatable, Sendable {
    public var floats: [Int: Float]
    public var integers: [Int: Int]
    public var colors: [Int: UInt32]
    public var texts: [Int: String]
    public var idLists: [Int: [Int]]
    
    public init(
        floats: [Int: Float] = [:],
        integers: [Int: Int] = [:],
        colors: [Int: UInt32] = [:],
        texts: [Int: String] = [:],
        idLists: [Int: [Int]] = [:]
    ) {
        self.floats = floats
        self.integers = integers
        self.colors = colors
        self.texts = texts
        self.idLists = idLists
    }
}
