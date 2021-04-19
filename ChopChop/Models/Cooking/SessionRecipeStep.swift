import Foundation

/**
 Represents a step in the instructions for the recipe that is being made.
 
 Representation Invariants:
 - Step is valid.
 */
struct SessionRecipeStep: Hashable {
    // MARK: - Specification Fields
    /// The step in the instructions represented.
    let step: RecipeStep
    /// The timers contained in the step.
    let timers: [CountdownTimer]

    /**
     Initialises a session step with the given recipe step.
     */
    init(step: RecipeStep) {
        self.step = step
        timers = step.timers.map { CountdownTimer(duration: $0) }
    }
}
