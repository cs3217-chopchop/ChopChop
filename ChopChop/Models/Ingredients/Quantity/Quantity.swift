import Foundation
import GRDB

/**
 Represents the quantity of an ingredient.
 
 Representation Invariants:
 - Value of the quantity is non negative.
 */
struct Quantity: Equatable {
    // MARK: - Specification Fields
    /// The unit of the quantity, which can be of three types: count, mass or volume.
    let unit: QuantityUnit
    /// The magnitude of the quantity. Must be non negative.
    var value: Double

    /**
     Instantiates a quantity with the given value, expressed in terms of the given unit.

     - Throws:`QuantityError.negativeQuantity` if the given quantity is negative.
     */
    init(_ unit: QuantityUnit, value: Double) throws {
        guard value >= 0 else {
            throw QuantityError.negativeQuantity
        }

        self.unit = unit
        self.value = value
    }

    /// The type of the unit of the quantity.
    var type: QuantityType {
        unit.type
    }

    /// The value of the quantity converted to the base unit of its type.
    var baseValue: Double {
        switch unit {
        case .count:
            return value
        case .mass(let unit):
            return MassUnit.convert(value, from: unit, to: .baseUnit)
        case .volume(let unit):
            return VolumeUnit.convert(value, from: unit, to: .baseUnit)
        }
    }

    // MARK: - Arithmetic Operations

    /**
     Returns the sum of two quantities.

     - Requires:
        - Either quantity has 0 value
        - OR Both quantities have type `count`.
        - OR Both quantities do not have type `count`.

     - Throws:
        - `QuantityError.incompatibleTypes`: if the types of the quantities are not compatible.
        - `QuantityError.negativeQuantity`: if the resultant quantity is negative.

     - Returns: The sum of the two quantities.
        - If both quantities have the same type that is not `count`:
            - If both quantities are in metric or non metric units, the sum is expressed in terms of the bigger unit.
            - If one quantity is in metric units while the other is not,
            the sum is expressed in terms of the base unit of that type.
        - If both quantities have different types that are not `count`:
            - The sum is expressed in terms of the left operand's units.
     */
    static func + (left: Quantity, right: Quantity) throws -> Quantity {
        guard left.value != 0 else {
            return right
        }

        guard right.value != 0 else {
            return left
        }

        switch (left.unit, right.unit) {
        case (.count, .count):
            let sum = left.value + right.value
            return try Quantity(.count, value: sum)
        case let (.mass(leftUnit), .mass(rightUnit)) where leftUnit.isMetric == rightUnit.isMetric:
            let unit = max(leftUnit, rightUnit)

            let leftValue = MassUnit.convert(left.value, from: leftUnit, to: unit)
            let rightValue = MassUnit.convert(right.value, from: rightUnit, to: unit)

            let sum = leftValue + rightValue
            return try Quantity(.mass(unit), value: sum)
        case let (.mass(leftUnit), .mass(rightUnit)) where leftUnit.isMetric != rightUnit.isMetric:
            let leftValue = MassUnit.convert(left.value, from: leftUnit, to: .baseUnit)
            let rightValue = MassUnit.convert(right.value, from: rightUnit, to: .baseUnit)

            let sum = leftValue + rightValue
            return try Quantity(.mass(.kilogram), value: sum)
        case let (.volume(leftUnit), .volume(rightUnit)) where leftUnit.isMetric == rightUnit.isMetric:
            let unit = max(leftUnit, rightUnit)

            let leftValue = VolumeUnit.convert(left.value, from: leftUnit, to: unit)
            let rightValue = VolumeUnit.convert(right.value, from: rightUnit, to: unit)

            let sum = leftValue + rightValue
            return try Quantity(.volume(unit), value: sum)
        case let (.volume(leftUnit), .volume(rightUnit)) where leftUnit.isMetric != rightUnit.isMetric:
            let leftValue = VolumeUnit.convert(left.value, from: leftUnit, to: .baseUnit)
            let rightValue = VolumeUnit.convert(right.value, from: rightUnit, to: .baseUnit)

            let sum = leftValue + rightValue
            return try Quantity(.volume(.liter), value: sum)
        case let (.mass(massUnit), .volume(volumeUnit)):
            let rightValue = VolumeUnit.convertToMass(right.value, from: volumeUnit, to: massUnit)

            let sum = left.value + rightValue
            return try Quantity(.mass(massUnit), value: sum)
        case let (.volume(volumeUnit), .mass(massUnit)):
            let rightValue = MassUnit.convertToVolume(right.value, from: massUnit, to: volumeUnit)

            let sum = left.value + rightValue
            return try Quantity(.volume(volumeUnit), value: sum)
        default:
            throw QuantityError.incompatibleTypes
        }
    }

    static func += (left: inout Quantity, right: Quantity) throws {
        let sum = try left + right
        left = sum
    }

