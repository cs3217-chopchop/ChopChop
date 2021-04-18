import Combine
import SwiftUI

final class RecipeStepTimerRowViewModel: ObservableObject {
    @Published var hours: String
    @Published var minutes: String
    @Published var seconds: String

    init(hours: String = "0", minutes: String = "0", seconds: String = "0") {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }

    func setHours(_ hours: String) {
        self.hours = hours.filter { "0123456789".contains($0) }
    }

    func setMinutes(_ minutes: String) {
        self.minutes = minutes.filter { "0123456789".contains($0) }
    }

    func setSeconds(_ seconds: String) {
        self.seconds = seconds.filter { "0123456789".contains($0) }
    }

    func convertToTimeInterval() throws -> TimeInterval {
        guard let hours = TimeInterval(hours), let minutes = TimeInterval(minutes),
              let seconds = TimeInterval(seconds) else {
            throw RecipeStepError.invalidDuration
        }

        return hours * 3_600 + minutes * 60 + seconds
    }
}

extension RecipeStepTimerRowViewModel: Equatable {
    static func == (lhs: RecipeStepTimerRowViewModel, rhs: RecipeStepTimerRowViewModel) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension RecipeStepTimerRowViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
