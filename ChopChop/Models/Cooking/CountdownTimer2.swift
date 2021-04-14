import Combine
import Foundation

final class CountdownTimer2 {
    @Published private(set) var timeRemaining: TimeInterval
    @Published private(set) var status: Status = .paused

    private let duration: TimeInterval
    private var durationRemaining: TimeInterval
    private var startDate: Date?

    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .merge(with: Deferred { Just(Date()) })
    private var cancellable: AnyCancellable?

    init(duration: TimeInterval) throws {
        guard duration > 0 else {
            throw CountdownTimer2Error.invalidDuration
        }

        self.timeRemaining = duration
        self.duration = duration
        self.durationRemaining = duration
    }

    func start() {
        guard status != .running else {
            return
        }

        status = .running
        startDate = Date()

        // Delay until the next second if the timer starts in between seconds.
        // Since the delay affects the delivery of elements and completion, but not of the original subscription,
        // use the current Date() instead of the date provided by the timer closure
        cancellable = timer.delay(for: .seconds(durationRemaining.truncatingRemainder(dividingBy: 1)),
                                  scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let durationRemaining = self?.durationRemaining, let startDate = self?.startDate else {
                    return
                }

                let timeRemaining = (durationRemaining - Date().timeIntervalSince(startDate)).rounded()
                self?.timeRemaining = timeRemaining

                if timeRemaining <= 0 {
                    self?.stop()
                    return
                }
            }
    }

    func pause() {
        guard status == .running, let startDate = startDate else {
            return
        }

        status = .paused
        durationRemaining -= Date().timeIntervalSince(startDate)
        cancellable?.cancel()
    }

    func resume() {
        start()
    }

    func stop() {
        status = .stopped
        durationRemaining = duration
        cancellable?.cancel()
    }
}

extension CountdownTimer2 {
    enum Status {
        case running, paused, stopped
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
