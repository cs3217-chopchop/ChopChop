import Foundation

/// Conforms to ActionTimeTracker so that SessionRecipeStep can modify only 1 attribute through the delegate
class SessionRecipe: ActionTimeTracker {
    private(set) var timeOfLastAction = Date()
    private(set) var recipe: Recipe
    private(set) var sessionSteps: [SessionRecipeStep]! // implicitly unwrapped optional due to need to bind to self

    init(recipe: Recipe) {
        // A copy of the recipe object is made so that recipe on recipe tab dosen't actually get modified
        guard let recipeCopy = recipe.copy() as? Recipe else {
            fatalError()
        }
        self.recipe = recipeCopy
        sessionSteps = recipeCopy.steps.map { SessionRecipeStep(step: $0, actionTimeTracker: self) }
    }

    // future use case: on complete, send session steps to user log
    var isCompleted: Bool {
        sessionSteps.allSatisfy { $0.isCompleted }
    }

    func updateTimeOfLastAction(date: Date) {
        assert(checkRepresentation())
        timeOfLastAction = date
        assert(checkRepresentation())
    }

    // all other attributes of recipe can be modified from recipe itself

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

        guard timeOfLastAction >= Date() else {
            return false
        }

        return true
    }
}
