import GRDB

/**
 Represents the quantity of an ingredient.
 
 Invariants:
 - Quantities are non negative.
 
 Mass type quantities are meaasured in kilograms.
 Volume type quantities are measured in litres.
 */
struct Quantity {
    let type: QuantityType
    var value: Double

    init(_ type: QuantityType, value: Double) throws {
        guard value >= 0 else {
            throw QuantityError.negativeQuantity
        }

        self.type = type
        self.value = value
    }

    var unit: String {
        switch type {
        case .count:
            return ""
        case .mass:
            return "kilograms"
        case .volume:
            return "liters"
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
        guard left.type == right.type else {
            throw QuantityError.differentTypes
        }

        let sum = left.value + right.value
        return try Quantity(left.type, value: sum)
    }

    /**
     Returns the result of the right quantity subtracted from the left if they are of the same type.
     - Throws:
        - `QuantityError.differentQuantityTypes`: if the types of the quantities do not match.
        - `QuantityError.negativeQuantity`: if the result is negative.
     */
    static func - (left: Quantity, right: Quantity) throws -> Quantity {
        guard left.type == right.type else {
            throw QuantityError.differentTypes
        }

        let difference = left.value - right.value
        return try Quantity(left.type, value: difference)
    }

    /**
     Returns the quantity scaled with a given factor.
     - Throws:
        - `QuantityError.negativeQuantity`: if the result is negative.
     */
    static func * (left: Quantity, right: Double) throws -> Quantity {
        let product = left.value * right
        return try Quantity(left.type, value: product)
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

        let quotient = left.value / right
        return try Quantity(left.type, value: quotient)
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
        switch type {
        case .count:
            return String(format: "%.1f", value)
        case .mass:
            let valueInKilograms = value

            if valueInKilograms < 1 {
                let valueInGrams = valueInKilograms * 1_000
                return String(format: "%.2f g", valueInGrams)
            }

            return String(format: "%.2f kg", valueInKilograms)
        case .volume:
            let valueInLitres = value

            if valueInLitres < 1 {
                let valueInMillilitres = valueInLitres * 1_000
                return String(format: "%.2f mL", valueInMillilitres)
            }

            return String(format: "%.2f L", valueInLitres)
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
    static func < (lhs: Quantity, rhs: Quantity) -> Bool {
        lhs.value < rhs.value
    }

    /**
     Returns whether the quantities are equal, if they are of the same type.
     If they are of different types, return false.
     */
    static func == (lhs: Quantity, rhs: Quantity) -> Bool {
        lhs.type == rhs.type && lhs.value == rhs.value
    }
}

extension Quantity {
    init(from record: QuantityRecord) throws {
        switch record {
        case .count(let value):
            try self.init(.count, value: value)
        case .mass(let value):
            try self.init(.mass, value: value)
        case .volume(let value):
            try self.init(.volume, value: value)
        }
    }

    var record: QuantityRecord {
        switch type {
        case .count:
            return .count(value)
        case .mass:
            return .mass(value)
        case .volume:
            return .volume(value)
        }
    }
}

enum QuantityError: Error {
    case negativeQuantity
    case divisionByZero
    case differentTypes
}

enum QuantityType: CustomStringConvertible, CaseIterable {
    case count
    case mass
    case volume

    var description: String {
        switch self {
        case .count:
            return "Count"
        case .mass:
            return "Mass"
        case .volume:
            return "Volume"
        }
    }
}
