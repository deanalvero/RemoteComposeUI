import Foundation

public enum RemoteContextVariableID {
    public static let continuousSeconds = 1
    public static let timeInSeconds = 2
    public static let timeInMinutes = 3
    public static let timeInHours = 4
    public static let windowWidth = 5
    public static let windowHeight = 6
    public static let componentWidth = 7
    public static let componentHeight = 8
    public static let calendarMonth = 9
    public static let offsetToUTC = 10
    public static let weekDay = 11
    public static let dayOfMonth = 12
    public static let touchPositionX = 13
    public static let touchPositionY = 14
    public static let touchVelocityX = 15
    public static let touchVelocityY = 16
    public static let accelerationX = 17
    public static let accelerationY = 18
    public static let accelerationZ = 19
    public static let gyroRotationX = 20
    public static let gyroRotationY = 21
    public static let gyroRotationZ = 22
    public static let magneticX = 23
    public static let magneticY = 24
    public static let magneticZ = 25
    public static let light = 26
    public static let density = 27
    public static let apiLevel = 28
    public static let touchEventTime = 29
    public static let animationTime = 30
    public static let animationDeltaTime = 31
    public static let epochSecond = 32
    public static let fontSize = 33
    public static let dayOfYear = 34
    public static let year = 35
    public static let firstBaseline = 36
    public static let lastBaseline = 37
    
    public static let timeFloatIDs: Set<Int> = [
        continuousSeconds, timeInSeconds, timeInMinutes, timeInHours,
        calendarMonth, offsetToUTC, weekDay, dayOfMonth, dayOfYear, year,
    ]
    
    public static let clockDrivenFloatIDs: Set<Int> = timeFloatIDs.union([animationTime, animationDeltaTime])
    
    public static func isTimeFloatID(_ id: Int) -> Bool {
        timeFloatIDs.contains(id)
    }
}

public struct TimeVariables {
    public let apiLevel: Float?
    
    public init(apiLevel: Float? = nil) {
        self.apiLevel = apiLevel
    }
    
    @discardableResult
    public func updateTime(
        into variables: inout RemoteVariables,
        clock: any RemoteClock = SystemRemoteClock()
    ) -> RemoteTimeSnapshot {
        let snapshot = clock.snapshot(at: clock.millis())
        updateTime(into: &variables, snapshot: snapshot)
        return snapshot
    }
    
    public func updateTime(
        into variables: inout RemoteVariables,
        snapshot: RemoteTimeSnapshot
    ) {
        let id = RemoteContextVariableID.self
        variables.floats[id.continuousSeconds] = snapshot.continuousSeconds
        variables.floats[id.timeInSeconds] = snapshot.timeInSeconds
        variables.floats[id.timeInMinutes] = snapshot.timeInMinutes
        variables.floats[id.timeInHours] = Float(snapshot.hour)
        variables.floats[id.calendarMonth] = Float(snapshot.month)
        variables.floats[id.offsetToUTC] = Float(snapshot.utcOffsetSeconds)
        variables.floats[id.weekDay] = Float(snapshot.dayOfWeek)
        variables.floats[id.dayOfMonth] = Float(snapshot.dayOfMonth)
        variables.floats[id.dayOfYear] = Float(snapshot.dayOfYear)
        variables.floats[id.year] = Float(snapshot.year)
        variables.integers[id.epochSecond] = Int(snapshot.epochSeconds)
        
        if let apiLevel {
            variables.floats[id.apiLevel] = apiLevel
        }
    }
}
