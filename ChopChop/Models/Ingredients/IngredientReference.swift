/**
 Represents some quantity of an ingredient.
 */
class IngredientReference {
    let name: String
    private(set) var quantity: IngredientQuantity

    init(name: String, quantity: IngredientQuantity) {
        self.name = name
        self.quantity = quantity
    }

    func add(_ quantity: IngredientQuantity) throws {
        try self.quantity += quantity
    }

    func subtract(_ quantity: IngredientQuantity) throws {
        try self.quantity -= quantity
    }

    func scale(_ factor: Double) throws {
        try self.quantity *= factor
    }
}
