import Foundation

class SessionRecipe {
    var timeOfLastAction = Date()

    var recipe: Recipe
    var sessionSteps: [SessionRecipeStep]

    var isCompleted: Bool {
        sessionSteps.allSatisfy{$0.isCompleted}
    }


}
