import Combine
import SwiftUI

final class RecipeStepTimersViewModel: ObservableObject {
    @Published var timers: [RecipeStepTimerRowViewModel]

    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    var timersPublisher: AnyPublisher<[TimeInterval], Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject = PassthroughSubject<[TimeInterval], Never>()

    init(timers: [TimeInterval]) {
        self.timers = timers.map {
            let hours = String(Int(($0 / 3_600).rounded(.down)))
            let minutes = String(Int(($0.truncatingRemainder(dividingBy: 3_600) / 60).rounded(.down)))
            let seconds = String(Int($0.truncatingRemainder(dividingBy: 3_600).truncatingRemainder(dividingBy: 60)))

            return RecipeStepTimerRowViewModel(hours: hours, minutes: minutes, seconds: seconds)
        }
    }

    func saveTimers() {
        do {
            subject.send(try timers.map { try $0.convertToTimeInterval() })
        } catch {
            alertTitle = "Error"

            if let message = (error as? LocalizedError)?.errorDescription {
                alertMessage = message
            } else {
                alertMessage = "\(error)"
            }

            alertIsPresented = true
        }
    }
}
