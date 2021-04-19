// swiftlint:disable line_length

import XCTest
import GRDB
import UIKit

@testable import ChopChop

class StorageManagerTests: XCTestCase {
    var storageManager: StorageManager!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let dbWriter = DatabaseQueue()
        let appDatabase = try AppDatabase(dbWriter)
        storageManager = StorageManager(appDatabase: appDatabase)
    }

    func testSaveRecipe() throws {
        let nodes = [
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
        ].map { RecipeStepNode($0) }

        let edges = (0..<(nodes.count - 1)).compactMap {
            Edge(source: nodes[$0], destination: nodes[$0 + 1])
        }

        var recipe = try Recipe(name: "Pancakes",
                                ingredients: [
                                    try RecipeIngredient(name: "Flour", quantity: try Quantity(from: .mass(120, unit: .gram))),
                                    try RecipeIngredient(name: "Baking Powder",
                                                         quantity: try Quantity(from: .volume(7.5, unit: .milliliter))),
                                    try RecipeIngredient(name: "Salt", quantity: try Quantity(from: .volume(0.312_5, unit: .milliliter))),
                                    try RecipeIngredient(name: "Milk", quantity: try Quantity(from: .volume(250, unit: .milliliter))),
                                    try RecipeIngredient(name: "Egg", quantity: try Quantity(from: .count(1))),
                                    try RecipeIngredient(name: "Sugar", quantity: try Quantity(from: .volume(1, unit: .tablespoon)))
                                ],
                                stepGraph: try RecipeStepGraph(nodes: nodes, edges: edges)
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
                                        type: .count,
                                        batches: [
                                            IngredientBatch(quantity: try Quantity(from: .count(12)),
                                                            expiryDate: .today),
                                            IngredientBatch(quantity: try Quantity(from: .count(13)),
                                                            expiryDate: Date(timeIntervalSinceNow: 60 * 60 * 24)
                                                                .startOfDay),
                                            IngredientBatch(quantity: try Quantity(from: .count(14)))
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

// MARK: - Image Persistence
extension StorageManagerTests {
    func testIngredientImagePersistence() {
        let image = UIImage(imageLiteralResourceName: "apples")

        let imageName = "1"
        XCTAssertNoThrow(try storageManager.saveIngredientImage(image, name: imageName))
        let persistedImage = storageManager.fetchIngredientImage(name: imageName)
        XCTAssertNotNil(persistedImage)
        XCTAssertEqual(persistedImage?.pngData(), image.pngData())

        storageManager.deleteIngredientImage(name: imageName)
        XCTAssertNil(storageManager.fetchIngredientImage(name: imageName))
    }

    func testOverwriteExistingIngredientImage() {
        let existingImage = UIImage(imageLiteralResourceName: "apples")
        let newImage = UIImage(imageLiteralResourceName: "oranges")

        let imageName = "1"
        XCTAssertNoThrow(try storageManager.saveIngredientImage(existingImage, name: imageName))

        XCTAssertNoThrow(try storageManager.saveIngredientImage(newImage, name: imageName))
        let persistedImage = storageManager.fetchIngredientImage(name: imageName)
        XCTAssertNotNil(persistedImage)
        XCTAssertNotEqual(persistedImage?.pngData(), existingImage.pngData())
        XCTAssertEqual(persistedImage?.pngData(), newImage.pngData())

        storageManager.deleteIngredientImage(name: imageName)
        XCTAssertNil(storageManager.fetchIngredientImage(name: imageName))
    }

    func testRecipeImagePersistence() throws {
        let image = UIImage(imageLiteralResourceName: "apple-pie")

        let imageName = "1"
        XCTAssertNoThrow(try storageManager.saveRecipeImage(image, id: 1, name: imageName))
        let persistedImage = storageManager.fetchRecipeImage(name: imageName)
        XCTAssertNotNil(persistedImage)
        XCTAssertEqual(persistedImage?.pngData(), image.pngData())

        try storageManager.deleteRecipeImage(name: imageName, id: 1)
        XCTAssertNil(storageManager.fetchRecipeImage(name: imageName))
    }

    func testOverwriteExistingRecipeImage() throws {
        let existingImage = UIImage(imageLiteralResourceName: "apple-pie")
        let newImage = UIImage(imageLiteralResourceName: "apple-pie-slice")

        let imageName = "1"
        XCTAssertNoThrow(try storageManager.saveRecipeImage(existingImage, id: 1, name: imageName))

        XCTAssertNoThrow(try storageManager.saveRecipeImage(newImage, id: 1, name: imageName))
        let persistedImage = storageManager.fetchRecipeImage(name: imageName)
        XCTAssertNotNil(persistedImage)
        XCTAssertNotEqual(persistedImage?.pngData(), existingImage.pngData())
        XCTAssertEqual(persistedImage?.pngData(), newImage.pngData())

        try storageManager.deleteRecipeImage(name: imageName, id: 1)
        XCTAssertNil(storageManager.fetchRecipeImage(name: imageName))
    }
}
