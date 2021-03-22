// swiftlint:disable file_length

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

    private func addTestQuantity(_ value: Double, expiryDate: Date? = .testDate) throws {
        let quantity = try Quantity(.count, value: value)
        XCTAssertNoThrow(try ingredient.add(quantity: quantity, expiryDate: expiryDate))
    }
}

// MARK: - Construct
extension IngredientTests {
    func testConstruct_validName_nameTrimmed() {
        let validName = "  Sugar\n"
        XCTAssertNoThrow(ingredient = try Ingredient(name: validName, type: .volume))

        let trimmedName = validName.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(ingredient.name, trimmedName)
    }

    func testConstruct_invalidName_throwsError() {
        let emptyName = ""
        XCTAssertThrowsError(try Ingredient(name: emptyName, type: .count))

        let invalidName = " \n"
        XCTAssertThrowsError(try Ingredient(name: invalidName, type: .count))
    }
}

// MARK: - Rename
extension IngredientTests {
    func testRename_validName_nameTrimmed() {
        let validName = "  Sugar\n"
        XCTAssertNoThrow(try ingredient.rename(validName))

        let trimmedName = validName.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(ingredient.name, trimmedName)
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
    func testAdd_sameQuantityTypeNewExpiryDate_newBatchAdded() throws {
        let addedQuantity = try Quantity(.count, value: 2)
        XCTAssertNoThrow(try ingredient.add(quantity: addedQuantity, expiryDate: nil))

        let nonExpiringBatch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: nil),
            "Batch should exist in ingredient")

        XCTAssertEqual(nonExpiringBatch?.quantity, addedQuantity, "Quantity of batch should be set correctly")
        XCTAssertNil(nonExpiringBatch?.expiryDate, "Batch should not have expiry date")

        XCTAssertNoThrow(try ingredient.add(quantity: addedQuantity, expiryDate: .testDate))

        let expiringBatch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(nonExpiringBatch?.quantity, addedQuantity, "Quantity of non expiring batch should be unchanged")
        XCTAssertEqual(expiringBatch?.quantity, addedQuantity, "Quantity of batch should be set correctly")
        XCTAssertEqual(expiringBatch?.expiryDate, .testDate, "Expiry date of batch should be set correctly")
    }

    func testAdd_sameQuantityTypeExistingBatchWithDate_quantityAddedToBatch() throws {
        let existingQuantity = try Quantity(.count, value: 2)
        XCTAssertNoThrow(try ingredient.add(quantity: existingQuantity, expiryDate: .testDate))

        let addedQuantity = try Quantity(.count, value: 3)
        XCTAssertNoThrow(try ingredient.add(quantity: addedQuantity, expiryDate: .testDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, try? Quantity(.count, value: 5), "Quantity should be added correctly")
        XCTAssertEqual(batch?.expiryDate, .testDate, "Expiry date of batch should be set correctly")
        XCTAssertEqual(ingredient.batches.count, 1,
                       "There should be no new batch appended")
    }

    func testAdd_sameQuantityTypeExistingNonExpiringBatch_quantityAddedToBatch() throws {
        let existingQuantity = try Quantity(.count, value: 2)
        XCTAssertNoThrow(try ingredient.add(quantity: existingQuantity, expiryDate: nil))

        let addedQuantity = try Quantity(.count, value: 3)
        XCTAssertNoThrow(try ingredient.add(quantity: addedQuantity, expiryDate: nil))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: nil),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, try? Quantity(.count, value: 5),
                       "Quantity should be added correctly")
        XCTAssertNil(batch?.expiryDate, "Batch should not have expiry date")
        XCTAssertEqual(ingredient.batches.count, 1,
                       "There should be no new batch appended")
    }

    func testAdd_differentQuantityTypeNewExpiryDate_throwsError() throws {
        let addedQuantity = try Quantity(.volume(.liter), value: 1)
        XCTAssertThrowsError(try ingredient.add(quantity: addedQuantity, expiryDate: .testDate))

        XCTAssertNil(ingredient.getBatch(expiryDate: .testDate), "Batch should not be added")
    }

    func testAdd_differentQuantityTypeExistingBatchWithDate_throwsError() throws {
        let existingQuantity = try Quantity(.count, value: 2)
        XCTAssertNoThrow(try ingredient.add(quantity: existingQuantity, expiryDate: .testDate))

        let addedQuantity = try Quantity(.mass(.kilogram), value: 1)
        XCTAssertThrowsError(try ingredient.add(quantity: addedQuantity, expiryDate: .testDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, existingQuantity, "Existing batch should not be updated")
    }
}

