import Foundation

public struct FloatExpressionOperation: Equatable {
    public static let maximumExpressionSize = 32
    public static let operatorOffset = 0x310_000
    
    public var id: Int
    public var expression: [RemoteFloat]
    public var animationSpec: [RemoteFloat]?
    
    public init(id: Int, expression: [RemoteFloat], animationSpec: [RemoteFloat]? = nil) {
        self.id = id
        self.expression = expression
        self.animationSpec = animationSpec
    }
    
    public func evaluate(using variables: RemoteVariables) -> Float? {
        var stack: [Float] = []
        stack.reserveCapacity(expression.count)
        var registers: [Float] = [0, 0, 0, 0]
        var randomState: UInt64?
        let randomMultiplier: UInt64 = 0x5DEECE66D
        let randomAddend: UInt64 = 0xB
        let randomMask: UInt64 = (1 << 48) - 1
        
        func nextRandomFloat() -> Float {
            var state = randomState ?? ((UInt64.random(in: 0...randomMask) ^ randomMultiplier) & randomMask)
            state = (state &* randomMultiplier &+ randomAddend) & randomMask
            randomState = state
            return Float(state >> 24) / 16_777_216
        }
        
        func pop(_ count: Int, from values: inout [Float]) -> [Float]? {
            guard count >= 0, values.count >= count else { return nil }
            guard count > 0 else { return [] }
            let start = values.count - count
            let result = Array(values[start...])
            values.removeLast(count)
            return result
        }
        
        for token in expression {
            let tokenID = Int(token.bits & 0x007F_FFFF)
            let operation = tokenID - Self.operatorOffset
            let isExpressionOperator = token.value.isNaN && (1...63).contains(operation)
            if isExpressionOperator {
                switch operation {
                case 1: // ADD
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(v[0] + v[1])
                case 2: // SUB
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(v[0] - v[1])
                case 3: // MUL
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(v[0] * v[1])
                case 4: // DIV
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(v[0] / v[1])
                case 5: // MOD
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(v[0].truncatingRemainder(dividingBy: v[1]))
                case 6: // MIN
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(min(v[0], v[1]))
                case 7: // MAX
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(max(v[0], v[1]))
                case 8: // POW
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(Float(pow(Double(v[0]), Double(v[1]))))
                case 9: // SQRT
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(v[0].squareRoot())
                case 10: // ABS
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(abs(v[0]))
                case 11: // SIGN
                    guard let v = pop(1, from: &stack) else { return nil }
                    stack.append(v[0] == 0 ? v[0] : (v[0] < 0 ? -1 : 1))
                case 12: // COPY_SIGN(a, b)
                    guard let v = pop(2, from: &stack) else { return nil }
                    stack.append(v[1].sign == .minus ? -abs(v[0]) : abs(v[0]))
                case 13: // EXP
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(exp(v[0]))
                case 14: // FLOOR
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(floor(v[0]))
                case 15: // LOG10
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(log10(v[0]))
                case 16: // LN
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(log(v[0]))
                case 17: // ROUND
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(floor(v[0] + 0.5))
                case 18: // SIN
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(sin(v[0]))
                case 19: // COS
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(cos(v[0]))
                case 20: // TAN
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(tan(v[0]))
                case 21: // ASIN
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(asin(v[0]))
                case 22: // ACOS
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(acos(v[0]))
                case 23: // ATAN
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(atan(v[0]))
                case 24: // ATAN2
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(atan2(v[0], v[1]))
                case 25: // MAD: a * b + c
                    guard let v = pop(3, from: &stack) else { return nil }; stack.append(v[0] * v[1] + v[2])
                case 26: // condition ? trueValue : falseValue
                    guard let v = pop(3, from: &stack) else { return nil }; stack.append(v[2] > 0 ? v[1] : v[0])
                case 27: // clamp(value, upper, lower)
                    guard let v = pop(3, from: &stack) else { return nil }; stack.append(min(max(v[0], v[2]), v[1]))
                case 28: // CBRT
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(Float(cbrt(Double(v[0]))))
                case 29: // DEGREES
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(v[0] * 57.29578)
                case 30: // RADIANS
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(v[0] * 0.017453292)
                case 31: // CEIL
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(ceil(v[0]))
                case 32...38:
                    return nil
                case 39: // RAND
                    stack.append(nextRandomFloat())
                case 40: // RAND_SEED
                    guard let v = pop(1, from: &stack) else { return nil }
                    if v[0] == 0 {
                        randomState = nil
                    } else {
                        let signedBits = Int64(Int32(bitPattern: v[0].bitPattern))
                        randomState = (UInt64(bitPattern: signedBits) ^ randomMultiplier) & randomMask
                    }
                case 41:
                    guard let v = pop(1, from: &stack) else { return nil }
                    let input = UInt32(bitPattern: Int32(bitPattern: v[0].bitPattern))
                    let x = Int32(bitPattern: (input << 13) ^ input)
                    let polynomial = x &* ((x &* x) &* 15_731 &+ 789_221) &+ 1_376_312_589
                    let positive = UInt32(bitPattern: polynomial) & 0x7FFF_FFFF
                    stack.append(1 - Float(positive) / 1_073_741_824)
                case 42: // RAND_IN_RANGE(lower, upper)
                    guard let v = pop(2, from: &stack) else { return nil }
                    stack.append(nextRandomFloat() * (v[1] - v[0]) + v[0])
                case 43: // SQUARE_SUM
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(v[0] * v[0] + v[1] * v[1])
                case 44: // STEP
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(v[0] > v[1] ? 1 : 0)
                case 45: // SQUARE
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(v[0] * v[0])
                case 46: // DUP
                    guard let value = stack.last else { return nil }; stack.append(value)
                case 47: // HYPOT
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(hypot(v[0], v[1]))
                case 48: // SWAP
                    guard let v = pop(2, from: &stack) else { return nil }; stack.append(contentsOf: [v[1], v[0]])
                case 49: // LERP
                    guard let v = pop(3, from: &stack) else { return nil }; stack.append(v[0] + (v[1] - v[0]) * v[2])
                case 50: // SMOOTH_STEP(value, max, min)
                    guard let v = pop(3, from: &stack) else { return nil }
                    let value = v[0], maxValue = v[1], minValue = v[2]
                    if value < minValue { stack.append(0) }
                    else if value > maxValue { stack.append(1) }
                    else {
                        let t = (value - minValue) / (maxValue - minValue)
                        stack.append(t * t * (3 - 2 * t))
                    }
                case 51: // LOG2
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(log2(v[0]))
                case 52: // INV
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(1 / v[0])
                case 53: // FRACT
                    guard let v = pop(1, from: &stack) else { return nil }; stack.append(v[0] - v[0].rounded(.towardZero))
                case 54: // PINGPONG
                    guard let v = pop(2, from: &stack) else { return nil }
                    let maximum = v[1] * 2
                    guard maximum != 0 else { return nil }
                    let phase = v[0].truncatingRemainder(dividingBy: maximum)
                    stack.append(phase < v[1] ? phase : maximum - phase)
                case 55: // NOP
                    guard !stack.isEmpty else { return nil }
                case 56...59: // STORE_R0...STORE_R3
                    guard let v = pop(1, from: &stack) else { return nil }
                    registers[operation - 56] = v[0]
                case 60...63: // LOAD_R0...LOAD_R3
                    stack.append(registers[operation - 60])
                default:
                    return nil
                }
                continue
            }
            
            if let variableId = token.variableId {
                guard let value = variables.floats[variableId] else { return nil }
                stack.append(value)
            } else {
                guard !token.value.isNaN else { return nil }
                stack.append(token.value)
            }
        }
        
        return stack.count == 1 ? stack[0] : nil
    }
    
}

