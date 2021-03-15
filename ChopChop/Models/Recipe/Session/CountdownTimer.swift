import Foundation

class CountdownTimer {
    var defaultTime: Int
    var remainingTime: Int // in seconds -> display this
    var timer: Timer? // https://developer.apple.com/documentation/foundation/timer/2091888-init

    init(time: Int) {
        remainingTime = time
        defaultTime = time
    }

    @objc private func countdown() {
        remainingTime -= 1;
        guard remainingTime <= 0 else {
            timer?.invalidate()
            // ring sound?
            return
        }
    }

    func start() {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: false)
//        RunLoop.current.add(timer, forMode: .common)
//        Timer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: false)
    }

    func pause() {
        timer?.invalidate()
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

    // use case: user inc or dec default time, prob thru up and down arrow buttons
    func updateDefaultTime(defaultTime: Int) {
        self.defaultTime = defaultTime
    }

    
}
