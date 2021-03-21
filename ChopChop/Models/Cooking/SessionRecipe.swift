import Foundation

class SessionRecipe {
    private(set) var recipe: Recipe
    private(set) var sessionSteps: [SessionRecipeStep]

    init(recipe: Recipe) {
        // A copy of the recipe object is made so that recipe on recipe tab dosen't actually get modified
        guard let recipeCopy = recipe.copy() as? Recipe else {
            fatalError("Could not copy recipe for edit")
        }
        self.recipe = recipeCopy
        let actionTimeTracker = ActionTimeTracker()
        sessionSteps = recipeCopy.steps.map { SessionRecipeStep(step: $0, actionTimeTracker: actionTimeTracker) }
    }
//
//    var isCompleted: Bool {
//        sessionSteps.allSatisfy { $0.isCompleted }
//    }

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

}
