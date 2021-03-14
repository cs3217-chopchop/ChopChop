//
//  Parser.swift
//  ChopChop
//
//  Created by Cao Wenjie on 14/3/21.
//

class RecipeParser {
    static let volumeWordMap = [
        "tablespoon": "tablespoon",
        "tablespoons": "tablespoon",
        "tbsp": "tablespoon",
        "teaspoon": "teaspoon",
        "teaspoons": "teaspoon",
        "tsp": "teaspoon",
        "cup": "cup",
        "cups": "cup",
        "pint": "pint",
        "pints": "pint",
        "pt": "pint",
        "quart": "quart",
        "quarts": "quart",
        "qt": "quart",
        "gallon": "gallon",
        "gallons": "gallon",
        "liter": "liter",
        "liters": "liter",
        "l": "liter",
        "ml": "milliliter",
        "milliliter": "milliliter",
        "milliliters": "milliliter"
    ]
    
    static let massWordMap = [
        "gram": "gram",
        "grams": "gram",
        "g": "gram",
        "kilogram": "kilogram",
        "kilograms": "kilogram",
        "kg": "kg",
        "ounce": "ounce",
        "ounces": "ounce",
        "oz": "ounce",
        "pound": "pound",
        "pounds": "pound",
        "lb": "pound"
    ]
    
    static let volumeToMl = [
        "milliliter": 1,
        "tablespoon": 15,
        "teaspoon": 5,
        "ounce": 30,
        "cup": 250,
        "pint": 500,
        "quart": 950,
        "gallon": 3800,
        "liter": 1000
    ]
    
    static let massToG = [
        "gram": 1,
        "kilogram": 1000,
        "ounce": 28,
        "pound": 454
    ]
    
    static func fromJsonStringToSteps(jsonInstructions: String) -> [String] {
        return jsonInstructions.components(separatedBy: "\r\n\r\n")
    }
    
    static func fromJsonStringArrayToIngredientDict(jsonIngredients: [String]) -> [String: Quantity?] {
        
        var ingredientDict = [String: Quantity]()
        
        jsonIngredients.map({ fromStringToNameQuantity(ingredientText: $0) })
            .forEach({ ingredientDict[$0] = $1 })
        return ingredientDict
    }
    
    static private func fromStringToNameQuantity(ingredientText: String) -> (name: String, quantity: Quantity?) {
        let wordArray = ingredientText.split(separator: " ")
        let len = wordArray.count
        
        var value = 0
        var valueIndex = 0
        var valueFound = false
        
        for idx in 0..<len {
            if let number = Int(wordArray[idx]) {
                value = number
                valueIndex = idx
                valueFound = true
                break
            }
        }
        
        if !valueFound {
            return (ingredientText, nil)
        }
        
        var measurementIndex = 0
        var measurementFound = false
        var quantity: Quantity?
        
        for idx in (valueIndex + 1)..<len {
            if let volume = volumeWordMap[String(wordArray[idx]).lowercased()], let factor = volumeToMl[volume] {
                value *= factor
                measurementIndex = idx
                quantity = .volume(Double(value))
                measurementFound = true
                break
            } else if let mass = massWordMap[String(wordArray[idx]).lowercased()], let factor = massToG[mass] {
                value *= factor
                measurementIndex = idx
                quantity = .mass(Double(value))
                measurementFound = true
                break
            }
        }
        
        if measurementFound {
            let name = wordArray.dropFirst(measurementIndex + 1).joined(separator: " ")
            return (name, quantity)
        } else {
            quantity = .count(Double(value))
            let name = wordArray.dropFirst(valueIndex + 1).joined(separator: " ")
            return (name, quantity)
        }
    }
}
