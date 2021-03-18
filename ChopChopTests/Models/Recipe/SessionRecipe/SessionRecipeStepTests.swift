import XCTest
@testable import ChopChop

class SessionRecipeStepTests: XCTestCase {

//    Cook for 30s until the edges are dry and bubbles appear on surface. Flip; cook for 1 to 2 minutes. \
//    Yields 12 to 14 pancakes.

    func testConstruct() throws {
        let sessionRecipe = SessionRecipe(recipe: RecipeTests.generateSampleRecipe())
        guard let lastStep = sessionRecipe.sessionSteps.last?.step else {
            XCTFail("No steps in recipe")
            return
        }
        let sessionRecipeStep = SessionRecipeStep(step: lastStep, actionTimeTracker: sessionRecipe)
        XCTAssertFalse(sessionRecipeStep.isCompleted)
        XCTAssertEqual(sessionRecipeStep.timeTaken, 0)
        XCTAssertTrue(sessionRecipeStep.step === lastStep)
        XCTAssertEqual(sessionRecipeStep.timers.map { $0.0 }, ["30s", "1 to 2 minutes"])
        XCTAssertEqual(sessionRecipeStep.timers.map { $0.1.defaultTime }, [30, 90])
    }

    func testToggleCompleted_uncomplete() {
        let sessionRecipe = SessionRecipe(recipe: RecipeTests.generateSampleRecipe())
        guard let lastSessionStep = sessionRecipe.sessionSteps.last else {
            XCTFail("No steps in recipe")
            return
        }
        lastSessionStep.toggleCompleted()
        XCTAssertTrue(lastSessionStep.isCompleted)
        XCTAssertNotEqual(lastSessionStep.timeTaken, 0) // means updated

        lastSessionStep.toggleCompleted()
        XCTAssertFalse(lastSessionStep.isCompleted)
        XCTAssertEqual(lastSessionStep.timeTaken, 0)
    }

    func testToggleCompleted_typical() {
        let sessionRecipe = SessionRecipe(recipe: RecipeTests.generateSampleRecipe())

        // there are 6 steps
        guard let sessionSteps = sessionRecipe.sessionSteps else {
            XCTFail("No session steps")
            return
        }
        sessionSteps[0].toggleCompleted()
        sessionSteps[1].toggleCompleted()
        sessionSteps[1].toggleCompleted()
        sessionSteps[3].toggleCompleted()
        sessionSteps[1].toggleCompleted()
        sessionSteps[2].toggleCompleted()
        sessionSteps[4].toggleCompleted()
        sessionSteps[5].toggleCompleted()
        dump(sessionSteps)

        XCTAssertTrue(sessionRecipe.isCompleted)
        XCTAssertTrue(sessionSteps.allSatisfy { $0.timeTaken != 0 })
    }

}
