import XCTest

@testable import ChopChop

class IngredientTests: XCTestCase {
    var ingredient: Ingredient!

    override func setUpWithError() throws {
        try super.setUpWithError()

        ingredient = try Ingredient(name: "Potato", type: .count)
    }

    override func tearDownWithError() throws {
        ingredient = nil

        try super.tearDownWithError()
    }

    private func addTestQuantity(_ quantity: Double, expiryDate: Date = .testDate) {
        let ingredientQuantity: IngredientQuantity = .count(quantity)
        XCTAssertNoThrow(try ingredient.add(quantity: ingredientQuantity, expiryDate: expiryDate))
    }
}

// MARK: - Init
extension IngredientTests {
    func testInit_validName_success() {
        let validName = "Sugar"
        XCTAssertNoThrow(try Ingredient(name: validName, type: .volume))
    }

    func testInit_emptyName_throwsError() {
        let emptyName = ""
        XCTAssertThrowsError(try Ingredient(name: emptyName, type: .count))

        let nameWithOnlyWhitespace = " "
        XCTAssertThrowsError(try Ingredient(name: nameWithOnlyWhitespace, type: .count))
    }
}

// MARK: - Rename
extension IngredientTests {
    func testRename_validName_success() {
        let validName = "Sugar"
        XCTAssertNoThrow(try ingredient.rename(validName))
    }

    func testRename_emptyName_throwsError() {
        let emptyName = ""
        XCTAssertThrowsError(try ingredient.rename(emptyName))

        let nameWithOnlyWhitespace = " "
        XCTAssertThrowsError(try ingredient.rename(nameWithOnlyWhitespace))
    }
}

