import Foundation

// All timings are in seconds
class CountdownTimer {
    private(set) var defaultTime: Int
    private(set) var remainingTime: Int
    private(set) var timer: Timer?

    init(time: Int) {
        remainingTime = time
        defaultTime = time
    }

    @objc private func countdown() {
        remainingTime -= 1;
        guard remainingTime > 0 else {
            timer?.invalidate()
            return
        }
    }

    func start() {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: false)
    }

    func pause() {
        timer?.invalidate() // removes timer from RunLoop
    }

    func resume() {
        guard let existingTimer = timer else {
            assertionFailure()
            return
        }
        RunLoop.current.add(existingTimer, forMode: .common)
    }

    func restart() {
        remainingTime = defaultTime
    }

    // use case: user inc or dec default time
    func updateDefaultTime(defaultTime: Int) {
        self.defaultTime = defaultTime
    }
    
}
