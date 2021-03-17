//
//  Parser.swift
//  ChopChop
//
//  Created by Cao Wenjie on 14/3/21.
//
import Foundation

class RecipeParser {
    static let stepsIndexRegex = "[1-9][0-9]*(\\.|\\))\\s"
    static let intOrDecimal = "[1-9]\\d*(\\.\\d+)?"
    static let integer = "[1-9]\\d*"
    static let fraction = "[1-9]\\s*/\\s*[1-9]"
    static let whitespace = "\\s+"
    static let optionalWhiteSpace = "\\s*"
    static let units: String = (Array(UnitsMapping.volumeWordMap.keys) + Array(UnitsMapping.massWordMap.keys))
        .joined(separator: "|")

    static func parseInstructions(instructions: String) -> [String] {
        let regex = NSRegularExpression(stepsIndexRegex)

        let indexes = regex.matches(in: instructions, options: [],
                                    range: NSRange(location: 0, length: instructions.utf16.count))
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
        } else {
            return instructions.components(separatedBy: ".")
                .dropLast()
                .map({ $0 + "." })
        }
    }

    static func parseIngredientList(ingredientList: [String]) -> [String: Quantity] {

        var ingredientDict = [String: Quantity]()

        ingredientList.map({ parseIngredient(ingredientText: $0) })
            .forEach({ ingredient in
                ingredientDict[ingredient.name] = ingredient.quantity
            })
        return ingredientDict
    }
    
    static func parseIngredient(ingredientText: String) -> (name: String, quantity: Quantity) {

        var parseResult = matchNumberFractionOptionalUnitFormat(text: ingredientText)
        if let ingredients = parseResult {
            return ingredients
        }

        parseResult = matchNumberOrFractionOptionalUnitFormat(text: ingredientText)
        if let ingredients = parseResult {
            return ingredients
        }

        // temporary
        return (ingredientText, .count(1))

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

            print("Incorrect match")
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
            print("Invalid quantity or ingredient")
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

            print("Incorrect match")
            return nil
        }

        var value: Double = 0
        let numberText = text[numeralRange]
        if isFraction(text: String(numberText)) {
            value = parseFraction(fraction: String(numberText))
        } else if let number = Double(numberText) {
            value = number
        } else {
            print("Incorrect match")
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
            print("Invalid quantity or ingredient")
            return nil
        }

        return (ingredient, ingredientQuantity)
    }

    private static func parseFraction(fraction: String) -> Double {
        let fractionArray = fraction.split(separator: "/")
        if fractionArray.count != 2 {
            print("Incorrect fraction format")
            return 0
        }
        let numeratorStr = fractionArray[0].trimmingCharacters(in: .whitespaces)
        let denominatorStr = fractionArray[1].trimmingCharacters(in: .whitespaces)

        guard let numerator = Double(numeratorStr), let denominator = Double(denominatorStr) else {
            print("Incorrect fraction format")
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
            // temp
            return .count(1)
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
