/**
 Represents some quantity of an ingredient.
 */
struct IngredientReference {
    let name: String
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
}
