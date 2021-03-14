/**
 Represents the count of an ingredient.
 */
class IngredientCount {
    static let precision: Int = 1

    let count: Double

    init(_ count: Double) throws {
        guard count >= 0 else {
            throw IngredientQuantityError.negativeQuantity
        }

        self.count = count
    }
}

extension IngredientCount: IngredientQuantity {
    static func + (left: IngredientCount, right: IngredientCount) throws -> IngredientCount {
        try IngredientCount(left.count + right.count)
    }

    static func - (left: IngredientCount, right: IngredientCount) throws -> IngredientCount {
        try IngredientCount(left.count - right.count)
    }

    static func * (left: IngredientCount, right: Double) throws -> IngredientCount {
        guard right > 0 else {
            throw IngredientQuantityError.nonPositiveFactor
        }

        return try IngredientCount(left.count * right)
    }

    static func / (left: IngredientCount, right: Double) throws -> IngredientCount {
        guard right > 0 else {
            throw IngredientQuantityError.nonPositiveFactor
        }

        return try IngredientCount(left.count / right)
    }

    static func < (lhs: IngredientCount, rhs: IngredientCount) -> Bool {
        lhs.count < rhs.count
    }

    var description: String {
        String(format: "%.\(IngredientCount.precision)f", count)
    }

    var isZero: Bool {
        count == 0
    }
}