    /**
     Returns the result of the right quantity subtracted from the left.

     - Requires:
        - Either quantity has 0 value
        - OR Both quantities have type `count`.
        - OR Both quantities do not have type `count`.

     - Throws:
        - `QuantityError.incompatibleTypes`: if the types of the quantities are not compatible.
        - `QuantityError.negativeQuantity`: if the result is negative.

     - Returns: The difference of the two quantities, expressed in terms of the left operand's units.
     */
    static func - (left: Quantity, right: Quantity) throws -> Quantity {
        guard right.value != 0 else {
            return left
        }

        switch (left.unit, right.unit) {
        case (.count, .count):
            let difference = left.value - right.value
            return try Quantity(.count, value: difference)
        case let (.mass(leftUnit), .mass(rightUnit)):
            let rightValue = MassUnit.convert(right.value, from: rightUnit, to: leftUnit)

            let difference = left.value - rightValue
            return try Quantity(.mass(leftUnit), value: difference)
        case let (.volume(leftUnit), .volume(rightUnit)):
            let rightValue = VolumeUnit.convert(right.value, from: rightUnit, to: leftUnit)

            let difference = left.value - rightValue
            return try Quantity(.volume(leftUnit), value: difference)
        case let (.mass(massUnit), .volume(volumeUnit)):
            let rightValue = VolumeUnit.convertToMass(right.value, from: volumeUnit, to: massUnit)

            let difference = left.value - rightValue
            return try Quantity(.mass(massUnit), value: difference)
        case let (.volume(volumeUnit), .mass(massUnit)):
            let rightValue = MassUnit.convertToVolume(right.value, from: massUnit, to: volumeUnit)

            let difference = left.value - rightValue
            return try Quantity(.volume(volumeUnit), value: difference)
        default:
            throw QuantityError.incompatibleTypes
        }
    }

    static func -= (left: inout Quantity, right: Quantity) throws {
        let difference = try left - right
        left = difference
    }

    /**
     Returns the quantity scaled with the given factor.

     - Throws:
        - `QuantityError.negativeQuantity`: if the result is negative.
     */
    static func * (left: Quantity, right: Double) throws -> Quantity {
        let product = left.value * right
        return try Quantity(left.unit, value: product)
    }

    static func *= (left: inout Quantity, right: Double) throws {
        let product = try left * right
        left = product
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
        return try Quantity(left.unit, value: quotient)
    }

    static func /= (left: inout Quantity, right: Double) throws {
        let quotient = try left / right
        left = quotient
    }

    /**
     Returns whether the left quantity is strictly lesser than the right, if they are of compatible types.

     - Requires:
        - Either quantity has 0 value
        - OR Both quantities have type `count`.
        - OR Both quantities do not have type `count`.

     - Throws:
        - `QuantityError.incompatibleTypes`: if the types of the quantities do not match.
     */
    static func < (left: Quantity, right: Quantity) throws -> Bool {
        guard right.value != 0 else {
            return false
        }

        guard left.value != 0 else {
            return true
        }

        var rightValue: Double

        switch (left.unit, right.unit) {
        case (.count, .count):
            rightValue = right.value

        case let (.mass(leftUnit), .mass(rightUnit)):
            rightValue = MassUnit.convert(right.value, from: rightUnit, to: leftUnit)

        case let (.volume(leftUnit), .volume(rightUnit)):
            rightValue = VolumeUnit.convert(right.value, from: rightUnit, to: leftUnit)

        case let (.mass(massUnit), .volume(volumeUnit)):
            rightValue = VolumeUnit.convertToMass(right.value, from: volumeUnit, to: massUnit)

        case let (.volume(volumeUnit), .mass(massUnit)):
            rightValue = MassUnit.convertToVolume(right.value, from: massUnit, to: volumeUnit)
        default:
            throw QuantityError.incompatibleTypes
        }

        return left.value < rightValue
    }
}

// MARK: - CustomStringConvertible
extension Quantity: CustomStringConvertible {
    var description: String {
        switch unit {
        case .count:
            if value == 0 {
                return "None"
            } else {
                return value.removeZerosFromEnd()
            }
        default:
            return "\(value.removeZerosFromEnd()) \(unit.description)"
        }
    }
}

extension Quantity {
    init(from record: QuantityRecord) throws {
        switch record {
        case let .count(value):
            try self.init(.count, value: value)
        case let .mass(value, unit):
            try self.init(.mass(unit), value: value)
        case let .volume(value, unit):
            try self.init(.volume(unit), value: value)
        }
    }

    var record: QuantityRecord {
        switch unit {
        case .count:
            return .count(value)
        case .mass(let unit):
            return .mass(value, unit: unit)
        case .volume(let unit):
            return .volume(value, unit: unit)
        }
    }
}

enum QuantityError: LocalizedError {
    case negativeQuantity
    case divisionByZero
    case incompatibleTypes
    case invalidUnit
    case invalidQuantity

    var errorDescription: String? {
        switch self {
        case .invalidQuantity:
            return "Ingredient quantity must be a non-negative number."
        default:
            return ""
        }
    }
}
