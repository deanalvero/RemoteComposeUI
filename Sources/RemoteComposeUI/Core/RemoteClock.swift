import Dispatch
import Foundation

public protocol RemoteClock: Sendable {
    func millis() -> Int64
    func nanoTime() -> UInt64
    var zoneIdentifier: String { get }
    func snapshot(at milliseconds: Int64?) -> RemoteTimeSnapshot
}

public extension RemoteClock {
    func snapshot(at milliseconds: Int64? = nil) -> RemoteTimeSnapshot {
        let timestamp = milliseconds ?? millis()
        let date = Date(timeIntervalSince1970: Double(timestamp) / 1_000)
        let zone = TimeZone(identifier: zoneIdentifier) ?? .current
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = zone
        
        let components = calendar.dateComponents(
            [.year, .month, .day, .weekday, .hour, .minute, .second, .nanosecond],
            from: date
        )
        let foundationWeekday = components.weekday ?? 1
        let mondayFirstWeekday = ((foundationWeekday + 5) % 7) + 1
        let millisecond = (components.nanosecond ?? 0) / 1_000_000
        
        let dayOfYear = calendar.ordinality(
            of: .day,
            in: .year,
            for: date
        ) ?? 1
        
        return RemoteTimeSnapshot(
            millisecondsSinceEpoch: timestamp,
            timeZoneIdentifier: zone.identifier,
            utcOffsetSeconds: zone.secondsFromGMT(for: date),
            year: components.year ?? 1970,
            month: components.month ?? 1,
            dayOfMonth: components.day ?? 1,
            dayOfYear: dayOfYear,
            hour: components.hour ?? 0,
            minute: components.minute ?? 0,
            second: components.second ?? 0,
            millisecond: millisecond,
            dayOfWeek: mondayFirstWeekday
        )
    }
}

public struct SystemRemoteClock: RemoteClock {
    public init() {}
    
    public func millis() -> Int64 {
        Int64((Date().timeIntervalSince1970 * 1_000).rounded(.down))
    }
    
    public func nanoTime() -> UInt64 {
        DispatchTime.now().uptimeNanoseconds
    }
    
    public var zoneIdentifier: String { TimeZone.current.identifier }
}

public struct RemoteTimeSnapshot: Equatable, Sendable {
    public let millisecondsSinceEpoch: Int64
    public let timeZoneIdentifier: String
    public let utcOffsetSeconds: Int
    public let year: Int
    public let month: Int
    public let dayOfMonth: Int
    public let dayOfYear: Int
    public let hour: Int
    public let minute: Int
    public let second: Int
    public let millisecond: Int
    
    public let dayOfWeek: Int
    
    public init(
        millisecondsSinceEpoch: Int64,
        timeZoneIdentifier: String,
        utcOffsetSeconds: Int,
        year: Int,
        month: Int,
        dayOfMonth: Int,
        dayOfYear: Int,
        hour: Int,
        minute: Int,
        second: Int,
        millisecond: Int,
        dayOfWeek: Int
    ) {
        self.millisecondsSinceEpoch = millisecondsSinceEpoch
        self.timeZoneIdentifier = timeZoneIdentifier
        self.utcOffsetSeconds = utcOffsetSeconds
        self.year = year
        self.month = month
        self.dayOfMonth = dayOfMonth
        self.dayOfYear = dayOfYear
        self.hour = hour
        self.minute = minute
        self.second = second
        self.millisecond = millisecond
        self.dayOfWeek = dayOfWeek
    }
    
    public var continuousSeconds: Float {
        Float(minute * 60 + second) + Float(millisecond) / 1_000
    }
    
    public var timeInSeconds: Float { Float(minute * 60 + second) }
    
    public var timeInMinutes: Float { Float(hour * 60 + minute) }
    
    public var epochSeconds: Int32 {
        Int32(truncatingIfNeeded: millisecondsSinceEpoch / 1_000)
    }
    
    public func value(forVariableID id: Int) -> Float? {
        switch id {
        case RemoteContextVariableID.continuousSeconds: return continuousSeconds
        case RemoteContextVariableID.timeInSeconds: return timeInSeconds
        case RemoteContextVariableID.timeInMinutes: return timeInMinutes
        case RemoteContextVariableID.timeInHours: return Float(hour)
        case RemoteContextVariableID.calendarMonth: return Float(month)
        case RemoteContextVariableID.offsetToUTC: return Float(utcOffsetSeconds)
        case RemoteContextVariableID.weekDay: return Float(dayOfWeek)
        case RemoteContextVariableID.dayOfMonth: return Float(dayOfMonth)
        case RemoteContextVariableID.dayOfYear: return Float(dayOfYear)
        case RemoteContextVariableID.year: return Float(year)
        default: return nil
        }
    }
}
