/**
 Represents the quantity of an ingredient.
 */
protocol IngredientQuantity: CustomStringConvertible, Comparable {
    static func + (left: Self, right: Self) throws -> Self
    static func - (left: Self, right: Self) throws -> Self
    static func * (left: Self, right: Double) throws -> Self
    static func / (left: Self, right: Double) throws -> Self
    static func += (left: inout Self, right: Self) throws
    static func -= (left: inout Self, right: Self) throws
    static func *= (left: inout Self, right: Double) throws
    static func /= (left: inout Self, right: Double) throws

    var isZero: Bool { get }
    var type: IngredientQuantityType { get }
}

extension IngredientQuantity {
    static func += (left: inout Self, right: Self) throws {
        let sum = try left + right
        left = sum
    }

    static func -= (left: inout Self, right: Self) throws {
        let difference = try left - right
        left = difference
    }

    static func *= (left: inout Self, right: Double) throws {
        let product = try left * right
        left = product
    }

    static func /= (left: inout Self, right: Double) throws {
        let quotient = try left / right
        left = quotient
    }
}

enum IngredientQuantityType {
    case count
    case volume
    case mass
}

enum IngredientQuantityError: Error {
    case negativeQuantity
    case nonPositiveFactor
}
