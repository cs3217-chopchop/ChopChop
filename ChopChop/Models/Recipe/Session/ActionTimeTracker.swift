import Foundation

protocol ActionTimeTracker {
    var timeOfLastAction: Date { get }
    func updateTimeOfLastAction(date: Date)
}
