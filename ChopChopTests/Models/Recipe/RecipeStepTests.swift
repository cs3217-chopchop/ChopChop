import XCTest
@testable import ChopChop

class RecipeStepTests: XCTestCase {

    let content = "Meanwhile, whisk cornstarch and cold water together until smooth."
    let contentWithWhiteSpace = "     Meanwhile, whisk cornstarch and cold water together until smooth.     "
    let contentWithTimeTaken = """
Select high pressure according to manufacturer's instructions; set timer for 0 minutes. \
Allow 10 minutes for pressure to build.
"""

    func testConstruct() throws {
        let recipeStep = try RecipeStep(content)
        XCTAssertEqual(recipeStep.content, content)

        let recipeStepWithWhiteSpaces = try RecipeStep(contentWithWhiteSpace)
        XCTAssertEqual(recipeStepWithWhiteSpaces.content, content)
        XCTAssertEqual(recipeStep.timeTaken, RecipeStepParser.defaultTime)
    }
}
