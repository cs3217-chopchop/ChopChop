/**
 Represents a parser that parses text into quantities.
 */
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

    /**
     Parses the given unit string and returns a quantity with the given value and unit.
     */
    static func parseQuantity(value: Double, unit: String) -> Quantity? {
        if let unit = volumeWordMap[unit.lowercased()] {
            return try? Quantity(.volume(unit), value: value)
        } else if let unit = massWordMap[unit.lowercased()] {
            return try? Quantity(.mass(unit), value: value)
        } else {
            return try? Quantity(.count, value: value)
        }
    }
}
