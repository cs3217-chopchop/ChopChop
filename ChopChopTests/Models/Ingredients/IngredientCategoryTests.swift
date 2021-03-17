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
