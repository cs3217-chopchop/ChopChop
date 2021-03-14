import Foundation

class CountdownTimer {
    var defaultTime: Double
    var remainingTime: Double // in seconds -> display this
    var timer: Timer? // https://developer.apple.com/documentation/foundation/timer/2091888-init

    init(time: Double) {
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
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: false)
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

    func updateDefaultTime(defaultTime: Double) {
        self.defaultTime = defaultTime
    }

    
}
