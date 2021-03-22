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
        let sessionRecipeStep = SessionRecipeStep(step: lastStep, actionTimeTracker: ActionTimeTracker())
        XCTAssertFalse(sessionRecipeStep.isCompleted)
        XCTAssertEqual(sessionRecipeStep.timeTaken, 0)
        XCTAssertTrue(sessionRecipeStep.step === lastStep)
        XCTAssertEqual(sessionRecipeStep.timers.map { $0.0 }, ["30s", "1 to 2 minutes"])
        XCTAssertEqual(sessionRecipeStep.timers.map { $0.1.defaultTime }, [30, 90])
    }

    func testToggleCompleted_uncomplete() throws {
        let sessionRecipe = SessionRecipe(recipe: RecipeTests.generateSampleRecipe())
        guard let lastSessionStep = sessionRecipe.sessionSteps.last else {
            XCTFail("No steps in recipe")
            return
        }
        try lastSessionStep.toggleCompleted()
        XCTAssertTrue(lastSessionStep.isCompleted)
        XCTAssertNotEqual(lastSessionStep.timeTaken, 0) // means updated

        try lastSessionStep.toggleCompleted()
        XCTAssertFalse(lastSessionStep.isCompleted)
        XCTAssertEqual(lastSessionStep.timeTaken, 0)
    }

    func testToggleCompleted_typical() throws {
        let sessionRecipe = SessionRecipe(recipe: RecipeTests.generateSampleRecipe())

        // there are 6 steps
        let sessionSteps = sessionRecipe.sessionSteps
        try sessionSteps[0].toggleCompleted()
        sleep(1)
        try sessionSteps[1].toggleCompleted()
        sleep(1)
        try sessionSteps[1].toggleCompleted()
        sleep(1)
        try sessionSteps[3].toggleCompleted()
        sleep(1)
        try sessionSteps[1].toggleCompleted()
        sleep(1)
        try sessionSteps[2].toggleCompleted()
        sleep(1)
        try sessionSteps[4].toggleCompleted()
        sleep(1)
        try sessionSteps[5].toggleCompleted()

        XCTAssertTrue(sessionSteps.allSatisfy { $0.timeTaken != 0 })
    }

}
