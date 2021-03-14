/**
 Represents the quantity of an ingredient.
 */
enum IngredientQuantity {
    case count(Double)
    case mass(Double)
    case volume(Double)

    var isZero: Bool {
        switch self {
        case .count(let value):
            return value == 0
        case .mass(let value):
            return value == 0
        case .volume(let value):
            return value == 0
        }
    }

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
}

// MARK: - Arithmetic operations
extension IngredientQuantity {
    static func + (left: IngredientQuantity, right: IngredientQuantity) throws -> IngredientQuantity {
        switch (left, right) {
        case (.count(let leftValue), .count(let rightValue)):
            let sum = leftValue + rightValue
            guard sum >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .count(sum)
        case (.mass(let leftValue), .mass(let rightValue)):
            let sum = leftValue + rightValue
            guard sum >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .mass(sum)
        case (.volume(let leftValue), .volume(let rightValue)):
            let sum = leftValue + rightValue
            guard sum >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .volume(sum)
        default:
            throw IngredientQuantityError.differentQuantityTypes
        }
    }

    static func - (left: IngredientQuantity, right: IngredientQuantity) throws -> IngredientQuantity {
        switch (left, right) {
        case (.count(let leftValue), .count(let rightValue)):
            let difference = leftValue - rightValue
            guard difference >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .count(difference)
        case (.mass(let leftValue), .mass(let rightValue)):
            let difference = leftValue - rightValue
            guard difference >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .mass(difference)
        case (.volume(let leftValue), .volume(let rightValue)):
            let difference = leftValue - rightValue
            guard difference >= 0 else {
                throw IngredientQuantityError.negativeQuantity
            }
            return .volume(difference)
        default:
            throw IngredientQuantityError.differentQuantityTypes
        }
    }
    
    static func * (left: IngredientQuantity, right: Double) throws -> IngredientQuantity {
        guard right > 0 else {
            throw IngredientQuantityError.nonPositiveFactor
        }

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

    static func / (left: IngredientQuantity, right: Double) throws -> IngredientQuantity {
        guard right > 0 else {
            throw IngredientQuantityError.nonPositiveFactor
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
    static func < (lhs: IngredientQuantity, rhs: IngredientQuantity) throws -> Bool {
        switch (lhs, rhs) {
        case (.count(let leftValue), .count(let rightValue)):
            return leftValue < rightValue
        case (.mass(let leftValue), .mass(let rightValue)):
            return leftValue < rightValue
        case (.volume(let leftValue), .volume(let rightValue)):
            return leftValue < rightValue
        default:
            throw IngredientQuantityError.differentQuantityTypes
        }
    }

    static func == (lhs: IngredientQuantity, rhs: IngredientQuantity) throws -> Bool {
        switch (lhs, rhs) {
        case (.count(let leftValue), .count(let rightValue)):
            return leftValue == rightValue
        case (.mass(let leftValue), .mass(let rightValue)):
            return leftValue == rightValue
        case (.volume(let leftValue), .volume(let rightValue)):
            return leftValue == rightValue
        default:
            throw IngredientQuantityError.differentQuantityTypes
        }
    }

    func isSameType(as quantity: IngredientQuantity) -> Bool {
        self.type == quantity.type
    }
}

enum IngredientQuantityError: Error {
    case negativeQuantity
    case nonPositiveFactor
    case differentQuantityTypes
}

enum IngredientQuantityType {
    case count
    case mass
    case volume
}
