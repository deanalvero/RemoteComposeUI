import Foundation

public struct TextFromFloatOperation: Equatable {
    public static let padAfterMask = 0x3
    public static let padAfterSpace = 0
    public static let padAfterNone = 0x1
    public static let padAfterZero = 0x3
    public static let padPreMask = 0x3 << 2
    public static let padPreSpace = 0
    public static let padPreNone = 0x1 << 2
    public static let padPreZero = 0x3 << 2
    public static let groupingBy3 = 1 << 4
    public static let groupingBy4 = 2 << 4
    public static let groupingBy32 = 3 << 4
    public static let separatorCommaPeriod = 0
    public static let separatorPeriodComma = 1 << 6
    public static let separatorSpaceComma = 2 << 6
    public static let separatorUnderPeriod = 3 << 6
    public static let negativeParentheses = 1 << 8
    public static let rounding = 2 << 8
    public static let legacyMode = 1 << 10
    public static let fullFormat = 1 << 12
    
    public var textId: Int
    public var value: RemoteFloat
    public var digitsBefore: Int
    public var digitsAfter: Int
    public var flags: Int
    
    public init(
        textId: Int,
        value: RemoteFloat,
        digitsBefore: Int = 0,
        digitsAfter: Int = 2,
        flags: Int = 0
    ) {
        self.textId = textId
        self.value = value
        self.digitsBefore = digitsBefore
        self.digitsAfter = digitsAfter
        self.flags = flags
    }
    
    public func formattedText(using variables: RemoteVariables) -> String? {
        let resolved: Float
        if let variableId = value.variableId {
            guard let variable = variables.floats[variableId] else { return nil }
            resolved = variable
        } else {
            resolved = value.value
        }
        guard resolved.isFinite else { return String(resolved) }
        if flags & Self.fullFormat != 0 { return String(resolved) }
        
        let negative = resolved < 0
        let magnitude = abs(resolved)
        let before = min(max(digitsBefore, 0), 32)
        let after = min(max(digitsAfter, 0), 18)
        guard magnitude < Float(Int64.max) else { return String(resolved) }
        
        if flags & Self.legacyMode != 0 {
            return legacyFormatted(magnitude, negative: negative, before: before, after: after)
        }
        
        let roundingEnabled = flags & Self.rounding != 0
        var adjusted = magnitude
        if roundingEnabled {
            var roundingFactor: Float = 0.5
            for _ in 0..<after { roundingFactor /= 10 }
            adjusted += roundingFactor
        }
        guard adjusted < Float(Int64.max) else { return String(resolved) }
        
        let integerPart = Int64(adjusted)
        var integerString = String(integerPart)
        
        let grouping = (flags >> 4) & 0x3
        let separatorMode = (flags >> 6) & 0x3
        let groupSeparator: Character
        let decimalSeparator: Character
        switch separatorMode {
        case 1: groupSeparator = "."; decimalSeparator = ","
        case 2: groupSeparator = " "; decimalSeparator = ","
        case 3: groupSeparator = "_"; decimalSeparator = "."
        default: groupSeparator = ","; decimalSeparator = "."
        }
        
        switch grouping {
        case 1:
            integerString = insertingSeparator(in: integerString, firstGroup: 3, repeatGroup: 3, separator: groupSeparator)
        case 2:
            integerString = insertingSeparator(in: integerString, firstGroup: 4, repeatGroup: 4, separator: groupSeparator)
        case 3:
            integerString = insertingSeparator(in: integerString, firstGroup: 3, repeatGroup: 2, separator: groupSeparator)
        default:
            break
        }
        
        if integerString.count < before {
            let pad: Character? = {
                switch flags & Self.padPreMask {
                case Self.padPreNone: return nil
                case Self.padPreZero: return "0"
                default: return " "
                }
            }()
            if let pad { integerString = String(repeating: String(pad), count: before - integerString.count) + integerString }
        } else if integerString.count > before {
            integerString = String(integerString.suffix(before))
        }
        
        let integerWidthBeforePadding = max(integerString.count, 0)
        let trimAfter = integerWidthBeforePadding + after > 9
        ? max(1, 9 - integerWidthBeforePadding)
        : after
        let padAfter = flags & Self.padAfterMask
        let outputAfter = padAfter == Self.padAfterNone ? trimAfter : after
        
        var fractionalPart = magnitude.truncatingRemainder(dividingBy: 1)
        for _ in 0..<trimAfter { fractionalPart *= 10 }
        fractionalPart = floor(fractionalPart + 0.5)
        for _ in 0..<trimAfter { fractionalPart *= 0.1 }
        
        let fractionalString = String(fractionalPart)
        var fractionalDigits = String(fractionalString.split(separator: ".", omittingEmptySubsequences: false).dropFirst().first ?? "")
        fractionalDigits = String(fractionalDigits.prefix(outputAfter))
        while fractionalDigits.count > 1 && fractionalDigits.last == "0" {
            fractionalDigits.removeLast()
        }
        
        let post: Character? = {
            switch padAfter {
            case Self.padAfterNone: return nil
            case Self.padAfterZero: return "0"
            default: return " "
            }
        }()
        if let post, fractionalDigits.count < outputAfter {
            fractionalDigits += String(repeating: String(post), count: outputAfter - fractionalDigits.count)
        }
        
        var result = integerString
        if outputAfter > 0 {
            result.append(decimalSeparator)
            result += fractionalDigits
        }
        if negative {
            result = flags & Self.negativeParentheses != 0 ? "(\(result))" : "-\(result)"
        }
        return result
    }
    