// MARK: - Subtract
extension IngredientTests {
    func testSubtract_sufficientQuantity_success() throws {
        let existingQuantity: Double = 5
        try addTestQuantity(existingQuantity)

        let subtractedQuantity: Quantity = try Quantity(.count, value: 3)
        XCTAssertNoThrow(try ingredient.subtract(quantity: subtractedQuantity, expiryDate: .testDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, try? Quantity(.count, value: 2),
                       "Quantity should be subtracted correctly")
    }

    func testSubtract_subtractAllQuantity_batchRemoved() throws {
        let existingQuantity = try Quantity(.count, value: 5)
        try addTestQuantity(5)

        XCTAssertNoThrow(try ingredient.subtract(quantity: existingQuantity, expiryDate: .testDate))

        XCTAssertNil(ingredient.getBatch(expiryDate: .testDate), "Empty batch should be removed")
    }

    func testSubtract_insufficientQuantity_throwsError() throws {
        let existingQuantity = try Quantity(.count, value: 5)
        try addTestQuantity(5)

        let subtractedQuantity = try Quantity(.count, value: 10)
        XCTAssertThrowsError(try ingredient.subtract(quantity: subtractedQuantity, expiryDate: .testDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, existingQuantity,
                       "Quantity should not be subtracted")
    }

    func testSubtract_nonExistentBatch_throwsError() throws {
        let subtractedQuantity = try Quantity(.count, value: 5)
        XCTAssertThrowsError(try ingredient.subtract(quantity: subtractedQuantity, expiryDate: .testDate))

        let existingQuantity = try Quantity(.count, value: 10)
        try addTestQuantity(10)

        let nonExistentBatchDate = Date(timeInterval: 86_400, since: .testDate)
        XCTAssertThrowsError(try ingredient.subtract(quantity: subtractedQuantity, expiryDate: nonExistentBatchDate))

        let batch = try? XCTUnwrap(
            ingredient.getBatch(expiryDate: .testDate),
            "Batch should exist in ingredient")

        XCTAssertEqual(batch?.quantity, existingQuantity, "Existing batch should not be subtracted")
    }

    func testSubtract_differentQuantityType_throwsError() throws {
        try addTestQuantity(10)

        let subtractedQuantity = try Quantity(.volume(.liter), value: 5)
        XCTAssertThrowsError(try ingredient.subtract(quantity: subtractedQuantity, expiryDate: .testDate))
    }
}

// MARK: - Use
extension IngredientTests {
    func testUse_sufficientQuantityInMultipleBatches_subtractsFromNearstExpiryDate() throws {
        let testDate1 = Date(timeInterval: 86_400, since: .now)
        let testDate2 = Date(timeInterval: 86_400 * 2, since: .now)
        try addTestQuantity(5, expiryDate: testDate1)
        try addTestQuantity(5, expiryDate: testDate2)
        try addTestQuantity(5, expiryDate: nil)

        let subtractedQuantity = try Quantity(.count, value: 12)
        XCTAssertNoThrow(try ingredient.use(quantity: subtractedQuantity))

        XCTAssertNil(ingredient.getBatch(expiryDate: testDate1),
                     "Quantity should be used up and batch should be removed")
        XCTAssertNil(ingredient.getBatch(expiryDate: testDate2),
                     "Quantity should be used up and batch should be removed")

        let nonExpiringBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: nil),
                                              "Non expiring batch should be in the ingredient")

        XCTAssertEqual(nonExpiringBatch?.quantity, try? Quantity(.count, value: 3),
                       "Quantity should be subtracted correctly")
    }

