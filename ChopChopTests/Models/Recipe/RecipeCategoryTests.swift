import XCTest
@testable import ChopChop

class RecipeCategoryTests: XCTestCase {

    let name1 = "Chinese"
    let name2 = "Indian"
    let name2WithWhiteSpace = "   Indian  "
    let whiteSpace = "      "

    func testConstruct() throws {
        let recipeCategory = try RecipeCategory(id: 1, name: name1)
        XCTAssertEqual(recipeCategory.name, name1)

        let recipeCategory2 = try RecipeCategory(id: 2, name: name2WithWhiteSpace)
        XCTAssertEqual(recipeCategory2.name, name2)
    }

    func testConstruct_whiteSpace_fail() {
        XCTAssertThrowsError(try RecipeCategory(id: 3, name: whiteSpace))
    }
}
