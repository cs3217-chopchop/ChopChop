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

// MARK: - Image Persistence
extension StorageManagerTests {
    func testIngredientImagePersistence() {
        guard let image = UIImage(named: "apples") else {
            XCTFail("Image asset not found")
            return
        }

        let imageName = "Apple"
        XCTAssertNoThrow(try storageManager.saveIngredientImage(image, name: imageName))
        let persistedImage = storageManager.fetchIngredientImage(name: imageName)
        XCTAssertNotNil(persistedImage)
        XCTAssertEqual(persistedImage?.pngData(), image.pngData())

        storageManager.deleteIngredientImage(name: imageName)
        XCTAssertNil(storageManager.fetchIngredientImage(name: imageName))
    }

    func testRenameIngredientImage() {
        guard let image = UIImage(named: "apples") else {
            XCTFail("Image asset not found")
            return
        }

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
        guard let existingImage = UIImage(named: "apples") else {
            XCTFail("Image asset not found")
            return
        }

        guard let newImage = UIImage(named: "oranges") else {
            XCTFail("Image asset not found")
            return
        }

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
        guard let image = UIImage(named: "apple-pie") else {
            XCTFail("Image asset not found")
            return
        }

        let imageName = "Apple Pie"
        XCTAssertNoThrow(try storageManager.saveRecipeImage(image, name: imageName))
        let persistedImage = storageManager.fetchRecipeImage(name: imageName)
        XCTAssertNotNil(persistedImage)
        XCTAssertEqual(persistedImage?.pngData(), image.pngData())

        storageManager.deleteRecipeImage(name: imageName)
        XCTAssertNil(storageManager.fetchRecipeImage(name: imageName))
    }

    func testRenameRecipeImage() {
        guard let image = UIImage(named: "apple-pie") else {
            XCTFail("Image asset not found")
            return
        }

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
        guard let existingImage = UIImage(named: "apple-pie") else {
            XCTFail("Image asset not found")
            return
        }

        guard let newImage = UIImage(named: "apple-pie-slice") else {
            XCTFail("Image asset not found")
            return
        }

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
