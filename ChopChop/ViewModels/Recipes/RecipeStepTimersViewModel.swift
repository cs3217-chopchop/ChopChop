import Combine
import SwiftUI

/**
 Represents a view model for a view of a collection of timers for an instruction step.
 */
final class RecipeStepTimersViewModel: ObservableObject {
    /// The node containing the step that owns the timers.
    let node: RecipeStepNode
    /// The collection of timers displayed.
    @Published var timers: [RecipeStepTimerRowViewModel]

    /// Alert fields
    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    /// Display flags
    @Published var actionSheetIsPresented = false

    private let subject = PassthroughSubject<[TimeInterval], Never>()

    init(node: RecipeStepNode, timers: [TimeInterval]) {
        self.node = node
        self.timers = timers.map(RecipeStepTimersViewModel.convertToViewModel)
    }

    /**
     Parses the content of the step to a collection of timers,
     overwriting or appending to the current collection depending on the given flag.
     */
    func parseTimers(shouldOverwrite: Bool = false) {
        let timers = RecipeStepParser.parseTimeStrings(step: node.label.content).map {
            TimeInterval(RecipeStepParser.parseDuration(timeString: $0))
        }

        if shouldOverwrite {
            self.timers = timers.map(RecipeStepTimersViewModel.convertToViewModel)
        } else {
            self.timers.append(contentsOf: timers.map(RecipeStepTimersViewModel.convertToViewModel))
        }
    }

    /**
     Saves the timers to local storage, or updates the alert fields if saving fails.
     */
    func saveTimers() -> Bool {
        do {
            subject.send(try timers.map {
                let duration = try $0.convertToTimeInterval()

                guard duration > 0 else {
                    throw RecipeStepError.invalidDuration
                }

                return duration
            })

            return true
        } catch {
            alertTitle = "Error"

            if let message = (error as? LocalizedError)?.errorDescription {
                alertMessage = message
            } else {
                alertMessage = "\(error)"
            }

            alertIsPresented = true

            return false
        }
    }

    private static func convertToViewModel(_ duration: TimeInterval) -> RecipeStepTimerRowViewModel {
        let hours = String(Int((duration / 3_600).rounded(.down)))
        let minutes = String(Int((duration.truncatingRemainder(dividingBy: 3_600) / 60).rounded(.down)))
        let seconds = String(Int(duration.truncatingRemainder(dividingBy: 60)))

        return RecipeStepTimerRowViewModel(hours: hours, minutes: minutes, seconds: seconds)
    }

    var timersPublisher: AnyPublisher<[TimeInterval], Never> {
        subject.eraseToAnyPublisher()
    }
}
