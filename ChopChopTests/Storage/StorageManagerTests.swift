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
        storageManager = StorageManager(appDatabase)
    }

    func testSaveRecipe() throws {
        var recipe = try Recipe(name: "Pancakes",
                                steps: [
                                    try RecipeStep(content: """
                                        In a large bowl, mix dry ingredients together until well-blended.
                                        """),
                                    try RecipeStep(content: "Add milk and mix well until smooth.") ,
                                    try RecipeStep(content: """
                                        Separate the egg, placing the whites in a medium bowl and the yolks in the \
                                        batter. Mix well.
                                        """) ,
                                    try RecipeStep(content: """
                                        Beat whites until stiff and then fold into batter gently.
                                        """) ,
                                    try RecipeStep(content: """
                                        Pour ladles of the mixture into a non-stick pan, one at a time.
                                        """),
                                    try RecipeStep(content: """
                                        Cook until the edges are dry and bubbles appear on surface. Flip; cook until \
                                        golden. Yields 12 to 14 pancakes.
                                        """)
                                ],
                                ingredients: [
                                    try RecipeIngredient(name: "Flour", quantity: try Quantity(from: .mass(120, unit: .gram))),
                                    try RecipeIngredient(name: "Baking Powder",
                                                         quantity: try Quantity(from: .volume(7.5, unit: .milliliter))),
                                    try RecipeIngredient(name: "Salt", quantity: try Quantity(from: .volume(0.312_5, unit: .milliliter))),
                                    try RecipeIngredient(name: "Milk", quantity: try Quantity(from: .volume(250, unit: .milliliter))),
                                    try RecipeIngredient(name: "Egg", quantity: try Quantity(from: .count(1))),
                                    try RecipeIngredient(name: "Sugar", quantity: try Quantity(from: .volume(1, unit: .tablespoon)))
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

        let imageName = "Apple"
        XCTAssertNoThrow(try storageManager.saveIngredientImage(image, name: imageName))
        let persistedImage = storageManager.fetchIngredientImage(name: imageName)
        XCTAssertNotNil(persistedImage)
        XCTAssertEqual(persistedImage?.pngData(), image.pngData())

        storageManager.deleteIngredientImage(name: imageName)
        XCTAssertNil(storageManager.fetchIngredientImage(name: imageName))
    }

    func testRenameIngredientImage() {
        let image = UIImage(imageLiteralResourceName: "apples")

        let oldName = "Apple"
        XCTAssertNoThrow(try storageManager.saveIngredientImage(image, name: oldName))

        let newName = "Apples"
        XCTAssertNoThrow(try storageManager.renameIngredientImage(from: oldName, to: newName))
        XCTAssertNil(storageManager.fetchIngredientImage(name: oldName))

        let renamedImage = storageManager.fetchIngredientImage(name: newName)
        XCTAssertNotNil(renamedImage)
        XCTAssertEqual(renamedImage?.pngData(), image.pngData())

        storageManager.deleteIngredientImage(name: newName)
        XCTAssertNil(storageManager.fetchIngredientImage(name: newName))
    }

    func testOverwriteExistingIngredientImage() {
        let existingImage = UIImage(imageLiteralResourceName: "apples")
        let newImage = UIImage(imageLiteralResourceName: "oranges")

        let imageName = "Fruit"
        XCTAssertNoThrow(try storageManager.saveIngredientImage(existingImage, name: imageName))

        XCTAssertNoThrow(try storageManager.saveIngredientImage(newImage, name: imageName))
        let persistedImage = storageManager.fetchIngredientImage(name: imageName)
        XCTAssertNotNil(persistedImage)
        XCTAssertNotEqual(persistedImage?.pngData(), existingImage.pngData())
        XCTAssertEqual(persistedImage?.pngData(), newImage.pngData())

        storageManager.deleteIngredientImage(name: imageName)
        XCTAssertNil(storageManager.fetchIngredientImage(name: imageName))
    }

    func testRecipeImagePersistence() {
        let image = UIImage(imageLiteralResourceName: "apple-pie")

        let imageName = "Apple Pie"
        XCTAssertNoThrow(try storageManager.saveRecipeImage(image, name: imageName))
        let persistedImage = storageManager.fetchRecipeImage(name: imageName)
        XCTAssertNotNil(persistedImage)
        XCTAssertEqual(persistedImage?.pngData(), image.pngData())

        storageManager.deleteRecipeImage(name: imageName)
        XCTAssertNil(storageManager.fetchRecipeImage(name: imageName))
    }

    func testRenameRecipeImage() {
        let image = UIImage(imageLiteralResourceName: "apple-pie")

        let oldName = "Apple Pie"
        XCTAssertNoThrow(try storageManager.saveRecipeImage(image, name: oldName))

        let newName = "Delicious Apple Pie"
        XCTAssertNoThrow(try storageManager.renameRecipeImage(from: oldName, to: newName))
        XCTAssertNil(storageManager.fetchRecipeImage(name: oldName))

        let renamedImage = storageManager.fetchRecipeImage(name: newName)
        XCTAssertNotNil(renamedImage)
        XCTAssertEqual(renamedImage?.pngData(), image.pngData())

        storageManager.deleteRecipeImage(name: newName)
        XCTAssertNil(storageManager.fetchRecipeImage(name: newName))
    }

    func testOverwriteExistingRecipeImage() {
        let existingImage = UIImage(imageLiteralResourceName: "apple-pie")
        let newImage = UIImage(imageLiteralResourceName: "apple-pie-slice")

        let imageName = "Apple Pie"
        XCTAssertNoThrow(try storageManager.saveRecipeImage(existingImage, name: imageName))

        XCTAssertNoThrow(try storageManager.saveRecipeImage(newImage, name: imageName))
        let persistedImage = storageManager.fetchRecipeImage(name: imageName)
        XCTAssertNotNil(persistedImage)
        XCTAssertNotEqual(persistedImage?.pngData(), existingImage.pngData())
        XCTAssertEqual(persistedImage?.pngData(), newImage.pngData())

        storageManager.deleteRecipeImage(name: imageName)
        XCTAssertNil(storageManager.fetchRecipeImage(name: imageName))
    }
}
