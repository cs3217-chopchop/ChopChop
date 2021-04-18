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
