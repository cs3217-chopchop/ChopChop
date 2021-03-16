import XCTest

@testable import ChopChop

class IngredientReferenceTests: XCTestCase {
    var reference: IngredientReference!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let existingQuantity = try Quantity(.volume, value: 0.1)
        reference = try IngredientReference(
            name: "Sugar",
            quantity: existingQuantity)
    }

    override func tearDownWithError() throws {
        reference = nil

        try super.tearDownWithError()
    }
}

// MARK: - Construct
extension IngredientReferenceTests {
    func testConstruct_validName_nameTrimmed() throws {
        let validName = "  Cheese\n"
        let quantity = try Quantity(.count, value: 3)
        XCTAssertNoThrow(reference = try IngredientReference(name: validName, quantity: quantity))

        let trimmedName = validName.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(reference.name, trimmedName)
    }

    func testConstruct_invalidName_throwsError() throws {
        let emptyName = ""
        let quantity = try Quantity(.count, value: 3)
        XCTAssertThrowsError(try IngredientReference(name: emptyName, quantity: quantity))

        let invalidName = " \n"
        XCTAssertThrowsError(try IngredientReference(name: invalidName, quantity: quantity))
    }
}

// MARK: - Add
extension IngredientReferenceTests {
    func testAdd_sameQuantityType_success() throws {
        let addedQuantity = try Quantity(.volume, value: 0.2)

        XCTAssertNoThrow(try reference.add(addedQuantity))

        let existingQuantity = try Quantity(.volume, value: 0.1)
        let sum = try? existingQuantity + addedQuantity
        XCTAssertEqual(reference.quantity, sum, "Quantities should be added correctly")
    }

    func testAdd_differentQuantityType_throwsError() throws {
        let addedQuantity = try Quantity(.mass, value: 3)

        XCTAssertThrowsError(try reference.add(addedQuantity))

        let existingQuantity = try Quantity(.volume, value: 0.1)
        XCTAssertEqual(reference.quantity, existingQuantity,
                       "Current quantity should not be changed")
    }
}

// MARK: - Subtract
extension IngredientReferenceTests {
    func testSubtract_sameQuantityTypeSufficientQuantity_success() throws {
        let subtractedQuantity = try Quantity(.volume, value: 0.05)

        XCTAssertNoThrow(try reference.subtract(subtractedQuantity))

        let existingQuantity = try Quantity(.volume, value: 0.1)
        guard let difference = try? existingQuantity - subtractedQuantity else {
            XCTFail("Quantity not subtracted properly")
            return
        }

        XCTAssertEqual(reference.quantity, difference, "Quantities should be subtracted correctly")
    }

    func testSubtract_insufficientQuantity_throwsError() throws {
        let subtractedQuantity = try Quantity(.volume, value: 1)

        XCTAssertThrowsError(try reference.subtract(subtractedQuantity))

        let existingQuantity = try Quantity(.volume, value: 0.1)
        XCTAssertEqual(reference.quantity, existingQuantity,
                       "Quantity should not be subtracted")
    }

    func testSubtract_differentQuantityType_throwsError() throws {
        let subtractedQuantity = try Quantity(.mass, value: 3)

        XCTAssertThrowsError(try reference.subtract(subtractedQuantity))

        let existingQuantity = try Quantity(.volume, value: 0.1)
        XCTAssertEqual(reference.quantity, existingQuantity,
                       "Quantity should not be subtracted")
    }
}

// MARK: - Scale
extension IngredientReferenceTests {
    func testScale_nonNegativeFactor_success() throws {
        let factor: Double = 1.5

        XCTAssertNoThrow(try reference.scale(factor))

        let existingQuantity = try Quantity(.volume, value: 0.1)
        guard let product = try? existingQuantity * factor else {
            XCTFail("Quantity not multiplied properly")
            return
        }

        XCTAssertEqual(reference.quantity, product, "Quantity should be scaled correctly")
    }

    func testScale_negativeResult_throwsError() throws {
        let factor: Double = -0.5

        XCTAssertThrowsError(try reference.scale(factor))

        let existingQuantity = try Quantity(.volume, value: 0.1)
        XCTAssertEqual(reference.quantity, existingQuantity,
                       "Quantity should not be scaled")
    }
}
