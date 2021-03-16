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
            "olive oil": .volume(0.015 * 2),
            "lemon, juiced": .count(1)
        ]
        XCTAssertEqual(result, right)
    }

    func testParseIngredient_fractionWithVolume() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "1/4 tsp ground cloves")
        XCTAssertEqual(result.name, "ground cloves")
        XCTAssertEqual(result.quantity, .volume(0.005 * 0.25))
    }

    func testParseIngredient_fractionWithCount() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "1/4 nutmeg, grated")
        XCTAssertEqual(result.name, "nutmeg, grated")
        XCTAssertEqual(result.quantity, .count(0.25))
    }

    func testParseIngredient_fractionWithMass() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "1/4 tsp ground cloves")
        XCTAssertEqual(result.name, "ground cloves")
        XCTAssertEqual(result.quantity, .volume(0.005 * 0.25))
    }

    func testParseIngredient_integerFractionWithCount() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "2 1/2 4.0kg pork escalopes")
        XCTAssertEqual(result.name, "4.0kg pork escalopes")
            XCTAssertEqual(result.quantity, .count(2.5))
    }

    func testParseIngredient_integerSpaceWithVolume() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "2 teaspoon sesame oil")
        XCTAssertEqual(result.name, "sesame oil")
        XCTAssertEqual(result.quantity, .volume(0.005 * 2))
    }

    func testParseIngredient_integerNoSpaceWithVolume() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "2tsp sesame oil")
        XCTAssertEqual(result.name, "sesame oil")
        XCTAssertEqual(result.quantity, .volume(0.005 * 2))
    }

    func testParseIngredient_decimalSpaceWithMass() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "2.5 g butter")
        XCTAssertEqual(result.name, "butter")
        XCTAssertEqual(result.quantity, .mass(0.001 * 2.5))
    }

    func testParseIngredient_decimalNoSpaceWithMass() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "19.0kg ground beef")
        XCTAssertEqual(result.name, "ground beef")
        XCTAssertEqual(result.quantity, .mass(19.0))
    }

    func testParseIngredient_noQuantity() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "Salt and pepper")
        XCTAssertEqual(result.name, "Salt and pepper")
        XCTAssertEqual(result.quantity, .count(1))
    }

    func testParseIngredient_invalidFraction() throws {
        let result = RecipeParser.parseIngredient(ingredientText: "0/0 tsp ground cloves")
        XCTAssertEqual(result.name, "0/0 tsp ground cloves")
        XCTAssertEqual(result.quantity, .count(1))
    }

    func testfromJsonStringToSteps() throws {
        let instructions = "1. Do this. 2. Do that."
        let steps = RecipeParser.fromJsonStringToSteps(jsonInstructions: instructions)
        print(steps)
        let correctSteps = ["Do this.", "Do that."]
        XCTAssertEqual(steps, correctSteps)
    }

}
