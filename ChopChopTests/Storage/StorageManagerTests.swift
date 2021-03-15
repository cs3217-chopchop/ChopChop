import XCTest
import GRDB
@testable import ChopChop

class StorageManagerTests: XCTestCase {
    var storageManager: StorageManager!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let dbWriter = DatabaseQueue()
        let appDatabase = try AppDatabase(dbWriter)
        storageManager = StorageManager(appDatabase)
    }

    func testSaveRecipe() throws {
        var recipe = Recipe(name: "Pancakes",
                            ingredients: [
                                "Flour": .mass(0.120),
                                "Baking Powder": .volume(0.007_5),
                                "Salt": .volume(0.000_312_5),
                                "Milk": .volume(0.250),
                                "Egg": .count(1),
                                "Sugar": .volume(0.015)
                            ],
                            steps: [
                                "In a large bowl, mix dry ingredients together until well-blended.",
                                "Add milk and mix well until smooth.",
                                """
                                Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix \
                                well.
                                """,
                                "Beat whites until stiff and then fold into batter gently",
                                "Pour ladles of the mixture into a non-stick pan, one at a time.",
                                """
                                Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. \
                                Yields 12 to 14 pancakes.
                                """
                            ])

        try storageManager.saveRecipe(&recipe)

        guard let id = recipe.id else {
            XCTFail("Recipes should have a non-nil ID after saving")
            return
        }

        let fetchedRecipe = try storageManager.fetchRecipe(id: id)

        XCTAssertEqual(recipe, fetchedRecipe)
    }

    func testSaveIngredient() throws {
        var ingredient = try Ingredient(name: "Egg",
                                        batches: [
                                            IngredientBatch(
                                                quantity: .count(12),
                                                expiryDate: Calendar.current.startOfDay(for: Date())),
                                            IngredientBatch(
                                                quantity: .count(13),
                                                expiryDate: Calendar.current
                                                    .startOfDay(for: Date(timeIntervalSinceNow: 60 * 60 * 24))),
                                            IngredientBatch(quantity: .count(14), expiryDate: nil)
                                        ])

        try storageManager.saveIngredient(&ingredient)

        guard let id = ingredient.id else {
            XCTFail("Ingredients should have a non-nil ID after saving")
            return
        }

        let fetchedIngredient = try storageManager.fetchIngredient(id: id)

        XCTAssertEqual(ingredient, fetchedIngredient)
    }
}
