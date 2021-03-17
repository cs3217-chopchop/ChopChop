import XCTest
@testable import ChopChop

class RecipeCategoryTests: XCTestCase {

    let name = "Chinese"
    let name2 = "Indian"
    let name2WithWhiteSpace = "   Indian  "
    let whiteSpace = "      "

    func testConstruct() {
        let recipeCategory = RecipeCategory(id: 1, name: name)
        XCTAssertEqual(recipeCategory.name, name)

        let recipeCategory2 = RecipeCategory(id: 2, name: name2WithWhiteSpace)
        XCTAssertEqual(recipeCategory.name, name2)
    }

    func testConstruct_whiteSpace_fail() {
        XCTAssertThrowsError(RecipeCategory(id: 3, name: whiteSpace))
    }

    func testUpdateName() {
        let recipeCategory = RecipeCategory(id: 1, name: name)
        recipeCategory.updateName(name2)
        XCTAssertEqual(recipeCategory.name, name2)
    }

    func testUpdateName_noChange() {
        let recipeCategory = RecipeCategory(id: 1, name: name2)
        recipeCategory.updateName(name2WithWhiteSpace)
        XCTAssertEqual(recipeCategory.name, name2)
    }

    func testUpdateName_whiteSpace_fail() {
        let recipeCategory = RecipeCategory(id: 1, name: name)
        XCTAssertThrowsError(recipeCategory.updateName(whiteSpace))
    }
}
