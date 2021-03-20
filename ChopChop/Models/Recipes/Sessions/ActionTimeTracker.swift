import Foundation

class ActionTimeTracker {
    private(set) var timeOfLastAction = Date()

    func updateTimeOfLastAction(date: Date) throws {
        guard date <= Date() else {
            throw ActionTimeTrackerError.invalidTime
        }
        timeOfLastAction = date
    }
}

enum ActionTimeTrackerError: Error {
    case invalidTime
}
