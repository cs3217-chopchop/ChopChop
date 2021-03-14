/**
 Represents the volume of an ingredient measured in milliliters.
 */
struct IngredientVolume {
    static let precision: Int = 2

    let volume: Double

    init(_ volume: Double) throws {
        guard !volume.isLess(than: 0) else {
            throw IngredientQuantityError.negativeQuantity
        }

        self.volume = volume
    }
}

extension IngredientVolume: IngredientQuantity {
    // swiftlint:disable force_try
    static let zero: IngredientVolume = try! IngredientVolume(0)
    // swiftlint:enable force_try

    static func + (left: IngredientVolume, right: IngredientVolume) throws -> IngredientVolume {
        try IngredientVolume(left.volume + right.volume)
    }

    static func - (left: IngredientVolume, right: IngredientVolume) throws -> IngredientVolume {
        try IngredientVolume(left.volume - right.volume)
    }

    static func * (left: IngredientVolume, right: Double) throws -> IngredientVolume {
        guard right > 0 else {
            throw IngredientQuantityError.nonPositiveFactor
        }

        return try IngredientVolume(left.volume * right)
    }

    static func / (left: IngredientVolume, right: Double) throws -> IngredientVolume {
        guard right > 0 else {
            throw IngredientQuantityError.nonPositiveFactor
        }

        return try IngredientVolume(left.volume / right)
    }

    static func < (lhs: IngredientVolume, rhs: IngredientVolume) -> Bool {
        lhs.volume < rhs.volume
    }

    var description: String {
        String(format: "%.\(IngredientVolume.precision)f", volume)
    }
}
