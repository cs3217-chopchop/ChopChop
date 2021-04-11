import Combine

final class RecipeIngredientRowViewModel: ObservableObject {
    @Published var name: String
    @Published var quantity: String
    @Published var type: QuantityType

    init(name: String = "", quantity: String = "", type: QuantityType = .count) {
        self.name = name
        self.quantity = quantity
        self.type = type
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

        return try RecipeIngredient(name: name, quantity: Quantity(type, value: value))
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
