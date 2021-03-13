/**
 Represents the mass of an ingredient measured in grams.
 */
struct IngredientMass {
    static let precision: Int = 2

    let mass: Double

    init(_ mass: Double) throws {
        guard mass > 0 else {
            throw IngredientQuantityError.negativeQuantity
        }

        self.mass = mass
    }
}

extension IngredientMass: IngredientQuantity {
    static func + (left: IngredientMass, right: IngredientMass) throws -> IngredientMass {
        try IngredientMass(left.mass + right.mass)
    }
    
    static func - (left: IngredientMass, right: IngredientMass) throws -> IngredientMass {
        try IngredientMass(left.mass - right.mass)
    }

    static func * (left: IngredientMass, right: Double) throws -> IngredientMass {
        guard right > 0 else {
            throw IngredientQuantityError.nonPositiveFactor
        }

        return try IngredientMass(left.mass * right)
    }

    static func / (left: IngredientMass, right: Double) throws -> IngredientMass {
        guard right > 0 else {
            throw IngredientQuantityError.nonPositiveFactor
        }

        return try IngredientMass(left.mass / right)
    }

    static func < (lhs: IngredientMass, rhs: IngredientMass) -> Bool {
        lhs.mass < rhs.mass
    }

    var description: String {
        String(format: "%.\(IngredientMass.precision)f", mass)
    }

    var isZero: Bool {
        mass == 0
    }

    var type: IngredientQuantityType {
        .mass
    }
}
