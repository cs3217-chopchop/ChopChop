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
        var recipe = try Recipe(name: "Pancakes",
                                steps: [
                                    try RecipeStep(content: "In a large bowl, mix dry ingredients together until well-blended."),
                                    try RecipeStep(content: "Add milk and mix well until smooth.") ,
                                    try RecipeStep(content: """
                                    Separate the egg, placing the whites in a medium bowl and the yolks in the batter. Mix \
                                    well.
                                    """) ,
                                    try RecipeStep(content: "Beat whites until stiff and then fold into batter gently") ,
                                    try RecipeStep(content: "Pour ladles of the mixture into a non-stick pan, one at a time."),
                                    try RecipeStep(content: """
                                    Cook until the edges are dry and bubbles appear on surface. Flip; cook until golden. \
                                    Yields 12 to 14 pancakes.
                                    """)
                                ],
                                ingredients: [
                                    try RecipeIngredient(name: "Flour", quantity: try Quantity(from: .mass(0.120))),
                                    try RecipeIngredient(name: "Baking Powder",
                                                         quantity: try Quantity(from: .volume(0.007_5))),
                                    try RecipeIngredient(name: "Salt", quantity: try Quantity(from: .volume(0.000_312_5))),
                                    try RecipeIngredient(name: "Milk", quantity: try Quantity(from: .volume(0.250))),
                                    try RecipeIngredient(name: "Egg", quantity: try Quantity(from: .count(1))),
                                    try RecipeIngredient(name: "Sugar", quantity: try Quantity(from: .volume(0.015)))
                                ]
                            )

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
                                                quantity: try Quantity(from: .count(12)),
                                                expiryDate: Calendar.current.startOfDay(for: Date())),
                                            IngredientBatch(
                                                quantity: try Quantity(from: .count(13)),
                                                expiryDate: Calendar.current
                                                    .startOfDay(for: Date(timeIntervalSinceNow: 60 * 60 * 24))),
                                            IngredientBatch(quantity: try Quantity(from: .count(14)), expiryDate: nil)
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