// MARK: - Add
extension IngredientTests {
    func testAdd_sameQuantityTypeNewExpiryDate_newBatchAdded() {
        let addedQuantity: IngredientQuantity = .count(2)
        XCTAssertNoThrow(try ingredient.add(quantity: addedQuantity, expiryDate: .testDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, addedQuantity, "Quantity of batch should be set correctly")
        XCTAssertEqual(batch?.expiryDate, .testDate, "Expiry date of batch should be set correctly")
    }

    func testAdd_sameQuantityTypeExistingBatchWithDate_quantityAddedToBatch() {
        let existingQuantity: IngredientQuantity = .count(2)
        XCTAssertNoThrow(try ingredient.add(quantity: existingQuantity, expiryDate: .testDate))

        let addedQuantity: IngredientQuantity = .count(3)
        XCTAssertNoThrow(try ingredient.add(quantity: addedQuantity, expiryDate: .testDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, .count(5), "Quantity should be added correctly")
        XCTAssertEqual(batch?.expiryDate, .testDate, "Expiry date of batch should be set correctly")
        XCTAssertEqual(ingredient.batches.count, 1,
                       "There should be no new batch appended")
    }

    func testAdd_differentQuantityTypeNewExpiryDate_throwsError() {
        let addedQuantity: IngredientQuantity = .volume(1)
        XCTAssertThrowsError(try ingredient.add(quantity: addedQuantity, expiryDate: .testDate))

        XCTAssertNil(ingredient.getBatch(expiryDate: .testDate), "Batch should not be added")
    }

    func testAdd_differentQuantityTypeExistingBatchWithDate_throwsError() {
        let existingQuantity: IngredientQuantity = .count(2)
        XCTAssertNoThrow(try ingredient.add(quantity: existingQuantity, expiryDate: .testDate))

        let addedQuantity: IngredientQuantity = .mass(1)
        XCTAssertThrowsError(try ingredient.add(quantity: addedQuantity, expiryDate: .testDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, existingQuantity, "Existing batch should not be updated")
    }
}

// MARK: - Subtract
extension IngredientTests {
    func testSubtract_sufficientQuantity_success() {
        let existingQuantity: Double = 5
        addTestQuantity(existingQuantity)

        let subtractedQuantity: IngredientQuantity = .count(3)
        XCTAssertNoThrow(try ingredient.subtract(quantity: subtractedQuantity, expiryDate: .testDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, .count(2), "Quantity should be subtracted correctly")
    }

    func testSubtract_subtractAllQuantity_batchRemoved() {
        let existingQuantity: Double = 5
        addTestQuantity(existingQuantity)

        XCTAssertNoThrow(try ingredient.subtract(quantity: .count(existingQuantity), expiryDate: .testDate))

        XCTAssertNil(ingredient.getBatch(expiryDate: .testDate), "Empty batch should be removed")
    }

    func testSubtract_insufficientQuantity_throwsError() {
        let existingQuantity: Double = 5
        addTestQuantity(existingQuantity)

        let subtractedQuantity: IngredientQuantity = .count(10)
        XCTAssertThrowsError(try ingredient.subtract(quantity: subtractedQuantity, expiryDate: .testDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, .count(existingQuantity),
                       "Quantity should not be subtracted")
    }

    func testSubtract_nonExistentBatch_throwsError() {
        let subtractedQuantity: IngredientQuantity = .count(5)
        XCTAssertThrowsError(try ingredient.subtract(quantity: subtractedQuantity, expiryDate: .testDate))

        let existingQuantity: Double = 10
        addTestQuantity(existingQuantity)

        let nonExistentBatchDate = Date(timeInterval: 100, since: .testDate)
        XCTAssertThrowsError(try ingredient.subtract(quantity: subtractedQuantity, expiryDate: nonExistentBatchDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, .count(existingQuantity), "Existing batch should not be subtracted")
    }

    func testSubtract_differentQuantityType_throwsError() {
        addTestQuantity(10)

        let subtractedQuantity: IngredientQuantity = .volume(5)
        XCTAssertThrowsError(try ingredient.subtract(quantity: subtractedQuantity, expiryDate: .testDate))
    }
}

// MARK: - Use
extension IngredientTests {
    func testUse_sufficientQuantityInMultipleBatches_subtractsFromNearstExpiryDate() {
        let testDate1 = Date(timeInterval: 1_000, since: .now)
        let testDate2 = Date(timeInterval: 2_000, since: .now)
        addTestQuantity(5, expiryDate: testDate1)
        addTestQuantity(5, expiryDate: testDate2)

        let subtractedQuantity: IngredientQuantity = .count(7)
        XCTAssertNoThrow(try ingredient.use(quantity: subtractedQuantity))

        XCTAssertNil(ingredient.getBatch(expiryDate: testDate1),
                     "Quantity should be used up and batch should be removed")

        let batch2 = try? XCTUnwrap(ingredient.getBatch(expiryDate: testDate2),
                                    "Second batch should be in the ingredient")

        XCTAssertEqual(batch2?.quantity, .count(3), "Quantity should be subtracted correctly")
    }

    func testUse_existingExpiredBatch_ignoresExpiredBatch() {
        let existingQuantity: Double = 5
        let expiredDate = Date(timeInterval: -1_000, since: .now)

        let testDate = Date(timeInterval: 1_000, since: .now)
        addTestQuantity(existingQuantity, expiryDate: expiredDate)
        addTestQuantity(existingQuantity, expiryDate: testDate)

        let subtractedQuantity: IngredientQuantity = .count(5)
        XCTAssertNoThrow(try ingredient.use(quantity: subtractedQuantity))

        let expiredBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: expiredDate),
                                          "Expired batch should be in the ingredient")

        XCTAssertEqual(expiredBatch?.quantity, .count(existingQuantity),
                       "Expired ingredients should not be used")

        XCTAssertNil(ingredient.getBatch(expiryDate: testDate),
                     "Quantity should be used up and batch should be removed")
    }

    func testUse_differentQuantityType_throwsError() {
        addTestQuantity(5, expiryDate: .testDate)

        let usedQuantity: IngredientQuantity = .volume(5)
        XCTAssertThrowsError(try ingredient.use(quantity: usedQuantity))
    }

    func testUse_insufficientQuantity_throwsError() {
        let existingQuantity: Double = 5
        let expiredDate = Date(timeInterval: -1_000, since: .now)
        let testDate = Date(timeInterval: 1_000, since: .now)
        addTestQuantity(existingQuantity, expiryDate: expiredDate)
        addTestQuantity(existingQuantity, expiryDate: testDate)

        let subtractedQuantity: IngredientQuantity = .count(10)
        XCTAssertThrowsError(try ingredient.use(quantity: subtractedQuantity))

        let expiredBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: expiredDate),
                                          "Expired batch should be in the ingredient")
        XCTAssertEqual(expiredBatch?.quantity, .count(existingQuantity),
                       "Expired ingredients should not be used")

        let existingBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: testDate),
                                           "Other batch should be in the ingredient")
        XCTAssertEqual(existingBatch?.quantity, .count(existingQuantity),
                       "Ingredients should not be used if there is insufficient quantity")
    }
}

