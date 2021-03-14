class RecipeIngredient {
    let id: Int64
    var name: String
    var quantity: Quantity

    init(id: Int64, name: String, quantity: Quantity) {
        self.id = id
        self.name = name
        self.quantity = quantity
        assert(checkRepresentation())
    }

    // Use case: substitutes
    func updateName(name: String) {
        self.name = name
    }

    func updateQuantity(quantity: Quantity) {
        // since we are only deducting ingredients at the end, the units only need to be same as those in inventory at the end
        // user can change units of ingredients too

        self.quantity = quantity

    }

    func scaleQuantityMagnitude(scale: Double) {
        guard scale > 0 else {
            assertionFailure("Should be positive magnitude")
        }
        quantity.magnitude *= scale
    }

    private func checkRepresentation() -> Bool {
        name != ""
    }



}

// remove
struct Quantity {
    var unit: String
    var magnitude: Double
}
