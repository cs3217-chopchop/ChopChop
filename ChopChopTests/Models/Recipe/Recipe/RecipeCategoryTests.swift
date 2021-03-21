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

    func testRename() throws {
        let recipeCategory = try RecipeCategory(id: 1, name: name1)
        try recipeCategory.rename(name2)
        XCTAssertEqual(recipeCategory.name, name2)
    }

    func testRename_noChange() throws {
        let recipeCategory = try RecipeCategory(id: 1, name: name2)
        try recipeCategory.rename(name2WithWhiteSpace)
        XCTAssertEqual(recipeCategory.name, name2)
    }

    func testRename_whiteSpace_fail() throws {
        let recipeCategory = try RecipeCategory(id: 1, name: name1)
        XCTAssertThrowsError(try recipeCategory.rename(whiteSpace))
    }
}