// MARK: - Combine
extension IngredientTests {
    func testCombine_sameIngredientAndQuantityType_success() {
        guard let combinedIngredient = try? Ingredient(name: ingredient.name, type: ingredient.quantityType) else {
            XCTFail("Ingredient should be successfully constructed")
            return
        }

        let expiredDate = Date(timeInterval: -1_000, since: .now)
        let combinedDate = Date(timeInterval: 1_000, since: .now)
        let existingDate = Date(timeInterval: 2_000, since: .now)
        let newDate = Date(timeInterval: 3_000, since: .now)
        addTestQuantity(1, expiryDate: expiredDate)
        addTestQuantity(2, expiryDate: combinedDate)
        addTestQuantity(3, expiryDate: existingDate)

        XCTAssertNoThrow(try combinedIngredient.add(quantity: .count(4), expiryDate: expiredDate))
        XCTAssertNoThrow(try combinedIngredient.add(quantity: .count(5), expiryDate: combinedDate))
        XCTAssertNoThrow(try combinedIngredient.add(quantity: .count(6), expiryDate: newDate))

        XCTAssertNoThrow(try ingredient.combine(with: combinedIngredient))

        let expiredBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: expiredDate),
                                          "Expired batch should be in the ingredient")
        XCTAssertEqual(expiredBatch?.quantity, .count(5),
                       "Expired batch quantities should be combined")

        let combinedBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: combinedDate),
                                           "Combined batch should be in the ingredient")
        XCTAssertEqual(combinedBatch?.quantity, .count(7),
                       "Combined batch quantities should be combined")

        let existingBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: existingDate),
                                           "Existing batch should be in the ingredient")
        XCTAssertEqual(existingBatch?.quantity, .count(3),
                       "Existing batch quantities should not be changed")

        let newBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: newDate),
                                      "New batch should be appended to the ingredient")
        XCTAssertEqual(newBatch?.quantity, .count(6),
                       "New batch quantities should be added correctly")
    }

    func testCombine_differentIngredientName_throwsError() {
        guard let combinedIngredient = try? Ingredient(name: "Apple", type: ingredient.quantityType) else {
            XCTFail("Ingredient should be successfully constructed")
            return
        }

        XCTAssertThrowsError(try ingredient.combine(with: combinedIngredient))
    }

    func testCombine_differentQuantityType_throwsError() {
        guard let combinedIngredient = try? Ingredient(name: ingredient.name, type: .volume) else {
            XCTFail("Ingredient should be successfully constructed")
            return
        }

        XCTAssertThrowsError(try ingredient.combine(with: combinedIngredient))
    }
}

// MARK: - Get and remove batches
extension IngredientTests {
    func testGetBatch_existingBatch_success() {
        addTestQuantity(5)
        guard let batch = ingredient.getBatch(expiryDate: .testDate) else {
            XCTFail("Batch should be added")
            return
        }

        XCTAssertEqual(batch.expiryDate, .testDate,
                       "Correct batch should be retrieved")
    }

    func testGetBatch_notExistingBatch_returnsNil() {
        addTestQuantity(5)
        let notExistingDate = Date(timeInterval: 1_000, since: .testDate)

        XCTAssertNil(ingredient.getBatch(expiryDate: notExistingDate),
                     "Non existent batch should not be retrieved")
    }

    func testRemoveBatch_existingBatch_success() {
        addTestQuantity(5)
        ingredient.removeBatch(expiryDate: .testDate)

        XCTAssertNil(ingredient.getBatch(expiryDate: .testDate),
                     "Batch should be removed")
    }

    func testRemoveBatch_nonExistingBatch_doNothing() {
        addTestQuantity(5)
        let nonExistingDate = Date(timeInterval: 1_000, since: .testDate)
        ingredient.removeBatch(expiryDate: nonExistingDate)

        XCTAssertNotNil(ingredient.getBatch(expiryDate: .testDate),
                        "Batch should not be removed")
    }

    func testRemoveExpiredBatches_existingExpiredBatches_success() {
        let expiredDate2 = Date(timeInterval: -2_000, since: .now)
        let expiredDate1 = Date(timeInterval: -1_000, since: .now)
        addTestQuantity(5, expiryDate: expiredDate1)
        addTestQuantity(5, expiryDate: expiredDate2)

        ingredient.removeExpiredBatches()

        XCTAssertNil(ingredient.getBatch(expiryDate: expiredDate1),
                     "Expired batch should be removed")
        XCTAssertNil(ingredient.getBatch(expiryDate: expiredDate2),
                     "Expired batch should be removed")
    }

    func testRemoveExpiredBatches_existingNonExpiredBatches_ignoresNonExpiredBatches() {
        let expiredDate = Date(timeInterval: -1_000, since: .now)
        let notExpiredDate = Date(timeInterval: 1_000, since: .now)
        addTestQuantity(5, expiryDate: expiredDate)
        addTestQuantity(5, expiryDate: notExpiredDate)

        ingredient.removeExpiredBatches()

        XCTAssertNil(ingredient.getBatch(expiryDate: expiredDate),
                     "Expired batch should be removed")
        XCTAssertNotNil(ingredient.getBatch(expiryDate: notExpiredDate),
                        "Not expired batch should not be removed")
    }
}
