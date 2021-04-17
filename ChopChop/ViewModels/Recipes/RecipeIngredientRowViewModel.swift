import Combine

final class RecipeIngredientRowViewModel: ObservableObject {
    @Published var name: String
    @Published var quantity: String
    @Published var unit: QuantityUnit

    init(name: String = "", quantity: String = "", unit: QuantityUnit = .count) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }

    func setQuantity(_ quantity: String) {
        self.quantity = String(quantity.filter { "0123456789.".contains($0) })
            .components(separatedBy: ".")
            .prefix(2)
            .joined(separator: ".")
    }

    func convertToIngredient() throws -> RecipeIngredient {
        guard let value = Double(quantity) else {
            throw QuantityError.invalidQuantity
        }

        return try RecipeIngredient(name: name, quantity: Quantity(unit, value: value))
    }
}

extension RecipeIngredientRowViewModel: Equatable {
    static func == (lhs: RecipeIngredientRowViewModel, rhs: RecipeIngredientRowViewModel) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension RecipeIngredientRowViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
