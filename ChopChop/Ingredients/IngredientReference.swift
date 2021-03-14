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

    func add(_ quantity: IngredientQuantity) {
        do {
            try self.quantity += quantity
        } catch {
            return
        }
    }

    func subtract(_ quantity: IngredientQuantity) {
        do {
            try self.quantity -= quantity
        } catch {
            return
        }
    }

    func subtractAll() {
        subtract(self.quantity)
    }

    func scale(_ factor: Double) {
        do {
            try self.quantity *= factor
        } catch {
            return
        }
    }
}
