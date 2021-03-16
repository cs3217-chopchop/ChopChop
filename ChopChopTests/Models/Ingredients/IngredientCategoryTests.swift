import XCTest

@testable import ChopChop

class IngredientCategoryTests: XCTestCase {
    static let categoryName = "Dairy"
    static let categoryId: Int64 = 3_217
    var category: IngredientCategory!

    override func setUpWithError() throws {
        try super.setUpWithError()

        category = IngredientCategory(
            name: IngredientCategoryTests.categoryName,
            id: IngredientCategoryTests.categoryId)
    }

    override func tearDownWithError() throws {
        category = nil

        try super.tearDownWithError()
    }
}

extension IngredientCategoryTests {
    func testConstruct_ingredients_setIngredientCategoryId() throws {
        let ingredientName = "Cheese"
        let quantityType: QuantityType = .mass
        let ingredient = try Ingredient(name: ingredientName, type: quantityType)

        category = IngredientCategory(
            name: IngredientCategoryTests.categoryName,
            id: IngredientCategoryTests.categoryId,
            ingredients: [ingredient])

        XCTAssertEqual(ingredient.ingredientCategoryId, IngredientCategoryTests.categoryId,
                       "Category ID of contained ingredient should be set correctly")
    }
}

// MARK: - Add
extension IngredientCategoryTests {
    func testAdd_newIngredient_success() throws {
        let ingredientName = "Cheese"
        let quantityType: QuantityType = .mass
        let ingredient = try Ingredient(name: ingredientName, type: quantityType)

        category.add(ingredient)

        let addedIngredient = try? XCTUnwrap(category.getIngredient(name: ingredientName, type: quantityType),
                                             "Ingredient should be added")

        XCTAssertEqual(addedIngredient, ingredient)
        XCTAssertEqual(addedIngredient?.ingredientCategoryId, IngredientCategoryTests.categoryId,
                       "Category ID of added ingredient should be set correctly")
    }

    func testAdd_existingIngredient_ingredientCombined() throws {
        let name = "Cheese"
        let quantityType: QuantityType = .mass
        let existingDate = Date(timeInterval: -1_000, since: .testDate)
        let commonDate: Date = .testDate
        let existingIngredient = try Ingredient(
            name: name,
            type: quantityType,
            batches: [
                IngredientBatch(quantity: .mass(1)),
                IngredientBatch(quantity: .mass(0.3), expiryDate: commonDate),
                IngredientBatch(quantity: .mass(0.5), expiryDate: existingDate)
            ])

        category.add(existingIngredient)

        let newDate = Date(timeInterval: 1_000, since: .testDate)
        let addedIngredient = try Ingredient(
            name: name,
            type: quantityType,
            batches: [
                IngredientBatch(quantity: .mass(2)),
                IngredientBatch(quantity: .mass(0.4), expiryDate: commonDate),
                IngredientBatch(quantity: .mass(0.5), expiryDate: newDate)
            ])

        category.add(addedIngredient)

        let combinedIngredient = try XCTUnwrap(category.getIngredient(name: name, type: quantityType),
                                               "Ingredient should be in category")

        let notExpiringBatch = combinedIngredient.getBatch(expiryDate: nil)
        XCTAssertEqual(notExpiringBatch?.quantity, .mass(1 + 2),
                       "Quantity should be combined correctly")

        let commonBatch = combinedIngredient.getBatch(expiryDate: commonDate)
        XCTAssertEqual(commonBatch?.quantity, .mass(0.3 + 0.4),
                       "Quantity should be combined correctly")

        XCTAssertNotNil(combinedIngredient.getBatch(expiryDate: existingDate),
                        "Existing batch should be in ingredient")
        XCTAssertNotNil(combinedIngredient.getBatch(expiryDate: newDate),
                        "New batch should be appended to ingredient")

        XCTAssertEqual(category.ingredients.count, 1,
                       "Ingredient should not be appended")
    }

