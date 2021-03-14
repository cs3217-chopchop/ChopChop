import Foundation

class SessionRecipeStep {
    var isCompleted = false
    var timeTaken = 0.0 // for user log only
    var step: RecipeStep
    private(set) var timers: [(String, CountdownTimer)]

    var actionTimeTracker: ActionTimeTracker

    init(step: RecipeStep, actionTimeTracker: ActionTimeTracker) {
        self.step = step
        self.actionTimeTracker = actionTimeTracker

        let parser = RecipeStepParser()
        let durationStrings = parser.parseTimerDurations(step: step.content)
        timers = durationStrings.map{($0, CountdownTimer(time: parser.parseToTime(timeString: $0)))}
    }

    func toggleCompleted() {
        isCompleted = !isCompleted
        if isCompleted {
            // https://stackoverflow.com/questions/50950092/calculating-the-difference-between-two-dates-in-swift
            timeTaken = Date().timeIntervalSinceReferenceDate - actionTimeTracker.timeOfLastAction.timeIntervalSinceReferenceDate
        } else {
            // means step is unchecked
            timeTaken = 0
        }
        actionTimeTracker.timeOfLastAction = Date()
    }

    func updateStep(content: String) {
        step.updateContent(content: content)

        // the next few steps are abit iffy,
        // the easiest way would be to prevent edit to step while timer is counting down
        // but the user would probably want to "retain" old timers through some intelligent decision making

        // check if timing words are the same
        let newTimeWords = RecipeStepParser().parseTimerDurations(step: content)
        let isTimersExactlySame = newTimeWords == timers.map{$0.0}

        guard !isTimersExactlySame else {
            // currently all timing words must be the same to not edit timers at all
            return
        }

        // otherwise, nuke all timers and replace with new timers
        timers = newTimeWords.map{($0, CountdownTimer(time: RecipeStepParser().parseToTime(timeString: $0)))}

    }


}
