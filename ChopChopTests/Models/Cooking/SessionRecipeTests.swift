import XCTest
@testable import ChopChop

class SessionRecipeTests: XCTestCase {

    func testConstruct() throws {
        let recipe = try Recipe(name: "Pancakes")
        let sessionRecipe = SessionRecipe(recipe: recipe)
        XCTAssertEqual(sessionRecipe.recipe, recipe)
        XCTAssertTrue(sessionRecipe.stepGraph.nodes.isEmpty)
        XCTAssertTrue(sessionRecipe.recipe === recipe)

        let recipe2 = RecipeTests.generateSampleRecipe()
        let sessionRecipe2 = SessionRecipe(recipe: recipe2)
        XCTAssertEqual(sessionRecipe2.recipe, recipe2)
        XCTAssertEqual(Set(sessionRecipe2.stepGraph.nodes.map { $0.label.step }),
                       Set(recipe2.stepGraph.nodes.map { $0.label }))
    }

}