    func testUse_existingExpiredBatch_ignoresExpiredBatch() throws {
        let existingQuantity = try Quantity(.count, value: 5)
        let expiredDate = Date.today.addingTimeInterval(-86_400)
        let testDate = Date.today.addingTimeInterval(86_400)

        try addTestQuantity(5, expiryDate: expiredDate)
        try addTestQuantity(5, expiryDate: testDate)

        let subtractedQuantity = try Quantity(.count, value: 5)
        XCTAssertNoThrow(try ingredient.use(quantity: subtractedQuantity))

        let expiredBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: expiredDate),
                                          "Expired batch should be in the ingredient")

        XCTAssertEqual(expiredBatch?.quantity, existingQuantity,
                       "Expired ingredients should not be used")

        XCTAssertNil(ingredient.getBatch(expiryDate: testDate),
                     "Quantity should be used up and batch should be removed")
    }

    func testUse_differentQuantityType_throwsError() throws {
        try addTestQuantity(5, expiryDate: .testDate)

        let usedQuantity = try Quantity(.volume(.liter), value: 5)
        XCTAssertThrowsError(try ingredient.use(quantity: usedQuantity))
    }

    func testUse_insufficientQuantity_throwsError() throws {
        let existingQuantity = try Quantity(.count, value: 5)
        let expiredDate = Date(timeInterval: -86_400, since: .now)
        let testDate = Date(timeInterval: 86_400, since: .now)
        try addTestQuantity(5, expiryDate: expiredDate)
        try addTestQuantity(5, expiryDate: testDate)

        let subtractedQuantity = try Quantity(.count, value: 10)
        XCTAssertThrowsError(try ingredient.use(quantity: subtractedQuantity))

        let expiredBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: expiredDate),
                                          "Expired batch should be in the ingredient")
        XCTAssertEqual(expiredBatch?.quantity, existingQuantity,
                       "Expired ingredients should not be used")

        let existingBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: testDate),
                                           "Other batch should be in the ingredient")
        XCTAssertEqual(existingBatch?.quantity, existingQuantity,
                       "Ingredients should not be used if there is insufficient quantity")
    }
}

