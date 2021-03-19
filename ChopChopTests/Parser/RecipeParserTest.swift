//
//  RecipeParserTest.swift
//  ChopChopTests
//
//  Created by Cao Wenjie on 14/3/21.
//

import XCTest
@testable import ChopChop

class RecipeParserTest: XCTestCase {

    func testParseIngredientList() throws {
        let ingredients = [
            "2 tablespoon olive oil",
            "1 lemon, juiced"
        ]
        let result = RecipeParser.parseIngredientList(ingredientList: ingredients)
        let right: [String: Quantity] = [
            "olive oil": try Quantity(.volume, value: 0.03),
            "lemon, juiced": try Quantity(.count, value: 1)
        ]
        XCTAssertEqual(result, right)
    }

    func testParseIngredient_fractionWithVolume() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "1/4 tsp ground cloves")
        XCTAssertEqual(result.name, "ground cloves")
        XCTAssertEqual(result.quantity, try Quantity(.volume, value: 0.001_25))
    }

    func testParseIngredient_fractionWithCount() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "1/4 nutmeg, grated")
        XCTAssertEqual(result.name, "nutmeg, grated")
        XCTAssertEqual(result.quantity, try Quantity(.count, value: 0.25))
    }

    func testParseIngredient_fractionWithMass() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "1/4 tsp ground cloves")
        XCTAssertEqual(result.name, "ground cloves")
        XCTAssertEqual(result.quantity, try Quantity(.volume, value: 0.001_25))
    }

    func testParseIngredient_integerFractionWithCount() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "2 1/2 4.0kg pork escalopes")
        XCTAssertEqual(result.name, "4.0kg pork escalopes")
        XCTAssertEqual(result.quantity, try Quantity(.count, value: 2.5))
    }

    func testParseIngredient_integerSpaceWithVolume() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "2 teaspoon sesame oil")
        XCTAssertEqual(result.name, "sesame oil")
        XCTAssertEqual(result.quantity, try Quantity(.volume, value: 0.01))
    }

    func testParseIngredient_integerNoSpaceWithVolume() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "2tsp sesame oil")
        XCTAssertEqual(result.name, "sesame oil")
        XCTAssertEqual(result.quantity, try Quantity(.volume, value: 0.01))
    }

    func testParseIngredient_decimalSpaceWithMass() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "2.5 g butter")
        XCTAssertEqual(result.name, "butter")
        XCTAssertEqual(result.quantity, try Quantity(.mass, value: 0.002_5))
    }

    func testParseIngredient_decimalNoSpaceWithMass() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "19.0kg ground beef")
        XCTAssertEqual(result.name, "ground beef")
        XCTAssertEqual(result.quantity, try Quantity(.mass, value: 19))
    }

    func testParseIngredient_noQuantity() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "Salt and pepper")
        XCTAssertEqual(result.name, "Salt and pepper")
        XCTAssertEqual(result.quantity, try Quantity(.count, value: 0))
    }

    func testParseIngredient_invalidFraction() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "0/0 tsp ground cloves")
        XCTAssertEqual(result.name, "0/0 tsp ground cloves")
        XCTAssertEqual(result.quantity, try Quantity(.count, value: 0))
    }

    func testParseIngredient_removeConnector() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "1 kg of ground cloves")
        XCTAssertEqual(result.name, "ground cloves")
        XCTAssertEqual(result.quantity, try Quantity(.mass, value: 1))
    }

    func testParseInstructions_withNewLine() throws {
        let instructions = "First Step.\nSecond Step.\nLast Step."
        let steps = RecipeParser.parseInstructions(instructions: instructions)
        let correctSteps = ["First Step.", "Second Step.", "Last Step."]
        XCTAssertEqual(steps, correctSteps)
    }

    func testParseInstructions_trimNewLine() throws {
        let instructions = "\n\n1. First Step. 2. Second Step. 3. Last Step.\n\n"
        let steps = RecipeParser.parseInstructions(instructions: instructions)
        let correctSteps = ["First Step.", "Second Step.", "Last Step."]
        XCTAssertEqual(steps, correctSteps)
    }

    func testParseInstructions_withIndexDot() throws {
        let instructions = "1. First Step. 2. Second Step. 3. Last Step."
        let steps = RecipeParser.parseInstructions(instructions: instructions)
        let correctSteps = ["First Step.", "Second Step.", "Last Step."]
        XCTAssertEqual(steps, correctSteps)
    }

    func testParseInstructions_withIndexBracket() throws {
        let instructions = "1) First Step. 2) Second Step. 3) Last Step."
        let steps = RecipeParser.parseInstructions(instructions: instructions)
        print(steps)
        let correctSteps = ["First Step.", "Second Step.", "Last Step."]
        XCTAssertEqual(steps, correctSteps)
    }

    func testParseInstructions_withStep() throws {
        let instructions = "Step 1) Wash apple. Step 2. Cut them. Step 3. Eat."
        let steps = RecipeParser.parseInstructions(instructions: instructions)
        print(steps)
        let correctSteps = ["Wash apple.", "Cut them.", "Eat."]
        XCTAssertEqual(steps, correctSteps)
    }

    func testParseInstructions_oneStep() throws {
        let instructions = "1. First Step."
        let steps = RecipeParser.parseInstructions(instructions: instructions)
        let correctSteps = ["First Step."]
        XCTAssertEqual(steps, correctSteps)
    }

    func testParseInstructions_withoutIndex() throws {
        let instructions = "In a non-reactive dish, combine the lemon juice, olive oil and mix together. "
            + "To cook the chicken: Heat a nonstick skillet or grill pan over high heat. "
            + "Add the chicken breasts and cook on each side or until cooked through."
        let steps = RecipeParser.parseInstructions(instructions: instructions)
        let correctSteps = [
            "In a non-reactive dish, combine the lemon juice, olive oil and mix together.",
            "To cook the chicken: Heat a nonstick skillet or grill pan over high heat.",
            "Add the chicken breasts and cook on each side or until cooked through."
        ]
        XCTAssertEqual(steps, correctSteps)
    }

    func testParseInstructions_oneSentence() throws {
        let instructions = "In a non-reactive dish, combine the lemon juice, olive oil and mix together."
        let steps = RecipeParser.parseInstructions(instructions: instructions)
        let correctSteps = [
            "In a non-reactive dish, combine the lemon juice, olive oil and mix together."
        ]
        XCTAssertEqual(steps, correctSteps)
    }

}
