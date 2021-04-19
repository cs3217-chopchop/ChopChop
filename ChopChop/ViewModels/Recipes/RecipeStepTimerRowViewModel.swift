import Combine
import SwiftUI

/**
 Represents a view model for a view of a timer of a step in the recipe instructions.
 */
final class RecipeStepTimerRowViewModel: ObservableObject {
    /// Form fields
    @Published var hours: String
    @Published var minutes: String
    @Published var seconds: String

    init(hours: String = "0", minutes: String = "0", seconds: String = "0") {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }

    /**
     Formats the given input and updates the hours field.
     */
    func setHours(_ hours: String) {
        self.hours = hours.filter { "0123456789".contains($0) }
    }

    /**
     Formats the given input and updates the minutes field.
     */
    func setMinutes(_ minutes: String) {
        self.minutes = minutes.filter { "0123456789".contains($0) }
    }

    /**
     Formats the given input and updates the seconds field.
     */
    func setSeconds(_ seconds: String) {
        self.seconds = seconds.filter { "0123456789".contains($0) }
    }

    /**
     Converts the form fields into a `TimeInterval`

     - Throws: `RecipeStepError.invalidDuration` if the format of at least one of the form fields is invalid.
     */
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
