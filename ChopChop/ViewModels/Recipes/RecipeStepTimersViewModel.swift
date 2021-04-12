import Combine
import SwiftUI

final class RecipeStepTimersViewModel: ObservableObject {
    @Published var timers: [RecipeStepTimerRowViewModel]

    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    @Published var actionSheetIsPresented = false

    var timersPublisher: AnyPublisher<[TimeInterval], Never> {
        subject.eraseToAnyPublisher()
    }

    let node: RecipeStepNode
    private let subject = PassthroughSubject<[TimeInterval], Never>()

    init(node: RecipeStepNode, timers: [TimeInterval]) {
        self.node = node
        self.timers = timers.map(RecipeStepTimersViewModel.convertToViewModel)
    }

    func parseTimers(shouldOverride: Bool = false) {
        let timers = RecipeStepParser.parseTimerDurations(step: node.label.content).map {
            TimeInterval(RecipeStepParser.parseToTime(timeString: $0))
        }

        if shouldOverride {
            self.timers = timers.map(RecipeStepTimersViewModel.convertToViewModel)
        } else {
            self.timers.append(contentsOf: timers.map(RecipeStepTimersViewModel.convertToViewModel))
        }
    }

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
}
