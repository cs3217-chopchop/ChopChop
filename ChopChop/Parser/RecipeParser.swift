//
//  Parser.swift
//  ChopChop
//
//  Created by Cao Wenjie on 14/3/21.
//
import Foundation
import NaturalLanguage

class RecipeParser {
    // matches 1., 1), Step 1., Step 1)
    static let stepsIndexRegex = "(Step\\s)?[1-9][0-9]*(\\.|\\))\\s"
    // matches 2 or 2.5
    static let intOrDecimal = "[1-9]\\d*(\\.\\d+)?"
    // matches 2
    static let integer = "[1-9]\\d*"
    // matches 1/2 or 1 / 2
    static let fraction = "[1-9]\\s*/\\s*[1-9]"
    static let whitespace = "\\s+"
    static let optionalWhiteSpace = "\\s*"
    // places all units into a group like (kg|g|cup)
    static let units: String = (Array(UnitsMapping.volumeWordMap.keys) + Array(UnitsMapping.massWordMap.keys))
        .joined(separator: "|")
    /**
     Parses a chunk of instructions into an array of steps. Parsing is done differently depending on
     whether the instructions are already numbered.
     */
    static func parseInstructions(instructions: String) -> [String] {
        let regex = NSRegularExpression(stepsIndexRegex)
        let indexes = regex.matches(in: instructions, options: [],
                                    range: NSRange(location: 0, length: instructions.utf16.count))
        // when instructions are numbered, just parse base on the numbering
        if !indexes.isEmpty {
            var steps = [String]()
            for idx in 1..<indexes.count {
                let startIndex = instructions.index(instructions.startIndex,
                                                    offsetBy: indexes[idx - 1].range.upperBound)
                let endIndex = instructions.index(instructions.startIndex,
                                                  offsetBy: indexes[idx].range.lowerBound - 1)
                steps.append(String(instructions[startIndex...endIndex])
                                .trimmingCharacters(in: .whitespacesAndNewlines))
            }
            let lastStart = instructions.index(instructions.startIndex,
                                               offsetBy: indexes[indexes.count - 1].range.upperBound)
            steps.append(String(instructions[lastStart..<instructions.endIndex])
                            .trimmingCharacters(in: .whitespacesAndNewlines))
            return steps
        // when instructions are not numbered, each sentence is taken as a step
        } else {
            let tokenizer = NLTokenizer(unit: .sentence)
            tokenizer.string = instructions
            return tokenizer.tokens(for: instructions.startIndex..<instructions.endIndex)
                .map({ String(instructions[$0]).trimmingCharacters(in: .whitespaces) })
        }
    }
    /**
     Parse a list of ingredient description into a dictionary of ingredient name and its corresponding quantity.
     */
    static func parseIngredientList(ingredientList: [String]) -> [String: Quantity] {

        var ingredientDict = [String: Quantity]()

        ingredientList.map({ parseIngredient(ingredientText: $0) })
            .forEach({ ingredient in
                ingredientDict[ingredient.name] = ingredient.quantity
            })
        return ingredientDict
    }
    /**
     Parse a ingredient description into a pair of ingredient name and its corresponding quantity
     */
    static func parseIngredient(ingredientText: String) -> (name: String, quantity: Quantity) {
        // checks if the text has both a number and a fraction, e.g. 1 1/2 gram of potato
        var parseResult = matchNumberFractionOptionalUnitFormat(text: ingredientText)
        if let ingredients = parseResult {
            return ingredients
        }
        // checks if the text has either a number or a fraction, e.g. 1 egg, 1/2 lemon
        parseResult = matchNumberOrFractionOptionalUnitFormat(text: ingredientText)
        if let ingredients = parseResult {
            return ingredients
        }

        // case where there is no numerical information about the ingredient, e.g. salt
        return (ingredientText, .count(0))

    }

