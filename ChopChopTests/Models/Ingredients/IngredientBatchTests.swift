import XCTest

@testable import ChopChop

class IngredientBatchTests: XCTestCase {
    static let existingQuantity: Quantity = .count(5)
    var batch: IngredientBatch!

    override func setUpWithError() throws {
        try super.setUpWithError()

        batch = IngredientBatch(
            quantity: IngredientBatchTests.existingQuantity,
            expiryDate: .testDate)
    }

    override func tearDownWithError() throws {
        batch = nil

        try super.tearDownWithError()
    }
}

// MARK: - IsEmpty
extension IngredientBatchTests {
    func testIsEmpty_emptyBatch_success() {
        batch = IngredientBatch(quantity: .count(0), expiryDate: .testDate)

        XCTAssertTrue(batch.isEmpty)
    }

    func testIsEmpty_nonEmptyBatch_success() {
        XCTAssertFalse(batch.isEmpty)
    }
}

// MARK: - Add
extension IngredientBatchTests {
    func testAdd_sameQuantityType_success() {
        let addedQuantity: Quantity = .count(3)

        XCTAssertNoThrow(try batch.add(addedQuantity))

        let sum = try? IngredientBatchTests.existingQuantity + addedQuantity
        XCTAssertEqual(batch.quantity, sum, "Quantities should be added correctly")
    }

    func testAdd_differentQuantityType_throwsError() {
        let addedQuantity: Quantity = .mass(3)

        XCTAssertThrowsError(try batch.add(addedQuantity))

        XCTAssertEqual(batch.quantity, IngredientBatchTests.existingQuantity,
                       "Current quantity should not be changed")
    }
}

// MARK: - Subtract
extension IngredientBatchTests {
    func testSubtract_sameQuantityTypeSufficientQuantity_success() {
        let subtractedQuantity: Quantity = .count(3)

        XCTAssertNoThrow(try batch.subtract(subtractedQuantity))

        guard let difference = try? IngredientBatchTests.existingQuantity - subtractedQuantity else {
            XCTFail("Quantity not subtracted properly")
            return
        }

        XCTAssertEqual(batch.quantity, difference, "Quantities should be subtracted correctly")

        XCTAssertNoThrow(try batch.subtract(difference))
        XCTAssertTrue(batch.isEmpty)
    }

    func testSubtract_insufficientQuantity_throwsError() {
        let subtractedQuantity: Quantity = .count(10)

        XCTAssertThrowsError(try batch.subtract(subtractedQuantity))

        XCTAssertEqual(batch.quantity, IngredientBatchTests.existingQuantity,
                       "Quantity should not be subtracted")
    }

    func testSubtract_differentQuantityType_throwsError() {
        let subtractedQuantity: Quantity = .mass(3)

        XCTAssertThrowsError(try batch.subtract(subtractedQuantity))

        XCTAssertEqual(batch.quantity, IngredientBatchTests.existingQuantity,
                       "Quantity should not be subtracted")
    }
}

// MARK: - Comparable
extension IngredientBatchTests {
    func testCompare() {
        let laterDate = Date(timeInterval: 1_000, since: .testDate)

        let laterBatch = IngredientBatch(
            quantity: IngredientBatchTests.existingQuantity,
            expiryDate: laterDate)

        XCTAssertTrue(batch < laterBatch)
    }

    func testEqual() {
        let identicalBatch = IngredientBatch(
            quantity: IngredientBatchTests.existingQuantity,
            expiryDate: .testDate)

        XCTAssertTrue(batch == identicalBatch)

        let differentDate = Date(timeInterval: 1_000, since: .testDate)
        let differentDateBatch = IngredientBatch(
            quantity: IngredientBatchTests.existingQuantity,
            expiryDate: differentDate)

        XCTAssertFalse(batch == differentDateBatch)

        let differentQuantityTypeBatch = IngredientBatch(
            quantity: .volume(5),
            expiryDate: .testDate)

        XCTAssertFalse(batch == differentQuantityTypeBatch)

        let differentQuantityBatch = IngredientBatch(
            quantity: .count(4),
            expiryDate: .testDate)

        XCTAssertFalse(batch == differentQuantityBatch)
    }
}
