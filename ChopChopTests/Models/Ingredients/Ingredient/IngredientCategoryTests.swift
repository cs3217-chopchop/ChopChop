import XCTest

@testable import ChopChop

class IngredientCategoryTests: XCTestCase {
    static let categoryName = "Dairy"
    static let categoryId: Int64 = 3_217
    var category: IngredientCategory!

    override func setUpWithError() throws {
        try super.setUpWithError()

        category = try IngredientCategory(
            name: IngredientCategoryTests.categoryName,
            id: IngredientCategoryTests.categoryId)
    }

    override func tearDownWithError() throws {
        category = nil

        try super.tearDownWithError()
    }
}

// MARK: - Construct
extension IngredientCategoryTests {
    func testConstruct_validName_nameTrimmed() throws {
        let validName = "  Dairy\n"
        XCTAssertNoThrow(category = try IngredientCategory(name: validName))

        let trimmedName = validName.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(category.name, trimmedName)
    }

    func testConstruct_invalidName_throwsError() {
        let emptyName = ""
        XCTAssertThrowsError(try IngredientCategory(name: emptyName))

        let invalidName = " \n"
        XCTAssertThrowsError(try IngredientCategory(name: invalidName))
    }
}
