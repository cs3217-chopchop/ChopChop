/**
 Represents the count of an ingredient.
 */
struct IngredientCount {
    static let precision: Int = 1

    let count: Double

    init(_ count: Double) throws {
        guard !count.isLess(than: 0) else {
            throw IngredientQuantityError.negativeQuantity
        }

        self.count = count
    }
}

extension IngredientCount: IngredientQuantity {
    // swiftlint:disable force_try
    static let zero: IngredientCount = try! IngredientCount(0)
    // swiftlint:enable force_try

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
}
