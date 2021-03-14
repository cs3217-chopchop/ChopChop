import Foundation

class SessionRecipeStep {
    var isCompleted = false
    var timeTaken = 0.0
    var step: RecipeStep
    var timers: [Timer]

    init(step: RecipeStep) {
        self.step = step
        timers = step.content // parse... Timer.publish(every: 1, on: .main, in: .common)
    }

    func parseTimers(content: String) {
        // 20 - 25 mins
        // 2025 minutes
        let time_indicator_regex = '(min|hour)'

       

    }

}
