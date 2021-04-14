import Combine
import Foundation

final class CountdownTimer2 {
    private let duration: TimeInterval
    private let action: (TimeInterval) -> Void
    private let onEnded: () -> Void

    private var isRunning = false
    private var durationRemaining: TimeInterval
    private var startDate: Date?

    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .merge(with: Deferred { Just(Date()) })
    private var cancellable: AnyCancellable?

    init(duration: TimeInterval, action: @escaping (TimeInterval) -> Void = { _ in },
         onEnded: @escaping () -> Void = {}) throws {
        guard duration > 0 else {
            throw CountdownTimer2Error.invalidDuration
        }

        self.duration = duration
        self.action = action
        self.onEnded = onEnded
        self.durationRemaining = duration
    }

    func start() {
        guard !isRunning else {
            return
        }

        startDate = Date()

        // Delay until the next second if the timer starts in between seconds.
        // Since the delay affects the delivery of elements and completion, but not of the original subscription,
        // use the current Date() instead of the date provided by the timer closure
        cancellable = timer.delay(for: .seconds(durationRemaining.truncatingRemainder(dividingBy: 1)),
                                  scheduler: RunLoop.main)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.isRunning = true
            }, receiveCancel: { [weak self] in
                self?.isRunning = false
            })
            .sink { [weak self] _ in
                guard let durationRemaining = self?.durationRemaining, let startDate = self?.startDate else {
                    return
                }

                let timeRemaining = (durationRemaining - Date().timeIntervalSince(startDate)).rounded()
                self?.action(timeRemaining)

                if timeRemaining <= 0 {
                    self?.stop()
                    self?.onEnded()
                    return
                }
            }
    }

    func pause() {
        guard isRunning, let startDate = startDate else {
            return
        }

        durationRemaining -= Date().timeIntervalSince(startDate)
        cancellable?.cancel()
    }

    func resume() {
        start()
    }

    func stop() {
        durationRemaining = duration
        cancellable?.cancel()
    }
}

enum CountdownTimer2Error: LocalizedError {
    case invalidDuration

    var errorDescription: String? {
        switch self {
        case .invalidDuration:
            return "Timer duration should be positive."
        }
    }
}
