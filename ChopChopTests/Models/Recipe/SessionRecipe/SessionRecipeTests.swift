import XCTest
@testable import ChopChop

class SessionRecipeTests: XCTestCase {

    func testConstruct() throws {
        let recipe = try Recipe(name: "Pancakes")
        let sessionRecipe = SessionRecipe(recipe: recipe)
        XCTAssertLessThanOrEqual(sessionRecipe.timeOfLastAction, Date())
        XCTAssertEqual(sessionRecipe.recipe, recipe)
        XCTAssertTrue(sessionRecipe.sessionSteps.isEmpty)
        XCTAssertFalse(sessionRecipe.recipe === recipe) // check identity

        let recipe2 = RecipeTests.generateSampleRecipe()
        let sessionRecipe2 = SessionRecipe(recipe: recipe2)
        XCTAssertLessThanOrEqual(sessionRecipe2.timeOfLastAction, Date())
        XCTAssertEqual(sessionRecipe2.recipe, recipe2)
        XCTAssertEqual(sessionRecipe2.sessionSteps.map { $0.step }, recipe2.steps)
    }

    func testUpdateTimeOfLastAction() {
        let sessionRecipe = SessionRecipe(recipe: RecipeTests.generateSampleRecipe())
        let newTime = Date().addingTimeInterval(-3)
        sessionRecipe.updateTimeOfLastAction(date: newTime)
        XCTAssertEqual(sessionRecipe.timeOfLastAction, newTime)
    }

    func testUpdateTimeOfLastAction_veryLate() {
        let sessionRecipe = SessionRecipe(recipe: RecipeTests.generateSampleRecipe())
        let newTime = Date().addingTimeInterval(-1_000_000)
        sessionRecipe.updateTimeOfLastAction(date: newTime)
        XCTAssertEqual(sessionRecipe.timeOfLastAction, newTime)
    }

    func testCompleted() {
        let sessionRecipe = SessionRecipe(recipe: RecipeTests.generateSampleRecipe())
        sessionRecipe.sessionSteps.forEach { $0.toggleCompleted() }
        XCTAssertTrue(sessionRecipe.isCompleted)

    }

}
