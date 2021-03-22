import Foundation

class SessionRecipeStep: Identifiable {
    private(set) var isCompleted = false
    private(set) var timeTaken = 0.0 // for user log only
    private(set) var step: RecipeStep
    private(set) var timers: [(String, CountdownTimer)]

    private let actionTimeTracker: ActionTimeTracker

    init(step: RecipeStep, actionTimeTracker: ActionTimeTracker) {
        self.step = step
        self.actionTimeTracker = actionTimeTracker

        let durationPhrases = RecipeStepParser.parseTimerDurations(step: step.content)
        timers = SessionRecipeStep.convertToTimers(durationPhrases: durationPhrases)
    }

    /// If previously checked, becomes unchecked and timeTaken resets to 0.
    /// If previously unchecked, becomes checked and timeTaken recorded based on current time and timeOfLastAction.
    /// Also updates actionTimeTracker's timeOfLastAction.
    func toggleCompleted() {
        isCompleted.toggle()
        if isCompleted {
            timeTaken = Date().timeIntervalSinceReferenceDate -
                actionTimeTracker.timeOfLastAction.timeIntervalSinceReferenceDate
        } else {
            // means step is unchecked and time should be reset
            timeTaken = 0
        }
        try? actionTimeTracker.updateTimeOfLastAction(date: Date())
    }

    private static func convertToTimers(durationPhrases: [String]) -> [(String, CountdownTimer)] {
        durationPhrases.map { duration -> (String, CountdownTimer) in
            do {
                let timer = try CountdownTimer(time: RecipeStepParser.parseToTime(timeString: duration))
                return (duration, timer)
            } catch {
                fatalError("Time was not valid")
            }
        }
    }

}
