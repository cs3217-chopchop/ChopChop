import Combine
import Foundation

/**
 Represents a view model of a view of a timer.
 */
final class CountdownTimerViewModel: ObservableObject {
    /// The timer displayed in the view.
    let timer: CountdownTimer
    /// The time remaining of the timer.
    @Published var timeRemaining: String = ""
    /// The status of the timer.
    @Published var status: CountdownTimer.Status = .stopped

    private let timeFormatter: DateComponentsFormatter
    private var cancellables: Set<AnyCancellable> = []

    init(timer: CountdownTimer) {
        self.timer = timer

        timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.zeroFormattingBehavior = .pad

        timer.$timeRemaining
            .sink { [weak self] time in
                // Truncate the string so that it has at most 2 digits in each unit
                self?.timeRemaining = String((self?.timeFormatter.string(from: time) ?? "").suffix(8))
            }
            .store(in: &cancellables)

        timer.$status
            .sink { [weak self] status in
                self?.status = status
            }
            .store(in: &cancellables)
    }
}