    private func insertingSeparator(
        in value: String,
        firstGroup: Int,
        repeatGroup: Int,
        separator: Character
    ) -> String {
        let characters = Array(value)
        guard characters.count > firstGroup else { return value }
        var result = ""
        for (index, character) in characters.enumerated() {
            let remaining = characters.count - index
            if index > 0 && remaining >= firstGroup && (remaining - firstGroup) % repeatGroup == 0 {
                result.append(separator)
            }
            result.append(character)
        }
        return result
    }
    
    private func legacyFormatted(_ magnitude: Float, negative: Bool, before: Int, after: Int) -> String {
        let integer = Int64(magnitude)
        var integerString = String(integer)
        if integerString.count < before {
            let pad: Character = (flags & Self.padPreMask) == Self.padPreZero ? "0" : " "
            if flags & Self.padPreMask != Self.padPreNone {
                integerString = String(repeating: String(pad), count: before - integerString.count) + integerString
            }
        } else if integerString.count > before {
            integerString = String(integerString.suffix(before))
        }
        guard after > 0 else { return negative ? "-\(integerString)" : integerString }
        let scale = powf(10, Float(after))
        let fraction = Int64((magnitude - Float(integer)) * scale + 0.5)
        var digits = String(fraction)
        if digits.count < after { digits = String(repeating: "0", count: after - digits.count) + digits }
        while digits.last == "0" { digits.removeLast() }
        let post: Character? = (flags & Self.padAfterMask) == Self.padAfterNone ? nil : ((flags & Self.padAfterMask) == Self.padAfterZero ? "0" : " ")
        if let post, digits.count < after { digits += String(repeating: String(post), count: after - digits.count) }
        let result = integerString + "." + digits
        return negative ? (flags & Self.negativeParentheses != 0 ? "(\(result))" : "-\(result)") : result
    }
}

extension TextFromFloatOperation {
    static func read(_ reader: inout WireReader) throws -> RemoteOperation {
        let textId = try reader.readId()
        let value = try reader.readNanId()
        let packedDigits = try reader.readInt()
        let digitsBefore = Int(Int16(bitPattern: UInt16(truncatingIfNeeded: packedDigits >> 16)))
        let digitsAfter = Int(Int16(bitPattern: UInt16(truncatingIfNeeded: packedDigits)))
        let flags = try reader.readInt()
        return .textFromFloat(
            TextFromFloatOperation(
                textId: textId, value: value, digitsBefore: digitsBefore, digitsAfter: digitsAfter, flags: flags
            )
        )
    }
    
    public func write(to writer: inout WireWriter) {
        writer.start(OpCode.textFromFloat)
        writer.writeInt(textId)
        writer.writeNanId(value)
        let before = UInt32(UInt16(bitPattern: Int16(clamping: digitsBefore)))
        let after = UInt32(UInt16(bitPattern: Int16(clamping: digitsAfter)))
        writer.writeUInt32((before << 16) | after)
        writer.writeInt(flags)
    }
}