extension FloatExpressionOperation {
    static func read(_ reader: inout WireReader) throws -> RemoteOperation {
        let lengthOffset = reader.offset + 4
        let id = try reader.declareId()
        let packedLengths = try reader.readInt()
        let expressionCount = packedLengths & 0xFFFF
        let animationCount = (packedLengths >> 16) & 0xFFFF
        
        guard expressionCount <= maximumExpressionSize else {
            throw RemoteComposeError.invalidLength(offset: lengthOffset, length: expressionCount)
        }
        let totalCount = expressionCount + animationCount
        guard totalCount <= reader.remainingByteCount / 4 else {
            throw RemoteComposeError.truncated(offset: reader.offset, needed: totalCount * 4)
        }
        
        var expression: [RemoteFloat] = []
        expression.reserveCapacity(expressionCount)
        for _ in 0..<expressionCount { expression.append(try reader.readNanId()) }
        
        var animation: [RemoteFloat] = []
        animation.reserveCapacity(animationCount)
        for _ in 0..<animationCount { animation.append(try reader.readNanId()) }
        
        return .floatExpression(
            FloatExpressionOperation(id: id, expression: expression, animationSpec: animationCount == 0 ? nil : animation)
        )
    }
    
    public func write(to writer: inout WireWriter) {
        writer.start(OpCode.floatExpression)
        writer.writeInt(id)
        let animationCount = animationSpec?.count ?? 0
        let packed = (expression.count & 0xFFFF) | ((animationCount & 0xFFFF) << 16)
        writer.writeInt(packed)
        for value in expression { writer.writeNanId(value) }
        for value in animationSpec ?? [] { writer.writeNanId(value) }
    }
}
