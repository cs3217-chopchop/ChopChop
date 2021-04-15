// swiftlint:disable line_length

import XCTest
@testable import ChopChop

class RecipeTests: XCTestCase {

    static func generateSteps() -> [RecipeStep] {
        do {
            return [
                try RecipeStep("In a large bowl, mix dry ingredients together until well-blended."),
                try RecipeStep("Add milk and mix well until smooth.") ,
                try RecipeStep("""
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix \
                well.
                """) ,
                try RecipeStep("Beat whites until stiff and then fold into batter gently") ,
                try RecipeStep("Pour ladles of the mixture into a non-stick pan, one at a time."),
                try RecipeStep("""
                Cook for 30s until the edges are dry and bubbles appear on surface. Flip; cook for 1 to 2 minutes. \
                Yields 12 to 14 pancakes.
                """)
            ]
        } catch {
            XCTFail("Could not generate sample recipe steps")
            return []
        }
    }

    static func generateIngredients() -> [RecipeIngredient] {
        do {
            return [
                try RecipeIngredient(name: "Flour", quantity: try Quantity(from: .mass(120, unit: .gram))),
                try RecipeIngredient(name: "Baking Powder",
                                     quantity: try Quantity(from: .volume(7.5, unit: .milliliter))),
                try RecipeIngredient(name: "Salt", quantity: try Quantity(from: .volume(0.312_5, unit: .milliliter))),
                try RecipeIngredient(name: "Milk", quantity: try Quantity(from: .volume(250, unit: .milliliter))),
                try RecipeIngredient(name: "Egg", quantity: try Quantity(from: .count(1))),
                try RecipeIngredient(name: "Sugar", quantity: try Quantity(from: .volume(1, unit: .tablespoon)))
            ]
        } catch {
            XCTFail("Could not generate sample ingredients")
            return []
        }
    }

    static func generateGraph(steps: [RecipeStep]) -> RecipeStepGraph {
        do {
            let nodes: [RecipeStepNode] = steps.map { RecipeStepNode($0) }
            var edges: [Edge<RecipeStepNode>] = []

            for index in nodes.indices.dropLast() {
                guard let edge = Edge(source: nodes[index], destination: nodes[index + 1]) else {
                    continue
                }

                edges.append(edge)
            }

            return try RecipeStepGraph(nodes: nodes, edges: edges)
        } catch {
            fatalError("Could not generate sample graph")
        }
    }

    static func generateSampleRecipe() -> Recipe {
        do {
            let steps = RecipeTests.generateSteps()
            let graph = RecipeTests.generateGraph(steps: steps)

            return try Recipe(name: "Pancakes",
                              servings: 3,
                              difficulty: Difficulty.easy,
                              ingredients: RecipeTests.generateIngredients(),
                              stepGraph: graph)
        } catch {
            fatalError("Could not generate sample recipe")
        }
    }

    func testConstruct() throws {
        let steps = RecipeTests.generateSteps()
        let graph = RecipeTests.generateGraph(steps: steps)
        let recipe = try Recipe(name: "Pancakes",
                                ingredients: RecipeTests.generateIngredients(),
                                stepGraph: graph)

        XCTAssertEqual(recipe.name, "Pancakes")
        XCTAssertEqual(recipe.servings, 1)
        XCTAssertNil(recipe.difficulty)
        XCTAssertEqual(recipe.ingredients, RecipeTests.generateIngredients())
        XCTAssertEqual(recipe.stepGraph, graph)
    }

    func testConstruct_fail() throws {
        XCTAssertThrowsError(try Recipe(name: ""))
        XCTAssertThrowsError(try Recipe(name: "Recipe", servings: -2))
    }
}
