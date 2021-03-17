// swiftlint:disable line_length

import XCTest
@testable import ChopChop

class RecipeStepTests: XCTestCase {

    let content = "Meanwhile, whisk cornstarch and cold water together until smooth."
    let contentWithWhiteSpace = "     Meanwhile, whisk cornstarch and cold water together until smooth.     "
    let contentWithTimeTaken = "Select high pressure according to manufacturer's instructions; set timer for 0 minutes. Allow 10 minutes for pressure to build."

    func testConstruct() {
        let recipeStep = RecipeStep(content: content)
        XCTAssertEqual(recipeStep.content, content)

        let recipeStepWithWhiteSpaces = RecipeStep(content: contentWithWhiteSpace)
        XCTAssertEqual(recipeStepWithWhiteSpaces.content, content)
    }

    func testUpdateContent() throws {
        let recipeStep = RecipeStep(content: content)

        try recipeStep.updateContent(contentWithTimeTaken)
        XCTAssertEqual(recipeStep.content, contentWithTimeTaken)
        XCTAssertEqual(recipeStep.timeTaken, 600)

        try recipeStep.updateContent(contentWithWhiteSpace)
        XCTAssertEqual(recipeStep.content, contentWithWhiteSpace, "Should not be trimmed")
        XCTAssertEqual(recipeStep.timeTaken, RecipeStepParser.defaultTime)
    }

}
