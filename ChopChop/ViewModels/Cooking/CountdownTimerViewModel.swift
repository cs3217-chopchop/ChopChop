import SwiftUI

class CountdownTimerViewModel: ObservableObject {
    let countdownTimer: CountdownTimer
    @Published var displayTime: String
    @Published var disableIncreaseTime: Bool
    @Published var disableDecreaseTime: Bool
    @Published var disableStart: Bool

    init(countdownTimer: CountdownTimer) {
        self.countdownTimer = countdownTimer
        disableStart = countdownTimer.defaultTime == 0
        disableDecreaseTime = countdownTimer.defaultTime == CountdownTimer.minimumTime
        disableIncreaseTime = countdownTimer.defaultTime == CountdownTimer.maximumTime
        displayTime = get_HHMMSS_Display(seconds: countdownTimer.remainingTime)
    }

    func countdown() {
        countdownTimer.countdown()
        displayTime = get_HHMMSS_Display(seconds: countdownTimer.remainingTime)
    }

    func start() {
        guard !disableStart else {
            return
        }
        countdownTimer.start()
        displayTime = get_HHMMSS_Display(seconds: countdownTimer.remainingTime)
    }

    func pauseResume() {
        if countdownTimer.isRunning {
            countdownTimer.pause()
        } else {
            countdownTimer.resume()
            displayTime = get_HHMMSS_Display(seconds: countdownTimer.remainingTime)
        }
    }

    func restart() {
        countdownTimer.restart()
        displayTime = get_HHMMSS_Display(seconds: countdownTimer.remainingTime)
    }

    func increaseTime() {
        guard !disableIncreaseTime else {
            return
        }
        try? countdownTimer.updateDefaultTime(defaultTime: countdownTimer.defaultTime + 1)
        disableIncreaseTime = countdownTimer.defaultTime == CountdownTimer.maximumTime
        displayTime = get_HHMMSS_Display(seconds: countdownTimer.remainingTime)
    }

    func decreaseTime() {
        guard !disableDecreaseTime else {
            return
        }
        try? countdownTimer.updateDefaultTime(defaultTime: countdownTimer.defaultTime - 1)
        disableDecreaseTime = countdownTimer.defaultTime == CountdownTimer.minimumTime
        displayTime = get_HHMMSS_Display(seconds: countdownTimer.remainingTime)
    }

}

extension CountdownTimerViewModel: Identifiable, Equatable {
    static func == (lhs: CountdownTimerViewModel, rhs: CountdownTimerViewModel) -> Bool {
        lhs === rhs
    }
}
