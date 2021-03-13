/**
 Represents some quantity of an ingredient.
 */
class IngredientReference<Quantity: IngredientQuantity> {
    let name: String
    private(set) var quantity: Quantity

    init(name: String, quantity: Quantity) {
        self.name = name
        self.quantity = quantity
    }

    func add(_ quantity: Quantity) {
        do {
            try self.quantity += quantity
        } catch {
            return
        }
    }

    func subtract(_ quantity: Quantity) {
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
