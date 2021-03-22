import Foundation

class SessionRecipe {
    private(set) var recipe: Recipe
    private(set) var sessionSteps: [SessionRecipeStep]
    private(set) var isCompleted = false

    init(recipe: Recipe) {
        self.recipe = recipe
        let actionTimeTracker = ActionTimeTracker()
        sessionSteps = recipe.steps.map { SessionRecipeStep(step: $0, actionTimeTracker: actionTimeTracker) }
    }

    private func checkRepresentation() -> Bool {
        guard recipe.steps.count == sessionSteps.count else {
            return false
        }

        for i in 0..<recipe.steps.count {
            // recipe's steps and session steps are in complete same order
            guard recipe.steps[i] === sessionSteps[i].step else {
                return false
            }
        }

        return true
    }

    func updateCompleted() {
        isCompleted = true
    }

}
