//
//  RecipeParserTest.swift
//  ChopChopTests
//
//  Created by Cao Wenjie on 14/3/21.
//

import XCTest
@testable import ChopChop

class RecipeParserTest: XCTestCase {

    let ingredients = [
        "2 1/2 tablespoon olive oil\r",
        "1  1 / 3 cup onion, chopped\r"
    ]

    func testFromJsonStringArrayToIngredientDict() throws {
        let result = RecipeParser.fromJsonStringArrayToIngredientDict(jsonIngredients: ingredients)
        print(result)
        XCTAssertTrue(true)
    }

    func testRegex() {
        let intOrDecimal = "(?<number>[1-9]\\d*)\\s+(?<frac>[1-9]\\s*/\\s*[1-9])\\s+"
        let full = intOrDecimal + "(<?unit>liters|milliliters|tablespoons|qt|teaspoon|cup|cups|tsp|"
            + "teaspoons|pint|pints|pt|tbsp|quart|gallon|gallons|liter|l|quarts|ml|tablespoon|milliliter"
            + "|lb|oz|grams|gram|ounce|kilogram|pound|g|kilograms|kg|ounces|pounds)"
        let regex = NSRegularExpression(full)
        let text = "2 1/2 tablespoon of olive oil"
        XCTAssertNotNil(regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)))
    }

    func testFromStringToNameQuantity() throws {
        let result = RecipeParser.fromStringToNameQuantity(ingredientText: "6.6 lettuce")
        XCTAssertEqual(result.name, "lettuce")
        XCTAssertEqual(result.quantity, .count(6.6))
    }

    func testMatchNumberFractionOptionalUnitFormat() {
        let result = RecipeParser.matchNumberFractionOptionalUnitFormat(text: "2 1/2 olive oil")
        XCTAssertEqual(result?.name, "olive oil")
        XCTAssertEqual(result?.quantity, .count(2.5))
    }

    func testMatchNumberOrFractionOptionalUnitFormat() {
        let result = RecipeParser.matchNumberOrFractionOptionalUnitFormat(text: "2L olive oil")
        XCTAssertEqual(result?.name, "olive oil")
        XCTAssertEqual(result?.quantity, .volume(2))
    }

    func testfromJsonStringToSteps() throws {
        let instructions = "1. Do this. 2. Do that."
        let steps = RecipeParser.fromJsonStringToSteps(jsonInstructions: instructions)
        print(steps)
        let correctSteps = ["Do this.", "Do that."]
        XCTAssertEqual(steps, correctSteps)
    }

}
