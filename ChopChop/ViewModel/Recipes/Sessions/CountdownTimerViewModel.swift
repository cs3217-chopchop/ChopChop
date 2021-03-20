import SwiftUI

class CountdownTimerViewModel: ObservableObject {
    @Published var isShow = false
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
        displayTime = CountdownTimerViewModel.getTimerDisplayTime(seconds: countdownTimer.remainingTime)
    }

    func countdown() {
        countdownTimer.countdown()
        displayTime = CountdownTimerViewModel.getTimerDisplayTime(seconds: countdownTimer.remainingTime)
    }

    func toggleShow() {
        isShow.toggle()
    }

    func start() {
        guard !disableStart else {
            return
        }
        countdownTimer.start()
        displayTime = CountdownTimerViewModel.getTimerDisplayTime(seconds: countdownTimer.remainingTime)
    }

    func pauseResume() {
        if countdownTimer.isRunning {
            countdownTimer.pause()
        } else {
            countdownTimer.resume()
            displayTime = CountdownTimerViewModel.getTimerDisplayTime(seconds: countdownTimer.remainingTime)
        }
    }

    func restart() {
        countdownTimer.restart()
        displayTime = CountdownTimerViewModel.getTimerDisplayTime(seconds: countdownTimer.remainingTime)
    }

    func increaseTime() {
        guard !disableIncreaseTime else {
            return
        }
        try? countdownTimer.updateDefaultTime(defaultTime: countdownTimer.defaultTime + 1)
        disableIncreaseTime = countdownTimer.defaultTime == CountdownTimer.maximumTime
        displayTime = CountdownTimerViewModel.getTimerDisplayTime(seconds: countdownTimer.remainingTime)
    }

    func decreaseTime() {
        guard !disableDecreaseTime else {
            return
        }
        try? countdownTimer.updateDefaultTime(defaultTime: countdownTimer.defaultTime - 1)
        disableDecreaseTime = countdownTimer.defaultTime == CountdownTimer.minimumTime
        displayTime = CountdownTimerViewModel.getTimerDisplayTime(seconds: countdownTimer.remainingTime)
    }

    static func getTimerDisplayTime(seconds: Int) -> String {
        let time = seconds
        let hour = "\(time / 3_600 / 10 > 0 ? "" : "0")\(time / 3_600)"
        let minute = "\((time % 3_600) / 60 / 10 > 0 ? "" : "0")\((time % 3_600) / 60)"
        let second = "\(((time % 3_600) % 60) / 10 > 0 ? "" : "0")\(((time % 3_600) % 60))"
        return hour + ":" + minute + ":" + second
    }

}
