import XCTest
@testable import ChopChop

class SessionRecipeStepTests: XCTestCase {
    func testConstruct() throws {
        let sessionRecipe = SessionRecipe(recipe: RecipeTests.generateSampleRecipe())
        guard let lastStep = sessionRecipe.stepGraph.topologicallySortedNodes.last?.label.step else {
            XCTFail("No steps in recipe")
            return
        }
        let sessionRecipeStep = SessionRecipeStep(step: lastStep, actionTimeTracker: ActionTimeTracker())
        XCTAssertFalse(sessionRecipeStep.isCompleted)
        XCTAssertEqual(sessionRecipeStep.timeTaken, 0)
        XCTAssertTrue(sessionRecipeStep.step == lastStep)
    }
}
