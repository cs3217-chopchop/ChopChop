import Foundation

class RecipeIngredient {
    var id: Int64?
    private(set) var name: String

    // Quantity is optional because some ingredients don't have an associated quantity
    // e.g. "add salt to meat" does not specify quantity of salt
    private(set) var quantity: Quantity?

    init(name: String, quantity: Quantity?) {
        self.name = name
        self.quantity = quantity
        assert(checkRepresentation())
    }

    func updateName(name: String) throws {
        assert(checkRepresentation())
        guard name != "" else {
            throw RecipeIngredientError.invalidName
        }
        self.name = name
        assert(checkRepresentation())
    }

    func updateQuantity(quantity: Quantity) {
        assert(checkRepresentation())
        self.quantity = quantity
        assert(checkRepresentation())
    }

    func scaleQuantityMagnitude(scale: Double) {
        assert(checkRepresentation())
        guard scale > 0 else {
            assertionFailure("Should be positive magnitude")
            return
        }
        quantity?.magnitude *= scale
        assert(checkRepresentation())
    }

    private func checkRepresentation() -> Bool {
        name != ""
    }

}

// TODO remove
struct Quantity {
    var unit: String
    var magnitude: Double
}


extension RecipeIngredient: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RecipeIngredient(id: id, name: name, quantity: quantity)
        return copy
    }
}

enum RecipeIngredientError: Error {
    case invalidName
}
