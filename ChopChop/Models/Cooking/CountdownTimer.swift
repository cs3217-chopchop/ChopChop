import Foundation
import Combine

// All timings are in seconds
class CountdownTimer {
    private(set) var defaultTime: Int
    private(set) var remainingTime: Int
    private(set) var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private(set) var isRunning = false
    private(set) var isStart = false

    static let minimumTime = 0
    static let maximumTime = 24 * 60 * 60 - 1 // Maximum count is 1 day

    init(time: Int) throws {
        guard time >= CountdownTimer.minimumTime && time <= CountdownTimer.maximumTime else {
            throw CountdownTimerError.invalidTiming
        }
        remainingTime = time
        defaultTime = time
    }

    func countdown() {
        guard isRunning else {
            return
        }
        remainingTime -= 1
        guard remainingTime > 0 else {
            isRunning = false
            return
        }
    }

    func start() {
        guard !isRunning && remainingTime > 0 else {
            return
        }
        remainingTime = defaultTime
        isRunning = true
        timer.merge(with: Just(Date()))
        isStart = true
    }

    func pause() {
        guard isRunning && remainingTime > 0 else {
            return
        }
        isRunning = false
    }

    func resume() {
        guard !isRunning else {
            return
        }
        isRunning = true
    }

    func restart() {
        remainingTime = defaultTime
        isRunning = false
        isStart = false
    }

    func updateDefaultTime(defaultTime: Int) throws {
        // cannot update default time while running
        guard !isRunning && !isStart else {
            return
        }

        guard defaultTime >= CountdownTimer.minimumTime && defaultTime <= CountdownTimer.maximumTime else {
            throw CountdownTimerError.invalidTiming
        }
        self.defaultTime = defaultTime
        self.remainingTime = defaultTime
    }

}

enum CountdownTimerError: Error {
    case invalidTiming
}
