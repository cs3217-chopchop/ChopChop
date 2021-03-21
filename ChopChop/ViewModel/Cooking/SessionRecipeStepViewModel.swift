import SwiftUI

class SessionRecipeStepViewModel: ObservableObject {
    @Published var isCompleted: Bool
    @Published var textWithTimers: [(String, CountdownTimer?)]
    private let sessionRecipeStep: SessionRecipeStep

    init(sessionRecipeStep: SessionRecipeStep) {
        self.sessionRecipeStep = sessionRecipeStep
        self.isCompleted = sessionRecipeStep.isCompleted
        textWithTimers = SessionRecipeStepViewModel.createTextWithTimers(sessionRecipeStep: sessionRecipeStep)
    }

    func toggleCompleted() {
        sessionRecipeStep.toggleCompleted()
        isCompleted = sessionRecipeStep.isCompleted

    }

    /// Breaks up the contents of a step to an array of tuple containing substring of the content and an optional CountdownTimerViewModel
    /// E.g. "Cook for 30s until the edges are dry and bubbles appear on surface. Flip; cook for 1 to 2 minutes. Yields 12 to 14 pancakes." into
    /// [("Cook for", nil), ("30s", timer), ("until the edges are dry and bubbles appear on surface. Flip; cook for ", nil),
    /// ("1 to 2 minutes", timer), (". Yields 12 to 14 pancakes.", nil)]" 
    private static func createTextWithTimers(sessionRecipeStep: SessionRecipeStep) -> [(String, CountdownTimer?)] {
        var textWithTimers: [(String, CountdownTimer?)] = []
        var timerCount = 0
        var characterCountInText = 0
        let originalText = sessionRecipeStep.step.content
        let endOfText = sessionRecipeStep.step.content.count
        while characterCountInText < endOfText {
            if timerCount >= sessionRecipeStep.timers.count {
                textWithTimers.append((originalText.substring(fromIndex: characterCountInText), nil))
                break
            }

            let start = characterCountInText
            let timerText = sessionRecipeStep.timers[timerCount].0
            let end = characterCountInText + timerText.count
            if originalText[start..<end] == timerText {
//                textWithTimers.append((timerText, CountdownTimerViewModel(countdownTimer: sessionRecipeStep.timers[timerCount].1)))
                textWithTimers.append((timerText, sessionRecipeStep.timers[timerCount].1))
                characterCountInText += timerText.count
                timerCount += 1
            } else {
                if textWithTimers.isEmpty || (textWithTimers.last != nil && textWithTimers.last?.1 != nil) {
                    // create a new one
                    textWithTimers.append((originalText[characterCountInText], nil))
                } else {
                    // add to previous
                    textWithTimers[textWithTimers.count - 1].0 += originalText[characterCountInText]
                }
                characterCountInText += 1
            }
        }

        assert(timerCount == sessionRecipeStep.timers.count)
        return textWithTimers
    }

}
