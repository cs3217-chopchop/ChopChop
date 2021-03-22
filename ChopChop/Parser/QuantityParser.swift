//
//  UnitsMapping.swift
//  ChopChop
//
//  Created by Cao Wenjie on 17/3/21.
//

struct QuantityParser {
    static let volumeWordMap: [String: VolumeUnit] = [
        "tablespoon": .tablespoon,
        "tablespoons": .tablespoon,
        "tbsp": .tablespoon,
        "teaspoon": .teaspoon,
        "teaspoons": .teaspoon,
        "tsp": .teaspoon,
        "cup": .cup,
        "cups": .cup,
        "pint": .pint,
        "pints": .pint,
        "pt": .pint,
        "quart": .quart,
        "quarts": .quart,
        "qt": .quart,
        "gallon": .gallon,
        "gallons": .gallon,
        "liter": .liter,
        "liters": .liter,
        "l": .liter,
        "ml": .milliliter,
        "milliliter": .milliliter,
        "milliliters": .milliliter
    ]

    static let massWordMap: [String: MassUnit] = [
        "gram": .gram,
        "grams": .gram,
        "g": .gram,
        "kilogram": .kilogram,
        "kilograms": .kilogram,
        "kg": .kilogram,
        "ounce": .ounce,
        "ounces": .ounce,
        "oz": .ounce,
        "pound": .pound,
        "pounds": .pound,
        "lb": .pound
    ]

    static func parseQuantity( value: Double, unit: String) -> Quantity {
        if let unit = volumeWordMap[unit.lowercased()] {
            do {
                return try Quantity(.volume(unit), value: value)
            } catch {
                fatalError("Invalid quantity")
            }
        } else if let unit = massWordMap[unit.lowercased()] {
            do {
                return try Quantity(.mass(unit), value: value)
            } catch {
                fatalError("Invalid quantity")
            }
        } else {
            do {
                return try Quantity(.count, value: value)
            } catch {
                fatalError("Invalid quantity")
            }
        }
    }
}