    func testAdd_existingIngredientDifferentQuantityType_ingredientAppended() throws {
        let name = "Cheese"
        let ingredient = try Ingredient(
            name: name,
            type: .mass,
            batches: [
                IngredientBatch(quantity: .mass(1))
            ])

        category.add(ingredient)

        let addedIngredient = try Ingredient(
            name: name,
            type: .count,
            batches: [
                IngredientBatch(quantity: .count(1))
            ])

        category.add(addedIngredient)

        let existingIngredient = try XCTUnwrap(category.getIngredient(name: name, type: .mass),
                                               "Ingredient should not be combined")
        let appendedIngredient = try XCTUnwrap(category.getIngredient(name: name, type: .count),
                                               "Ingredient should not be combined")

        XCTAssertEqual(existingIngredient.getBatch(expiryDate: nil), IngredientBatch(quantity: .mass(1)),
                       "Ingredient should not be combined")
        XCTAssertEqual(appendedIngredient.getBatch(expiryDate: nil), IngredientBatch(quantity: .count(1)),
                       "Ingredient should not be combined")

        XCTAssertEqual(appendedIngredient.ingredientCategoryId, IngredientCategoryTests.categoryId,
                       "Category ID of added ingredient should be set correctly")
    }
}

// MARK: - Remove
extension IngredientCategoryTests {
    func testRemove_existingIngredient_success() throws {
        let ingredientName = "Cheese"
        let quantityType: QuantityType = .mass
        let ingredient = try Ingredient(name: ingredientName, type: quantityType)

        category = IngredientCategory(
            name: IngredientCategoryTests.categoryName,
            id: IngredientCategoryTests.categoryId,
            ingredients: [ingredient])

        category.remove(ingredient)

        XCTAssertNil(category.getIngredient(name: ingredientName, type: quantityType),
                     "Ingredient should be removed")
    }

    func testRemove_nonExistingIngredient_doNothing() throws {
        let ingredientName = "Cheese"
        let quantityType: QuantityType = .mass
        let ingredient = try Ingredient(name: ingredientName, type: quantityType)

        category = IngredientCategory(
            name: IngredientCategoryTests.categoryName,
            id: IngredientCategoryTests.categoryId,
            ingredients: [ingredient])

        let removedIngredient = try Ingredient(name: "Milk", type: .volume)
        category.remove(removedIngredient)

        XCTAssertNotNil(category.getIngredient(name: ingredientName, type: quantityType),
                        "Existing ingredient should not be removed")
    }

    func testRemove_existingIngredientDifferentQuantityType_doNothing() throws {
        let ingredientName = "Cheese"
        let quantityType: QuantityType = .mass
        let ingredient = try Ingredient(name: ingredientName, type: quantityType)

        category = IngredientCategory(
            name: IngredientCategoryTests.categoryName,
            id: IngredientCategoryTests.categoryId,
            ingredients: [ingredient])

        let removedIngredient = try Ingredient(name: ingredientName, type: .count)
        category.remove(removedIngredient)

        XCTAssertNotNil(category.getIngredient(name: ingredientName, type: quantityType),
                        "Existing ingredient with different type should not be removed")

    }
}

// MARK: - Get ingredient
extension IngredientCategoryTests {
    func testGetIngredient_existingIngredient_success() throws {
        let ingredientName = "Cheese"
        let quantityType: QuantityType = .mass
        let ingredient = try Ingredient(
            name: ingredientName,
            type: quantityType,
            batches: [IngredientBatch(quantity: .mass(0.5))])

        category = IngredientCategory(
            name: IngredientCategoryTests.categoryName,
            id: IngredientCategoryTests.categoryId,
            ingredients: [ingredient])

        let retrievedIngredient = try XCTUnwrap(category.getIngredient(name: ingredientName, type: quantityType))

        XCTAssertEqual(retrievedIngredient, ingredient)
        XCTAssertEqual(retrievedIngredient.getBatch(expiryDate: nil), IngredientBatch(quantity: .mass(0.5)))
    }

    func testGetIngredient_nonExistingIngredient_returnsNil() throws {
        let ingredientName = "Cheese"
        let quantityType: QuantityType = .mass
        let ingredient = try Ingredient(
            name: ingredientName,
            type: quantityType,
            batches: [IngredientBatch(quantity: .mass(0.5))])

        category = IngredientCategory(
            name: IngredientCategoryTests.categoryName,
            id: IngredientCategoryTests.categoryId,
            ingredients: [ingredient])

        XCTAssertNil(category.getIngredient(name: "Milk", type: .volume))
    }

    func testGetIngredient_existingIngredientDifferentType_returnsNil() throws {
        let ingredientName = "Cheese"
        let quantityType: QuantityType = .mass
        let ingredient = try Ingredient(
            name: ingredientName,
            type: quantityType,
            batches: [IngredientBatch(quantity: .mass(0.5))])

        category = IngredientCategory(
            name: IngredientCategoryTests.categoryName,
            id: IngredientCategoryTests.categoryId,
            ingredients: [ingredient])

        XCTAssertNil(category.getIngredient(name: ingredientName, type: .count))
    }
}
