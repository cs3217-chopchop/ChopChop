import XCTest

@testable import ChopChop

class IngredientBatchTests: XCTestCase {
    var batch: IngredientBatch!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let existingQuantity = try Quantity(.count, value: 5)
        batch = IngredientBatch(
            quantity: existingQuantity,
            expiryDate: .testDate)
    }

    override func tearDownWithError() throws {
        batch = nil

        try super.tearDownWithError()
    }
}

// MARK: - IsEmpty
extension IngredientBatchTests {
    func testIsEmpty_emptyBatch_success() throws {
        let emptyQuantity = try Quantity(.count, value: 0)
        batch = IngredientBatch(quantity: emptyQuantity, expiryDate: .testDate)

        XCTAssertTrue(batch.isEmpty)
    }

    func testIsEmpty_nonEmptyBatch_success() {
        XCTAssertFalse(batch.isEmpty)
    }
}

// MARK: - Add
extension IngredientBatchTests {
    func testAdd_sameQuantityType_success() throws {
        let addedQuantity = try Quantity(.count, value: 3)

        XCTAssertNoThrow(try batch.add(addedQuantity))

        let existingQuantity = try Quantity(.count, value: 5)
        let sum = try? existingQuantity + addedQuantity
        XCTAssertEqual(batch.quantity, sum, "Quantities should be added correctly")
    }

    func testAdd_differentQuantityType_throwsError() throws {
        let addedQuantity = try Quantity(.mass(.baseUnit), value: 3)

        XCTAssertThrowsError(try batch.add(addedQuantity))

        let existingQuantity = try Quantity(.count, value: 5)
        XCTAssertEqual(batch.quantity, existingQuantity,
                       "Current quantity should not be changed")
    }
}

// MARK: - Subtract
extension IngredientBatchTests {
    func testSubtract_sameQuantityTypeSufficientQuantity_success() throws {
        let subtractedQuantity = try Quantity(.count, value: 3)

        XCTAssertNoThrow(try batch.subtract(subtractedQuantity))

        let existingQuantity = try Quantity(.count, value: 5)
        guard let difference = try? existingQuantity - subtractedQuantity else {
            XCTFail("Quantity not subtracted properly")
            return
        }

        XCTAssertEqual(batch.quantity, difference, "Quantities should be subtracted correctly")

        XCTAssertNoThrow(try batch.subtract(difference))
        XCTAssertTrue(batch.isEmpty)
    }

    func testSubtract_insufficientQuantity_throwsError() throws {
        let subtractedQuantity = try Quantity(.count, value: 10)

        XCTAssertThrowsError(try batch.subtract(subtractedQuantity))

        let existingQuantity = try Quantity(.count, value: 5)
        XCTAssertEqual(batch.quantity, existingQuantity,
                       "Quantity should not be subtracted")
    }

    func testSubtract_differentQuantityType_throwsError() throws {
        let subtractedQuantity = try Quantity(.mass(.baseUnit), value: 3)

        XCTAssertThrowsError(try batch.subtract(subtractedQuantity))

        let existingQuantity = try Quantity(.count, value: 5)
        XCTAssertEqual(batch.quantity, existingQuantity,
                       "Quantity should not be subtracted")
    }
}

// MARK: - Comparable
extension IngredientBatchTests {
    func testCompare_expiringBatches_success() throws {
        let laterDate = Date(timeInterval: 86_400, since: .testDate)

        let existingQuantity = try Quantity(.count, value: 5)
        let laterBatch = IngredientBatch(
            quantity: existingQuantity,
            expiryDate: laterDate)

        XCTAssertLessThan(batch, laterBatch)
    }

    func testCompare_nonExpiringBatch_success() throws {
        let existingQuantity = try Quantity(.count, value: 5)
        let nonExpiringBatch = IngredientBatch(
            quantity: existingQuantity)

        XCTAssertLessThan(batch, nonExpiringBatch)
    }

    func testEqual() throws {
        let existingQuantity = try Quantity(.count, value: 5)
        let identicalBatch = IngredientBatch(
            quantity: existingQuantity,
            expiryDate: .testDate)

        XCTAssertEqual(batch, identicalBatch)

        let differentDate = Date(timeInterval: 86_400, since: .testDate)
        let differentDateBatch = IngredientBatch(
            quantity: existingQuantity,
            expiryDate: differentDate)

        XCTAssertNotEqual(batch, differentDateBatch)

        let volumeQuantity = try Quantity(.volume(.baseUnit), value: 5)
        let differentQuantityTypeBatch = IngredientBatch(
            quantity: volumeQuantity,
            expiryDate: .testDate)

        XCTAssertNotEqual(batch, differentQuantityTypeBatch)

        let differentQuantity = try Quantity(.count, value: 4)
        let differentQuantityBatch = IngredientBatch(
            quantity: differentQuantity,
            expiryDate: .testDate)

        XCTAssertNotEqual(batch, differentQuantityBatch)
    }
}
