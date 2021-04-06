// swiftlint:disable line_length

import XCTest
@testable import ChopChop

class RecipeTests: XCTestCase {
    static func generateStepGraph() -> RecipeStepGraph {
        do {
            let nodes = [
                try RecipeStep(content: "In a large bowl, mix dry ingredients together until well-blended."),
                try RecipeStep(content: "Add milk and mix well until smooth.") ,
                try RecipeStep(content: """
                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix \
                well.
                """) ,
                try RecipeStep(content: "Beat whites until stiff and then fold into batter gently") ,
                try RecipeStep(content: "Pour ladles of the mixture into a non-stick pan, one at a time."),
                try RecipeStep(content: """
                Cook for 30s until the edges are dry and bubbles appear on surface. Flip; cook for 1 to 2 minutes. \
                Yields 12 to 14 pancakes.
                """)
            ].map { RecipeStepNode($0) }

            let edges = (0..<(nodes.count - 1)).compactMap {
                Edge(source: nodes[$0], destination: nodes[$0 + 1])
            }

            return try RecipeStepGraph(nodes: nodes, edges: edges)
        } catch {
            XCTFail("Could not generate sample recipe steps")
            return RecipeStepGraph()
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

    static func generateSampleRecipe() -> Recipe {
        do {
            return try Recipe(name: "Pancakes", servings: 3, difficulty: Difficulty.easy,
                              ingredients: RecipeTests.generateIngredients(), graph: RecipeTests.generateStepGraph())
        } catch {
            fatalError("Could not generate sample recipe")
        }
    }

    func testConstruct() throws {
        let graph = RecipeTests.generateStepGraph()
        let recipe = try Recipe(name: "Pancakes",
                                ingredients: RecipeTests.generateIngredients(),
                                graph: graph)

        XCTAssertEqual(recipe.name, "Pancakes")
        XCTAssertEqual(recipe.servings, 1)
        XCTAssertNil(recipe.difficulty)
        XCTAssertEqual(recipe.stepGraph, graph)
        XCTAssertEqual(recipe.ingredients, RecipeTests.generateIngredients())
    }

    func testConstruct_fail() throws {
        XCTAssertThrowsError(try Recipe(name: ""))
        XCTAssertThrowsError(try Recipe(name: "Recipe", servings: -2))
    }

    func testUpdateRecipe() throws {
        let newRecipe = RecipeTests.generateSampleRecipe()
        let recipeToUpdate = try Recipe(
            name: "Pizza",
            servings: 4,
            difficulty: Difficulty.hard,
            ingredients: RecipeTests.generateIngredients(),
            graph: RecipeTests.generateStepGraph()
        )
        newRecipe.updateRecipe(recipeToUpdate)
        XCTAssertEqual(newRecipe.name, recipeToUpdate.name)
        XCTAssertEqual(newRecipe.servings, recipeToUpdate.servings)
        XCTAssertEqual(newRecipe.difficulty, recipeToUpdate.difficulty)
        XCTAssertEqual(newRecipe.recipeCategoryId, newRecipe.recipeCategoryId)
        XCTAssertEqual(newRecipe.stepGraph, recipeToUpdate.stepGraph)
        XCTAssertEqual(newRecipe.ingredients, recipeToUpdate.ingredients)
    }

    func testAddIngredient_existingIngredient() throws {
        let recipe = RecipeTests.generateSampleRecipe()
        try recipe.addIngredient(name: "Flour", quantity: try Quantity(from: .mass(120, unit: .gram)))
        let updatedIngredient = try RecipeIngredient(name: "Flour", quantity: try Quantity(from: .mass(240, unit: .gram)))
        XCTAssertTrue(recipe.ingredients.contains(updatedIngredient))
        XCTAssertEqual(recipe.ingredients.filter { $0.name == "Flour" }.count, 1)
    }

    func testAddIngredient_new() throws {
        let recipe = RecipeTests.generateSampleRecipe()
        try recipe.addIngredient(name: "CauliFlour", quantity: try Quantity(from: .mass(120, unit: .gram)))
        let newIngredient = try RecipeIngredient(name: "CauliFlour", quantity: try Quantity(from: .mass(120, unit: .gram)))
        XCTAssertTrue(recipe.ingredients.contains(newIngredient))
    }

    func testRemoveIngredient() throws {
        let recipe = RecipeTests.generateSampleRecipe()
        guard let firstIngredient = recipe.ingredients.first else {
            XCTFail("There are no ingredients")
            return
        }
        try recipe.removeIngredient(firstIngredient)
        XCTAssertFalse(recipe.ingredients.contains(firstIngredient))
    }

    func testRemoveIngredient_nonExistentIngredient() throws {
        let recipe = RecipeTests.generateSampleRecipe()
        let nonExistentIngredient = try RecipeIngredient(name: "CauliFlour", quantity: try Quantity(from: .mass(120, unit: .gram)))
        XCTAssertThrowsError(try recipe.removeIngredient(nonExistentIngredient))
    }

    func testUpdateIngredient_changeName() throws {
        let recipe = RecipeTests.generateSampleRecipe()
        guard let firstIngredient = recipe.ingredients.first else {
            XCTFail("There are no ingredients")
            return
        }
        try recipe.updateIngredient(oldIngredient: firstIngredient, name: "All-Purpose Flour",
                                    quantity: try Quantity(from: .mass(120, unit: .gram)))

        let updatedIngredient = try RecipeIngredient(name: "All-Purpose Flour",
                                                     quantity: try Quantity(from: .mass(120, unit: .gram)))
        XCTAssertTrue(recipe.ingredients.contains(updatedIngredient))
        XCTAssertFalse(recipe.ingredients.contains { $0.name == "Flour" })
    }

    func testUpdateIngredient_changeNameToAnotherIngredient() throws {
        let recipe = RecipeTests.generateSampleRecipe()
        guard let firstIngredient = recipe.ingredients.first else {
            XCTFail("There are no ingredients")
            return
        }
        try recipe.updateIngredient(oldIngredient: firstIngredient, name: "Baking Powder", quantity: try Quantity(from: .volume(7.5, unit: .milliliter)))

        let updatedIngredient = try RecipeIngredient(name: "Baking Powder", quantity: try Quantity(from: .volume(15, unit: .milliliter)))
        XCTAssertTrue(recipe.ingredients.contains(updatedIngredient))
    }

    func testUpdateIngredient_changeQuantity() throws {
        let recipe = RecipeTests.generateSampleRecipe()
        guard let firstIngredient = recipe.ingredients.first else {
            XCTFail("There are no ingredients")
            return
        }
        try recipe.updateIngredient(oldIngredient: firstIngredient, name: "All-Purpose Flour",
                                    quantity: try Quantity(from: .mass(120, unit: .gram)))

        let updatedIngredient = try RecipeIngredient(name: "All-Purpose Flour",
                                                     quantity: try Quantity(from: .mass(120, unit: .gram)))
        XCTAssertTrue(recipe.ingredients.contains(updatedIngredient))
        XCTAssertFalse(recipe.ingredients.contains { $0.name == "Flour" })
    }

    func testUpdateIngredient_nonExistent() throws {
        let recipe = RecipeTests.generateSampleRecipe()
        let newIngredient = try RecipeIngredient(name: "CauliFlour", quantity: try Quantity(from: .mass(120, unit: .gram)))
        XCTAssertThrowsError(try recipe.updateIngredient(oldIngredient: newIngredient,
                                                         name: "CauliFlour", quantity: try Quantity(from: .mass(240, unit: .gram))))

    }
}
