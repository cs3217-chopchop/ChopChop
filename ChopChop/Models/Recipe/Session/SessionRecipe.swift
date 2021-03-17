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

    // step related functions
    func addStep() {
        assert(checkRepresentation())
        // like adding a new empty line with checkbox
        let newStep = recipe.addStep()
        sessionSteps.append(SessionRecipeStep(step: newStep, actionTimeTracker: self))
        assert(checkRepresentation())
    }

    func removeStep(_ removedStep: SessionRecipeStep) throws {
        assert(checkRepresentation())
        try recipe.removeStep(removedStep.step)
        guard (sessionSteps.contains { $0 === removedStep }) else {
            assertionFailure()
            return
        }

        sessionSteps.removeAll { $0 === removedStep }
        assert(checkRepresentation())
    }

    // reorder step from larger to smaller index
    func moveStepUp(_ movedStep: SessionRecipeStep) throws {
        assert(checkRepresentation())
        try recipe.moveStepUp(movedStep.step)
        guard let idx = (sessionSteps.firstIndex { $0 === movedStep }) else {
            assertionFailure()
            return
        }

        guard idx > 0 else {
            assertionFailure()
            return
        }

        sessionSteps[idx] = sessionSteps[idx - 1]
        sessionSteps[idx - 1] = movedStep
        assert(checkRepresentation())
    }

    // reorder step from smaller to larger index
    func moveStepDown(_ movedStep: SessionRecipeStep) throws {
        assert(checkRepresentation())
        try recipe.moveStepDown(movedStep.step)
        guard let idx = (sessionSteps.firstIndex { $0 === movedStep }) else {
            assertionFailure()
            return
        }

        guard idx < sessionSteps.count - 1 else {
            assertionFailure()
            return
        }

        sessionSteps[idx] = sessionSteps[idx + 1]
        sessionSteps[idx + 1] = movedStep
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
