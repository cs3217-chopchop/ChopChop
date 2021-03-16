/**
 Represents the quantity of an ingredient.
 
 Invariants:
 - Quantities are non negative.
 
 Mass type quantities are meaasured in kilograms.
 Volume type quantities are measured in litres.
 */
enum Quantity {
    case count(Double)
    case mass(Double)
    case volume(Double)

    var type: QuantityType {
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
extension Quantity {
    /**
     Returns the sum of two quantities if they are of the same type.
     - Throws:
        - `QuantityError.differentQuantityTypes`: if the types of the quantities do not match.
        - `QuantityError.negativeQuantity`: if the result is negative.
     */
    static func + (left: Quantity, right: Quantity) throws -> Quantity {
        switch (left, right) {
        case let (.count(leftValue), .count(rightValue)):
            let sum = leftValue + rightValue
            guard sum >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .count(sum)
        case let (.mass(leftValue), .mass(rightValue)):
            let sum = leftValue + rightValue
            guard sum >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .mass(sum)
        case let (.volume(leftValue), .volume(rightValue)):
            let sum = leftValue + rightValue
            guard sum >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .volume(sum)
        default:
            throw QuantityError.differentTypes
        }
    }

    /**
     Returns the result of the right quantity subtracted from the left if they are of the same type.
     - Throws:
        - `QuantityError.differentQuantityTypes`: if the types of the quantities do not match.
        - `QuantityError.negativeQuantity`: if the result is negative.
     */
    static func - (left: Quantity, right: Quantity) throws -> Quantity {
        switch (left, right) {
        case let (.count(leftValue), .count(rightValue)):
            let difference = leftValue - rightValue
            guard difference >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .count(difference)
        case let (.mass(leftValue), .mass(rightValue)):
            let difference = leftValue - rightValue
            guard difference >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .mass(difference)
        case let (.volume(leftValue), .volume(rightValue)):
            let difference = leftValue - rightValue
            guard difference >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .volume(difference)
        default:
            throw QuantityError.differentTypes
        }
    }

    /**
     Returns the quantity scaled with a given factor.
     - Throws:
        - `QuantityError.negativeQuantity`: if the result is negative.
     */
    static func * (left: Quantity, right: Double) throws -> Quantity {
        switch left {
        case .count(let value):
            let product = value * right
            guard product >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .count(product)
        case .mass(let value):
            let product = value * right
            guard product >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .mass(product)
        case .volume(let value):
            let product = value * right
            guard product >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .volume(product)
        }
    }

    /**
     Returns the quantity divided by a given factor.
     - Throws:
        - `QuantityError.divisionByZero`: if the given factor is 0.
        - `QuantityError.negativeQuantity`: if the result is negative.
     */
    static func / (left: Quantity, right: Double) throws -> Quantity {
        guard right != 0 else {
            throw QuantityError.divisionByZero
        }

        switch left {
        case .count(let value):
            let quotient = value / right
            guard quotient >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .count(quotient)
        case .mass(let value):
            let quotient = value / right
            guard quotient >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .mass(quotient)
        case .volume(let value):
            let quotient = value / right
            guard quotient >= 0 else {
                throw QuantityError.negativeQuantity
            }
            return .volume(quotient)
        }
    }

    static func += (left: inout Quantity, right: Quantity) throws {
        let sum = try left + right
        left = sum
    }

    static func -= (left: inout Quantity, right: Quantity) throws {
        let difference = try left - right
        left = difference
    }

    static func *= (left: inout Quantity, right: Double) throws {
        let product = try left * right
        left = product
    }

    static func /= (left: inout Quantity, right: Double) throws {
        let quotient = try left / right
        left = quotient
    }
}

// MARK: - CustomStringConvertible
extension Quantity: CustomStringConvertible {
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
extension Quantity: Comparable {
    /**
     Returns whether the left quantity is smaller than the right, if they are of the same type.
     - Throws:
        - `QuantityError.differentQuantityTypes`: if the types of the quantities do not match.
     */
    static func < (lhs: Quantity, rhs: Quantity) throws -> Bool {
        switch (lhs, rhs) {
        case let (.count(leftValue), .count(rightValue)):
            return leftValue < rightValue
        case let(.mass(leftValue), .mass(rightValue)):
            return leftValue < rightValue
        case let (.volume(leftValue), .volume(rightValue)):
            return leftValue < rightValue
        default:
            throw QuantityError.differentTypes
        }
    }

    /**
     Returns whether the quantities are equal, if they are of the same type.
     If they are of different types, return false.
     */
    static func == (lhs: Quantity, rhs: Quantity) -> Bool {
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

enum QuantityError: Error {
    case negativeQuantity
    case divisionByZero
    case differentTypes
}

enum QuantityType {
    case count
    case mass
    case volume
}
