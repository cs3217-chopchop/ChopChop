/**
 Represents some quantity of an ingredient.
 */
struct RecipeIngredient {
    private(set) var name: String
    private(set) var quantity: Quantity

    init(name: String, quantity: Quantity) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.name = trimmedName
        self.quantity = quantity
    }

    mutating func add(_ quantity: Quantity) throws {
        try self.quantity += quantity
    }

    mutating func subtract(_ quantity: Quantity) throws {
        try self.quantity -= quantity
    }

    mutating func scale(_ factor: Double) throws {
        try self.quantity *= factor
    }

    mutating func updateName(_ name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw IngredientError.emptyName
        }

        self.name = trimmedName
    }

}

extension RecipeIngredient: Equatable {
    static func == (lhs: RecipeIngredient, rhs: RecipeIngredient) -> Bool {
        lhs.quantity == rhs.quantity && lhs.name == rhs.name
    }
}
