import XCTest
@testable import ChopChop

class RecipeCategoryTests: XCTestCase {

    let name1 = "Chinese"
    let name2 = "Indian"
    let name2WithWhiteSpace = "   Indian  "
    let whiteSpace = "      "

    func testConstruct() throws {
        let recipeCategory = try RecipeCategory(name: name1, id: 1)
        XCTAssertEqual(recipeCategory.name, name1)

        let recipeCategory2 = try RecipeCategory(name: name2WithWhiteSpace, id: 2)
        XCTAssertEqual(recipeCategory2.name, name2)
    }

    func testConstruct_whiteSpace_fail() {
        XCTAssertThrowsError(try RecipeCategory(name: whiteSpace, id: 3))
    }

    func testRename() throws {
        let recipeCategory = try RecipeCategory(name: name1, id: 1)
        try recipeCategory.rename(name2)
        XCTAssertEqual(recipeCategory.name, name2)
    }

    func testRename_noChange() throws {
        let recipeCategory = try RecipeCategory(name: name2, id: 1)
        try recipeCategory.rename(name2WithWhiteSpace)
        XCTAssertEqual(recipeCategory.name, name2)
    }

    func testRename_whiteSpace_fail() throws {
        let recipeCategory = try RecipeCategory(name: name1, id: 1)
        XCTAssertThrowsError(try recipeCategory.rename(whiteSpace))
    }
}
