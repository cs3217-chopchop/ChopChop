// swiftlint:disable line_length

import XCTest
@testable import ChopChop

class OnlineRecipeTest: XCTestCase {

    func testConstruct() throws {
        let onlineRecipe = try OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 2, difficulty: Difficulty.easy, cuisine: nil, steps: [], stepGraph: RecipeStepGraph(), ingredients: [], ratings: [], created: Date())

        XCTAssertEqual(onlineRecipe.id, "1")
        XCTAssertEqual(onlineRecipe.userId, "1")
        XCTAssertEqual(onlineRecipe.name, "Pancakes")
        XCTAssertEqual(onlineRecipe.servings, 2)
        XCTAssertEqual(onlineRecipe.difficulty, Difficulty.easy)
        XCTAssertNil(onlineRecipe.cuisine)
        XCTAssertTrue(onlineRecipe.steps.isEmpty)
        XCTAssertEqual(onlineRecipe.stepGraph, RecipeStepGraph())
        XCTAssertTrue(onlineRecipe.ingredients.isEmpty)
        XCTAssertTrue(onlineRecipe.ratings.isEmpty)
    }

    func testConstruct_fail() throws {
        XCTAssertThrowsError(try OnlineRecipe(id: "1", userId: "1", name: "        ", servings: 2, difficulty: nil, cuisine: nil, steps: [], stepGraph: RecipeStepGraph(), ingredients: [], ratings: [], created: Date()))

        XCTAssertThrowsError(try OnlineRecipe(id: "1", userId: "1", name: "Pancakes", servings: 0, difficulty: nil, cuisine: nil, steps: [], stepGraph: RecipeStepGraph(), ingredients: [], ratings: [], created: Date()))
    }

    func testConstruct_fromRecord() throws {
        let onlineRecipe = try OnlineRecipe(from: OnlineRecipeRecord(id: "1", name: "Pancakes", creator: "1", servings: 2, ingredients: [OnlineIngredientRecord(name: "Butter", quantity: .count(2))], steps: ["Cook the pancakes", "Make the pancakes"], stepEdges: [OnlineStepEdgeRecord(sourceStep: "Cook the pancakes", destinationStep: "Make the pancakes")], created: Date()))

        XCTAssertEqual(onlineRecipe.name, "Pancakes")
        XCTAssertEqual(onlineRecipe.servings, 2)
        XCTAssertEqual(onlineRecipe.ingredients, [try RecipeIngredient(name: "Butter", quantity: Quantity(.count, value: 2))])
        XCTAssertEqual(onlineRecipe.steps, ["Cook the pancakes", "Make the pancakes"])

        let node1 = RecipeStepNode(try RecipeStep(content: "Cook the pancakes"))
        let node2 = RecipeStepNode(try RecipeStep(content: "Make the pancakes"))
        let edges = [Edge(source: node1, destination: node2)].compactMap { $0 }
        XCTAssertEqual(onlineRecipe.stepGraph, try RecipeStepGraph(nodes: [node1, node2], edges: edges))
    }

}
