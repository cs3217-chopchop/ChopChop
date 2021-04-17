import Combine
import Foundation

final class CountdownTimerViewModel: ObservableObject {
    @Published var timeRemaining: String = ""
    @Published var status: CountdownTimer.Status = .stopped

    let timer: CountdownTimer
    private let timeFormatter: DateComponentsFormatter

    private var timeRemainingCancellable: AnyCancellable?
    private var statusCancellable: AnyCancellable?

    init(timer: CountdownTimer) {
        self.timer = timer

        timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.zeroFormattingBehavior = .pad

        timeRemainingCancellable = timer.$timeRemaining.sink { [weak self] time in
            // Truncate the string so that it has at most 2 digits in each unit
            self?.timeRemaining = String((self?.timeFormatter.string(from: time) ?? "").suffix(8))
        }

        statusCancellable = timer.$status.sink { [weak self] status in
            self?.status = status
        }
    }
}
