import XCTest
 @testable import ChopChop

 class CountdownTimerTests: XCTestCase {

    let time = 30 // 30 seconds
    let runDuration = 3

    func testConstruct() throws {
        let timer = try CountdownTimer(time: time)
        XCTAssertEqual(timer.defaultTime, time)
        XCTAssertEqual(timer.remainingTime, time)
        XCTAssertNil(timer.timer)
    }

    func testConstruct_invalidTime() throws {
        XCTAssertThrowsError(try CountdownTimer(time: -1))
    }

    func testStart() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        XCTAssertEqual(timer.remainingTime, time)
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time - runDuration)
    }

    func testStart_overshoot() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        runLoop(seconds: time + 1)
        XCTAssertEqual(timer.remainingTime, 0)
    }

    func testStart_manyTimes() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        timer.start()
        timer.start()
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time - runDuration)
    }

    func testPause() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        runLoop(seconds: runDuration)
        timer.pause()
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time - runDuration)
    }

    func testPause_noTimeLeft() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        runLoop(seconds: time + 1)
        timer.pause()
        XCTAssertNoThrow(runLoop(seconds: runDuration))
        XCTAssertEqual(timer.remainingTime, 0)
    }

    func testPause_noTimer() throws {
        let timer = try CountdownTimer(time: time)
        XCTAssertNoThrow(timer.pause())
    }

    func testResume() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        runLoop(seconds: runDuration)
        timer.pause()
        runLoop(seconds: runDuration)
        timer.resume()
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time - 2 * runDuration)
    }

    func testResume_manyTimes() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        timer.pause()
        timer.resume()
        timer.resume()
        timer.resume()
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time - runDuration)
    }

    func testResume_withoutStart() throws {
        let timer = try CountdownTimer(time: time)
        timer.resume()
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time)
    }

    func testStartPauseResume() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        timer.pause()
        timer.resume()
        runLoop(seconds: runDuration)
        timer.pause()
        runLoop(seconds: runDuration)
        timer.resume()
        runLoop(seconds: runDuration)
        timer.pause()
        timer.resume()
        runLoop(seconds: runDuration)
        timer.pause()
        timer.resume()
        XCTAssertEqual(timer.remainingTime, time - 3 * runDuration)
    }

    func testRestart_whileRunning() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time - runDuration)
        timer.restart()
        XCTAssertEqual(timer.remainingTime, time)
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time)
        timer.start()
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time - runDuration)
    }

    func testRestart_paused() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time - runDuration)
        timer.restart()
        XCTAssertEqual(timer.remainingTime, time)
        timer.start()
        runLoop(seconds: runDuration)
        XCTAssertEqual(timer.remainingTime, time - runDuration)
    }

    func testUpdateDefaultTime() throws {
        let timer = try CountdownTimer(time: time)
        try timer.updateDefaultTime(defaultTime: 100)
        XCTAssertEqual(timer.defaultTime, 100)
    }

    func testUpdateDefaultTime_runningTimer() throws {
        let timer = try CountdownTimer(time: time)
        timer.start()
        runLoop(seconds: runDuration)
        try timer.updateDefaultTime(defaultTime: 100)
        XCTAssertEqual(timer.defaultTime, 100)
        XCTAssertEqual(timer.remainingTime, time - runDuration, "No change to remaining time if timer is running")

    }

    private func runLoop(seconds: Int) {
        RunLoop.current.run(until: Date().addingTimeInterval(TimeInterval(seconds)))
    }

 }
