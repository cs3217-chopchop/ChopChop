import Foundation

struct SessionRecipeStep: Hashable {
    let step: RecipeStep
    let timers: [CountdownTimer]

    init(step: RecipeStep) {
        self.step = step
        timers = step.timers.map { CountdownTimer(duration: $0) }
    }
}
