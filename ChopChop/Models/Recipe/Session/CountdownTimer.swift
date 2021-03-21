import Foundation

// All timings are in seconds
class CountdownTimer {
    private(set) var defaultTime: Int
    private(set) var remainingTime: Int
    private(set) var timer: Timer? // timer exists if running, dosent exist if not running

    private var isStart = false

    init(time: Int) throws {
        guard time >= 0 else {
            throw CountdownTimerError.invalidTiming
        }
        remainingTime = time
        defaultTime = time
    }

    @objc private func countdown() {
        guard timer != nil else {
            assertionFailure("No timer to run")
            return
        }
        remainingTime -= 1
        guard remainingTime > 0 else {
            timer?.invalidate()
            timer = nil
            isStart = false
            return
        }
    }

    func start() {
        guard !isStart && remainingTime > 0 else {
            return
        }
        remainingTime = defaultTime
        addTimerToRunLoop()
        isStart = true
    }

    func pause() {
        guard isStart && remainingTime > 0 else {
            return
        }
        timer?.invalidate() // removes timer from RunLoop
        timer = nil
    }

    func resume() {
        guard isStart else {
            return
        }
        addTimerToRunLoop()
    }

    func restart() {
        remainingTime = defaultTime
        timer?.invalidate()
        timer = nil
        isStart = false
    }

    func updateDefaultTime(defaultTime: Int) throws {
        // can update default time while running
        guard defaultTime >= 0 else {
            throw CountdownTimerError.invalidTiming
        }
        self.defaultTime = defaultTime
    }

    private func addTimerToRunLoop() {
        guard timer == nil else {
            return
        }
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown),
                                         userInfo: nil, repeats: true)

        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }

    // swiftlint:disable large_tuple
    var hoursMinutesSeconds: (Int, Int, Int) {
      (remainingTime / 3_600, (remainingTime % 3_600) / 60, (remainingTime % 3_600) % 60)
    }
}

enum CountdownTimerError: Error {
    case invalidTiming
}
