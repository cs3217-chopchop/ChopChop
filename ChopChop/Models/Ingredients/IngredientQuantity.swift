/**
 Represents the quantity of an ingredient.
 
 Invariants:
 - Quantities are non negative.
 
 Mass type quantities are meaasured in kilograms.
 Volume type quantities are measured in litres.
 */
enum IngredientQuantity {
    case count(Double)
    case mass(Double)
    case volume(Double)

    var type: IngredientQuantityType {
        switch self {
        case .count:
            return .count
        case .mass:
            return .mass
        case .volume:
            return .volume
        }
    }

    var value: Double {
        get {
            switch self {
            case .count(let value):
                return value
            case .mass(let value):
                return value
            case .volume(let value):
                return value
            }
        }
        set {
            switch self {
            case .count:
                self = .count(newValue)
            case .mass:
                self = .mass(newValue)
            case .volume:
                self = .volume(newValue)
            }
        }
    }
}

// MARK: - Arithmetic operations
extension IngredientQuantity {
    /**
     Returns the sum of two quantities if they are of the same type.
     - Throws:
        - `IngredientQuantityError.differentQuantityTypes`: if the types of the quantities do not match.
        - `IngredientQuantityError.negativeQuantity`: if the result is negative.
     */
    static func + (left: IngredientQuantity, right: IngredientQuantity) throws -> IngredientQuantity {
        switch (left, right) {
        case let (.count(leftValue), .count(rightValue)):
            let sum = leftValue + rightValue
            guard sum >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .count(sum)
        case let (.mass(leftValue), .mass(rightValue)):
            let sum = leftValue + rightValue
            guard sum >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .mass(sum)
        case let (.volume(leftValue), .volume(rightValue)):
            let sum = leftValue + rightValue
            guard sum >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .volume(sum)
        default:
            throw IngredientQuantityError.differentQuantityTypes
        }
    }

    /**
     Returns the result of the right quantity subtracted from the left if they are of the same type.
     - Throws:
        - `IngredientQuantityError.differentQuantityTypes`: if the types of the quantities do not match.
        - `IngredientQuantityError.negativeQuantity`: if the result is negative.
     */
    static func - (left: IngredientQuantity, right: IngredientQuantity) throws -> IngredientQuantity {
        switch (left, right) {
        case let (.count(leftValue), .count(rightValue)):
            let difference = leftValue - rightValue
            guard difference >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .count(difference)
        case let (.mass(leftValue), .mass(rightValue)):
            let difference = leftValue - rightValue
            guard difference >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .mass(difference)
        case let (.volume(leftValue), .volume(rightValue)):
            let difference = leftValue - rightValue
            guard difference >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .volume(difference)
        default:
            throw IngredientQuantityError.differentQuantityTypes
        }
    }

    /**
     Returns the quantity scaled with a given factor.
     - Throws:
        - `IngredientQuantityError.negativeQuantity`: if the result is negative.
     */
    static func * (left: IngredientQuantity, right: Double) throws -> IngredientQuantity {
        switch left {
        case .count(let value):
            let product = value * right
            guard product >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .count(product)
        case .mass(let value):
            let product = value * right
            guard product >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .mass(product)
        case .volume(let value):
            let product = value * right
            guard product >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .volume(product)
        }
    }

    /**
     Returns the quantity divided by a given factor.
     - Throws:
        - `IngredientQuantityError.divisionByZero`: if the given factor is 0.
        - `IngredientQuantityError.negativeQuantity`: if the result is negative.
     */
    static func / (left: IngredientQuantity, right: Double) throws -> IngredientQuantity {
        guard right != 0 else {
            throw IngredientQuantityError.divisionByZero
        }

        switch left {
        case .count(let value):
            let quotient = value / right
            guard quotient >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .count(quotient)
        case .mass(let value):
            let quotient = value / right
            guard quotient >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .mass(quotient)
        case .volume(let value):
            let quotient = value / right
            guard quotient >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .volume(quotient)
        }
    }

    static func += (left: inout IngredientQuantity, right: IngredientQuantity) throws {
        let sum = try left + right
        left = sum
    }

    static func -= (left: inout IngredientQuantity, right: IngredientQuantity) throws {
        let difference = try left - right
        left = difference
    }

    static func *= (left: inout IngredientQuantity, right: Double) throws {
        let product = try left * right
        left = product
    }

    static func /= (left: inout IngredientQuantity, right: Double) throws {
        let quotient = try left / right
        left = quotient
    }
}

// MARK: - CustomStringConvertible
extension IngredientQuantity: CustomStringConvertible {
    var description: String {
        switch self {
        case .count(let value):
            let precision = 1
            return String(format: "%.\(precision)f", value)
        case .mass(let value), .volume(let value):
            let precision = 2
            return String(format: "%.\(precision)f", value)
        }
    }
}

// MARK: - Comparable
extension IngredientQuantity: Comparable {
    /**
     Returns whether the left quantity is smaller than the right, if they are of the same type.
     - Throws:
        - `IngredientQuantityError.differentQuantityTypes`: if the types of the quantities do not match.
     */
    static func < (lhs: IngredientQuantity, rhs: IngredientQuantity) throws -> Bool {
        switch (lhs, rhs) {
        case let (.count(leftValue), .count(rightValue)):
            return leftValue < rightValue
        case let(.mass(leftValue), .mass(rightValue)):
            return leftValue < rightValue
        case let (.volume(leftValue), .volume(rightValue)):
            return leftValue < rightValue
        default:
            throw IngredientQuantityError.differentQuantityTypes
        }
    }

    /**
     Returns whether the quantities are equal, if they are of the same type.
     If they are of different types, return false.
     */
    static func == (lhs: IngredientQuantity, rhs: IngredientQuantity) -> Bool {
        switch (lhs, rhs) {
        case let (.count(leftValue), .count(rightValue)):
            return leftValue == rightValue
        case let (.mass(leftValue), .mass(rightValue)):
            return leftValue == rightValue
        case let (.volume(leftValue), .volume(rightValue)):
            return leftValue == rightValue
        default:
            return false
        }
    }
}

enum IngredientQuantityError: Error {
    case negativeQuantity
    case divisionByZero
    case differentQuantityTypes
}

enum IngredientQuantityType {
    case count
    case mass
    case volume
}