// MARK: - Combine
extension IngredientTests {
    func testCombine_sameIngredientAndQuantityType_success() throws {
        guard let combinedIngredient = try? Ingredient(name: ingredient.name, type: ingredient.quantityType) else {
            XCTFail("Ingredient should be successfully constructed")
            return
        }

        let expiredDate = Date(timeInterval: -86_400, since: .now)
        let combinedDate = Date(timeInterval: 86_400, since: .now)
        let existingDate = Date(timeInterval: 86_400 * 2, since: .now)
        let newDate = Date(timeInterval: 86_400 * 3, since: .now)
        try addTestQuantity(1, expiryDate: expiredDate)
        try addTestQuantity(2, expiryDate: combinedDate)
        try addTestQuantity(3, expiryDate: existingDate)

        let addedQuantity1 = try Quantity(.count, value: 4)
        let addedQuantity2 = try Quantity(.count, value: 5)
        let addedQuantity3 = try Quantity(.count, value: 6)

        XCTAssertNoThrow(try combinedIngredient.add(quantity: addedQuantity1, expiryDate: expiredDate))
        XCTAssertNoThrow(try combinedIngredient.add(quantity: addedQuantity2, expiryDate: combinedDate))
        XCTAssertNoThrow(try combinedIngredient.add(quantity: addedQuantity3, expiryDate: newDate))

        XCTAssertNoThrow(try ingredient.combine(with: combinedIngredient))

        let expiredBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: expiredDate),
                                          "Expired batch should be in the ingredient")
        XCTAssertEqual(expiredBatch?.quantity, try? Quantity(.count, value: 5),
                       "Expired batch quantities should be combined")

        let combinedBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: combinedDate),
                                           "Combined batch should be in the ingredient")
        XCTAssertEqual(combinedBatch?.quantity, try? Quantity(.count, value: 7),
                       "Combined batch quantities should be combined")

        let existingBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: existingDate),
                                           "Existing batch should be in the ingredient")
        XCTAssertEqual(existingBatch?.quantity, try? Quantity(.count, value: 3),
                       "Existing batch quantities should not be changed")

        let newBatch = try? XCTUnwrap(ingredient.getBatch(expiryDate: newDate),
                                      "New batch should be appended to the ingredient")
        XCTAssertEqual(newBatch?.quantity, try? Quantity(.count, value: 6),
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
    func testGetBatch_existingBatch_success() throws {
        try addTestQuantity(5)
        let batch = try? XCTUnwrap(ingredient.getBatch(expiryDate: .testDate),
                                   "Batch should be added")

        XCTAssertEqual(batch?.expiryDate, .testDate,
                       "Correct batch should be retrieved")
    }

    func testGetBatch_notExpiringBatch_success() throws {
        try addTestQuantity(5, expiryDate: nil)
        let batch = try? XCTUnwrap(ingredient.getBatch(expiryDate: nil),
                                   "Batch should be added")

        XCTAssertNil(batch?.expiryDate, "Correct batch should be retrieved")
    }

    func testGetBatch_notExistingBatch_returnsNil() throws {
        try addTestQuantity(5)
        let notExistingDate = Date(timeInterval: 86_400, since: .testDate)

        XCTAssertNil(ingredient.getBatch(expiryDate: notExistingDate),
                     "Non existent batch should not be retrieved")
    }

    func testRemoveBatch_existingBatch_success() throws {
        try addTestQuantity(5)
        ingredient.removeBatch(expiryDate: .testDate)

        XCTAssertNil(ingredient.getBatch(expiryDate: .testDate),
                     "Batch should be removed")
    }

    func testRemoveBatch_notExpiringBatch_success() throws {
        try addTestQuantity(5, expiryDate: nil)
        ingredient.removeBatch(expiryDate: nil)

        XCTAssertNil(ingredient.getBatch(expiryDate: nil),
                     "Batch should be removed")
    }

    func testRemoveBatch_nonExistingBatch_doNothing() throws {
        try addTestQuantity(5)
        let nonExistingDate = Date(timeInterval: 86_400, since: .testDate)
        ingredient.removeBatch(expiryDate: nonExistingDate)

        XCTAssertNotNil(ingredient.getBatch(expiryDate: .testDate),
                        "Batch should not be removed")
    }

    func testRemoveExpiredBatches_existingExpiredBatches_success() throws {
        let expiredDate2 = Date(timeInterval: -86_400 * 2, since: .now)
        let expiredDate1 = Date(timeInterval: -86_400, since: .now)
        try addTestQuantity(5, expiryDate: expiredDate1)
        try addTestQuantity(5, expiryDate: expiredDate2)

        ingredient.removeExpiredBatches()

        XCTAssertNil(ingredient.getBatch(expiryDate: expiredDate1),
                     "Expired batch should be removed")
        XCTAssertNil(ingredient.getBatch(expiryDate: expiredDate2),
                     "Expired batch should be removed")
    }

    func testRemoveExpiredBatches_existingNonExpiredBatches_ignoresNonExpiredBatches() throws {
        let expiredDate = Date(timeInterval: -86_400, since: .now)
        let notExpiredDate = Date(timeInterval: 86_400, since: .now)
        try addTestQuantity(5, expiryDate: expiredDate)
        try addTestQuantity(5, expiryDate: notExpiredDate)
        try addTestQuantity(5, expiryDate: nil)

        ingredient.removeExpiredBatches()

        XCTAssertNil(ingredient.getBatch(expiryDate: expiredDate),
                     "Expired batch should be removed")
        XCTAssertNotNil(ingredient.getBatch(expiryDate: notExpiredDate),
                        "Not expired batch should not be removed")
        XCTAssertNotNil(ingredient.getBatch(expiryDate: nil),
                        "Not expiring batch should not be removed")
    }
}

extension Date {
    static let testDate = Date(timeIntervalSinceReferenceDate: 0).startOfDay
    static let now = Date()
}
