import SwiftUI

class SessionRecipeStepViewModel: ObservableObject, Identifiable {
    @Published var isCompleted: Bool
    @Published var textWithTimers: [(String, CountdownTimerViewModel?)] = []
    private let sessionRecipeStep: SessionRecipeStep
    @Published var isDisabled = false {
        didSet {
            if isDisabled {
                textWithTimers.forEach { $0.1?.isDisabled = true }
            }
        }
    }

    init(sessionRecipeStep: SessionRecipeStep) {
        self.sessionRecipeStep = sessionRecipeStep
        self.isCompleted = sessionRecipeStep.isCompleted
        textWithTimers = self.createTextWithTimers(sessionRecipeStep: sessionRecipeStep)
    }

    func toggleCompleted() {
        guard !isDisabled else {
            return
        }
        sessionRecipeStep.toggleCompleted()
        isCompleted = sessionRecipeStep.isCompleted
    }

    /// Breaks up the contents of a step to an array of tuple containing substring of the content
    /// and an optional CountdownTimerViewModel
    /// E.g. "Cook for 30s until the edges are dry and bubbles appear on surface.
    /// Flip; cook for 1 to 2 minutes. Yields 12 to 14 pancakes." into
    /// [("Cook for", nil), ("30s", timer),
    /// ("until the edges are dry and bubbles appear on surface. Flip; cook for ", nil),
    /// ("1 to 2 minutes", timer), (". Yields 12 to 14 pancakes.", nil)]" 
    private func createTextWithTimers(sessionRecipeStep: SessionRecipeStep) -> [(String, CountdownTimerViewModel?)] {
        let splitStepContentBy = sessionRecipeStep.timers.map { $0.0 }
        let splittedStepContent = sessionRecipeStep.step.content
            .componentsSeperatedByStrings(separators: splitStepContentBy)
        var stringsToTimers: [(String, CountdownTimerViewModel?)] = []
        var timerIdx = 0
        for substring in splittedStepContent {
            guard sessionRecipeStep.timers.contains(where: { $0.0 == substring }) else {
                // no timer associated with substring
                stringsToTimers.append((substring, nil))
                continue
            }
            // has timer associated with substring
            stringsToTimers.append((substring, CountdownTimerViewModel(countdownTimer:
                                                                        sessionRecipeStep.timers[timerIdx].1)))
            timerIdx += 1
        }
        assert(timerIdx == sessionRecipeStep.timers.count)
        return stringsToTimers
    }

}
