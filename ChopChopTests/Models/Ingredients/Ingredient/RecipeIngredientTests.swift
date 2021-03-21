import XCTest

@testable import ChopChop

class RecipeIngredientTests: XCTestCase {
    var recipeIngredient: RecipeIngredient!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let existingQuantity = try Quantity(.volume(.baseUnit), value: 0.1)
        recipeIngredient = try RecipeIngredient(
            name: "Sugar",
            quantity: existingQuantity)
    }

    override func tearDownWithError() throws {
        recipeIngredient = nil

        try super.tearDownWithError()
    }
}

// MARK: - Construct
extension RecipeIngredientTests {
    func testConstruct_validName_nameTrimmed() throws {
        let validName = "  Cheese\n"
        let quantity = try Quantity(.count, value: 3)
        XCTAssertNoThrow(recipeIngredient = try RecipeIngredient(name: validName, quantity: quantity))

        let trimmedName = validName.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(recipeIngredient.name, trimmedName)
    }

    func testConstruct_invalidName_throwsError() throws {
        let emptyName = ""
        let quantity = try Quantity(.count, value: 3)
        XCTAssertThrowsError(try RecipeIngredient(name: emptyName, quantity: quantity))

        let invalidName = " \n"
        XCTAssertThrowsError(try RecipeIngredient(name: invalidName, quantity: quantity))
    }
}

// MARK: - Add
extension RecipeIngredientTests {
    func testAdd_sameQuantityType_success() throws {
        let addedQuantity = try Quantity(.volume(.baseUnit), value: 0.2)

        XCTAssertNoThrow(try recipeIngredient.add(addedQuantity))

        let existingQuantity = try Quantity(.volume(.baseUnit), value: 0.1)
        let sum = try? existingQuantity + addedQuantity
        XCTAssertEqual(recipeIngredient.quantity, sum, "Quantities should be added correctly")
    }
}

// MARK: - Subtract
extension RecipeIngredientTests {
    func testSubtract_sameQuantityTypeSufficientQuantity_success() throws {
        let subtractedQuantity = try Quantity(.volume(.baseUnit), value: 0.05)

        XCTAssertNoThrow(try recipeIngredient.subtract(subtractedQuantity))

        let existingQuantity = try Quantity(.volume(.baseUnit), value: 0.1)
        guard let difference = try? existingQuantity - subtractedQuantity else {
            XCTFail("Quantity not subtracted properly")
            return
        }

        XCTAssertEqual(recipeIngredient.quantity, difference, "Quantities should be subtracted correctly")
    }

    func testSubtract_insufficientQuantity_throwsError() throws {
        let subtractedQuantity = try Quantity(.volume(.baseUnit), value: 1)

        XCTAssertThrowsError(try recipeIngredient.subtract(subtractedQuantity))

        let existingQuantity = try Quantity(.volume(.baseUnit), value: 0.1)
        XCTAssertEqual(recipeIngredient.quantity, existingQuantity,
                       "Quantity should not be subtracted")
    }

    func testSubtract_differentQuantityType_throwsError() throws {
        let subtractedQuantity = try Quantity(.mass(.baseUnit), value: 3)

        XCTAssertThrowsError(try recipeIngredient.subtract(subtractedQuantity))

        let existingQuantity = try Quantity(.volume(.baseUnit), value: 0.1)
        XCTAssertEqual(recipeIngredient.quantity, existingQuantity,
                       "Quantity should not be subtracted")
    }
}

// MARK: - Scale
extension RecipeIngredientTests {
    func testScale_nonNegativeFactor_success() throws {
        let factor: Double = 1.5

        XCTAssertNoThrow(try recipeIngredient.scale(factor))

        let existingQuantity = try Quantity(.volume(.baseUnit), value: 0.1)
        guard let product = try? existingQuantity * factor else {
            XCTFail("Quantity not multiplied properly")
            return
        }

        XCTAssertEqual(recipeIngredient.quantity, product, "Quantity should be scaled correctly")
    }

    func testScale_negativeResult_throwsError() throws {
        let factor: Double = -0.5

        XCTAssertThrowsError(try recipeIngredient.scale(factor))

        let existingQuantity = try Quantity(.volume(.baseUnit), value: 0.1)
        XCTAssertEqual(recipeIngredient.quantity, existingQuantity,
                       "Quantity should not be scaled")
    }
}
