import Combine
import Foundation

/**
 Represents a timer for a duration in a recipe step, modeled as a finite state machine.
 
 The state machine has the following transitions:
 - `.stopped` - ( `start()` ) -> `.running`
 - `.stopped` - ( `reset()` ) -> `.stopped`
 - `.running` - ( `pause()` ) -> `.paused`
 - `.running` - ( `timeRemaining <= 0` ) -> `.ended`
 - `.paused` - ( `resume()` ) -> `.running`
 - `.paused` - ( `reset()` ) -> `.stopped`
 - `.ended` - ( `reset()` ) -> `.stopped`
 */
final class CountdownTimer {
    // MARK: - Specification Fields
    /// The time remaining before the timer ends.
    @Published private(set) var timeRemaining: TimeInterval
    /// The current status of the timer.
    @Published private(set) var status: Status = .stopped
    /// The total duration of the timer.
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

    /**
     Starts the timer.
     If the timer was not stopped, do nothing.
     */
    func start() {
        guard status.wasStopped else {
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

                if timeRemaining <= 0 && self?.status != .ended {
                    self?.status = .ended
                    return
                }
            }
    }

    /**
     Pauses the timer.
     If the timer is not running, do nothing.
     */
    func pause() {
        guard status == .running, let startDate = startDate else {
            return
        }

        status = .paused
        durationRemaining -= Date().timeIntervalSince(startDate)
        cancellable?.cancel()
    }

    /**
     Resumes the timer.
     If the timer is not paused, do nothing.
     */
    func resume() {
        guard status == .paused else {
            return
        }

        start()
    }

    /**
     Resets the timer.
     If the timer is running, do nothing.
     */
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

extension CountdownTimer: Equatable {
    static func == (lhs: CountdownTimer, rhs: CountdownTimer) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension CountdownTimer: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension CountdownTimer {
    enum Status {
        case stopped, running, paused, ended

        var wasStopped: Bool {
            switch self {
            case .stopped, .paused:
                return true
            case .running, .ended:
                return false
            }
        }
    }
}
