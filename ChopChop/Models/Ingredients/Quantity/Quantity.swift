import GRDB

/**
 Represents the quantity of an ingredient.
 
 Invariants:
 - Quantities are non negative.
 */
struct Quantity: Equatable {
    let type: QuantityType
    var value: Double

    init(_ type: QuantityType, value: Double) throws {
        guard value >= 0 else {
            throw QuantityError.negativeQuantity
        }

        self.type = type
        self.value = value
    }

    var baseType: BaseQuantityType {
        type.baseType
    }

    var baseValue: Double {
        switch type {
        case .count:
            return value
        case .mass(let unit):
            return MassUnit.convert(value, from: unit, to: .baseUnit)
        case .volume(let unit):
            return VolumeUnit.convert(value, from: unit, to: .baseUnit)
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
        switch (left.type, right.type) {
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

    /**
     Returns the result of the right quantity subtracted from the left if they are of the same type.
     - Throws:
        - `QuantityError.differentQuantityTypes`: if the types of the quantities do not match.
        - `QuantityError.negativeQuantity`: if the result is negative.
     */
    static func - (left: Quantity, right: Quantity) throws -> Quantity {
        switch (left.type, right.type) {
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

    /**
     Returns whether the left quantity is smaller than the right, if they are of the same type.
     - Throws:
        - `QuantityError.differentQuantityTypes`: if the types of the quantities do not match.
     */
    static func < (left: Quantity, right: Quantity) throws -> Bool {
        var rightValue: Double

        switch (left.type, right.type) {
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
        switch type {
        case .count:
            return String(format: "%.1f", value)
        case .mass(let unit):
            return String(format: "%.2f \(unit.description)", value)
        case .volume(let unit):
            return String(format: "%.2f \(unit.description)", value)
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
        switch type {
        case .count:
            return .count(value)
        case .mass(let unit):
            return .mass(value, unit: unit)
        case .volume(let unit):
            return .volume(value, unit: unit)
        }
    }
 }

enum QuantityError: Error {
    case negativeQuantity
    case divisionByZero
    case incompatibleTypes
}