    private static func matchNumberFractionOptionalUnitFormat(text: String) -> (name: String, quantity: Quantity)? {
        let pattern = groupWithName(pattern: integer, name: "number")
            + whitespace + groupWithName(pattern: fraction, name: "fraction")
            + optionalWhiteSpace + groupWithName(pattern: units, name: "unit", isOptional: true)
            + whitespace + groupWithName(pattern: ".*", name: "ingredient")
        let regex = NSRegularExpression(pattern)
        guard let result =
            regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) else {

            return nil
        }

        guard let numberRange = Range(result.range(withName: "number"), in: text),
              let number = Double(text[numberRange]),
              let fractionRange = Range(result.range(withName: "fraction"), in: text),
              let ingredientRange = Range(result.range(withName: "ingredient"), in: text) else {

            return nil
        }

        var value = number + parseFraction(fraction: String(text[fractionRange]))
        var quantity: Quantity?
        if let unitRange = Range(result.range(withName: "unit"), in: text) {
            let unit = text[unitRange]
            quantity = convertToQuantity(value: &value, unit: String(unit))
        } else {
            quantity = .count(value)
        }

        let ingredient = text[ingredientRange].trimmingCharacters(in: .whitespaces)

        guard let ingredientQuantity = quantity, !ingredient.isEmpty else {
            return nil
        }

        return (ingredient, ingredientQuantity)

    }

    private static func matchNumberOrFractionOptionalUnitFormat(text: String) -> (name: String, quantity: Quantity)? {
        let pattern = groupWithName(pattern: "\(intOrDecimal)|\(fraction)", name: "numeral")
            + optionalWhiteSpace + groupWithName(pattern: units, name: "unit", isOptional: true)
            + whitespace + groupWithName(pattern: ".*", name: "ingredient")

        let regex = NSRegularExpression(pattern)
        guard let result =
            regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) else {

            return nil
        }

        guard let numeralRange = Range(result.range(withName: "numeral"), in: text),
              let ingredientRange = Range(result.range(withName: "ingredient"), in: text) else {
            return nil
        }

        var value: Double = 0
        let numberText = text[numeralRange]
        if isFraction(text: String(numberText)) {
            value = parseFraction(fraction: String(numberText))
        } else if let number = Double(numberText) {
            value = number
        } else {
            return nil
        }

        var quantity: Quantity?
        if let unitRange = Range(result.range(withName: "unit"), in: text) {
            let unit = text[unitRange]
            quantity = convertToQuantity(value: &value, unit: String(unit))
        } else {
            quantity = .count(value)
        }

        let ingredient = text[ingredientRange].trimmingCharacters(in: .whitespaces)

        guard let ingredientQuantity = quantity, !ingredient.isEmpty else {
            return nil
        }

        return (ingredient, ingredientQuantity)
    }

    private static func parseFraction(fraction: String) -> Double {
        let fractionArray = fraction.split(separator: "/")
        if fractionArray.count != 2 {
            return 0
        }
        let numeratorStr = fractionArray[0].trimmingCharacters(in: .whitespaces)
        let denominatorStr = fractionArray[1].trimmingCharacters(in: .whitespaces)

        guard let numerator = Double(numeratorStr), let denominator = Double(denominatorStr) else {
            return 0
        }

        return numerator / denominator
    }

    private static func isFraction(text: String) -> Bool {
        NSRegularExpression(fraction).matches(text)
    }

    private static func convertToQuantity( value: inout Double, unit: String) -> Quantity {
        if let volume = UnitsMapping.volumeWordMap[unit.lowercased()], let factor = UnitsMapping.volumeToL[volume] {
            value *= factor
            return .volume(value)
        } else if let mass = UnitsMapping.massWordMap[unit.lowercased()], let factor = UnitsMapping.massToKg[mass] {
            value *= factor
            return .mass(value)
        } else {
            return .count(value)
        }
    }

    private static func groupWithName(pattern: String, name: String?, isOptional: Bool = false) -> String {
        if let groupName = name {
            return isOptional ? "(?<\(groupName)>\(pattern))?" : "(?<\(groupName)>\(pattern))"
        } else {
            return isOptional ? "(\(pattern))?" : "(\(pattern))"
        }
    }
}
