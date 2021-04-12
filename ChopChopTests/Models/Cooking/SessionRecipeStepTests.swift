import XCTest
@testable import ChopChop

class SessionRecipeStepTests: XCTestCase {
//    Cook for 30s until the edges are dry and bubbles appear on surface. Flip; cook for 1 to 2 minutes. \
//    Yields 12 to 14 pancakes.

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
        XCTAssertEqual(sessionRecipeStep.timers.map { $0.0 }, ["30s", "1 to 2 minutes"])
        XCTAssertEqual(sessionRecipeStep.timers.map { $0.1.defaultTime }, [30, 90])
    }
}
