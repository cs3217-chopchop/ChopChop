import XCTest
@testable import ChopChop

class ActionTimeTrackerTests: XCTestCase {

    func testUpdateTimeOfLastAction() throws {
        let actionTimeTracker = ActionTimeTracker()
        let newTime = Date().addingTimeInterval(-3)
        try actionTimeTracker.updateTimeOfLastAction(date: newTime)
        XCTAssertEqual(actionTimeTracker.timeOfLastAction, newTime)
    }

    func testUpdateTimeOfLastAction_veryLate() throws {
        let actionTimeTracker = ActionTimeTracker()
        let newTime = Date().addingTimeInterval(-1_000_000)
        try actionTimeTracker.updateTimeOfLastAction(date: newTime)
        XCTAssertEqual(actionTimeTracker.timeOfLastAction, newTime)
    }

}
