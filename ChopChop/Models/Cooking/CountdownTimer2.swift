import Combine
import Foundation

// State machine is as follows:
//
// .stopped - [ play() ] -> .running
// .stopped - [ reset() ] -> .stopped
// .running - [ pause() ] -> .paused
// .running - [ timeRemaining <= 0 ] -> .ended
// .paused - [ resume() ] -> .running
// .paused - [ reset() ] -> .stopped
// .ended - [ reset() ] -> .stopped
final class CountdownTimer2 {
    @Published private(set) var timeRemaining: TimeInterval
    @Published private(set) var status: Status = .stopped

    let duration: TimeInterval
    private var durationRemaining: TimeInterval
    private var startDate: Date?

    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .merge(with: Deferred { Just(Date()) })
    private var cancellable: AnyCancellable?

    init(duration: TimeInterval) {
        self.timeRemaining = duration
        self.duration = duration
        self.durationRemaining = duration
    }

    func start() {
        guard status == .paused || status == .stopped else {
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
                    self?.status = .ended
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
        guard status == .paused else {
            return
        }

        start()
    }

    func reset() {
        guard status != .running else {
            return
        }

        status = .stopped
        timeRemaining = duration
        durationRemaining = duration
        cancellable?.cancel()
    }
}

extension CountdownTimer2 {
    enum Status {
        case stopped, running, paused, ended
    }
}
