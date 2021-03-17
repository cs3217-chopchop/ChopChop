//
//  UnitsMapping.swift
//  ChopChop
//
//  Created by Cao Wenjie on 17/3/21.
//

struct UnitsMapping {
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
        "kg": "kilogram",
        "ounce": "ounce",
        "ounces": "ounce",
        "oz": "ounce",
        "pound": "pound",
        "pounds": "pound",
        "lb": "pound"
    ]

    static let volumeToL = [
        "milliliter": 0.001,
        "tablespoon": 0.015,
        "teaspoon": 0.005,
        "ounce": 0.03,
        "cup": 0.25,
        "pint": 0.5,
        "quart": 0.95,
        "gallon": 3.8,
        "liter": 1.0
    ]

    static let massToKg = [
        "gram": 0.001,
        "kilogram": 1.0,
        "ounce": 0.028,
        "pound": 0.454
    ]
}
