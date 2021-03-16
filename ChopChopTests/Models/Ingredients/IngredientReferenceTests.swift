import XCTest

@testable import ChopChop

class IngredientReferenceTests: XCTestCase {
    static let existingQuantity: Quantity = .volume(0.1)
    var reference: IngredientReference!

    override func setUpWithError() throws {
        try super.setUpWithError()

        reference = try IngredientReference(
            name: "Sugar",
            quantity: IngredientReferenceTests.existingQuantity)
    }

    override func tearDownWithError() throws {
        reference = nil

        try super.tearDownWithError()
    }
}

// MARK: - Construct
extension IngredientReferenceTests {
    func testConstruct_validName_nameTrimmed() {
        let validName = "  Cheese\n"
        XCTAssertNoThrow(reference = try IngredientReference(name: validName, quantity: .count(3)))

        let trimmedName = validName.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(reference.name, trimmedName)
    }

    func testConstruct_invalidName_throwsError() {
        let emptyName = ""
        XCTAssertThrowsError(try IngredientReference(name: emptyName, quantity: .count(3)))

        let invalidName = " \n"
        XCTAssertThrowsError(try IngredientReference(name: invalidName, quantity: .count(3)))
    }
}

// MARK: - Add
extension IngredientReferenceTests {
    func testAdd_sameQuantityType_success() {
        let addedQuantity: Quantity = .volume(0.2)

        XCTAssertNoThrow(try reference.add(addedQuantity))

        let sum = try? IngredientReferenceTests.existingQuantity + addedQuantity
        XCTAssertEqual(reference.quantity, sum, "Quantities should be added correctly")
    }

    func testAdd_differentQuantityType_throwsError() {
        let addedQuantity: Quantity = .mass(3)

        XCTAssertThrowsError(try reference.add(addedQuantity))

        XCTAssertEqual(reference.quantity, IngredientReferenceTests.existingQuantity,
                       "Current quantity should not be changed")
    }
}

// MARK: - Subtract
extension IngredientReferenceTests {
    func testSubtract_sameQuantityTypeSufficientQuantity_success() {
        let subtractedQuantity: Quantity = .volume(0.05)

        XCTAssertNoThrow(try reference.subtract(subtractedQuantity))

        guard let difference = try? IngredientReferenceTests.existingQuantity - subtractedQuantity else {
            XCTFail("Quantity not subtracted properly")
            return
        }

        XCTAssertEqual(reference.quantity, difference, "Quantities should be subtracted correctly")
    }

    func testSubtract_insufficientQuantity_throwsError() {
        let subtractedQuantity: Quantity = .volume(1)

        XCTAssertThrowsError(try reference.subtract(subtractedQuantity))

        XCTAssertEqual(reference.quantity, IngredientReferenceTests.existingQuantity,
                       "Quantity should not be subtracted")
    }

    func testSubtract_differentQuantityType_throwsError() {
        let subtractedQuantity: Quantity = .mass(3)

        XCTAssertThrowsError(try reference.subtract(subtractedQuantity))

        XCTAssertEqual(reference.quantity, IngredientReferenceTests.existingQuantity,
                       "Quantity should not be subtracted")
    }
}

// MARK: - Scale
extension IngredientReferenceTests {
    func testScale_nonNegativeFactor_success() {
        let factor: Double = 1.5

        XCTAssertNoThrow(try reference.scale(factor))

        guard let product = try? IngredientReferenceTests.existingQuantity * factor else {
            XCTFail("Quantity not multiplied properly")
            return
        }

        XCTAssertEqual(reference.quantity, product, "Quantity should be scaled correctly")
    }

    func testScale_negativeResult_throwsError() {
        let factor: Double = -0.5

        XCTAssertThrowsError(try reference.scale(factor))

        XCTAssertEqual(reference.quantity, IngredientReferenceTests.existingQuantity,
                       "Quantity should not be scaled")
    }
}
