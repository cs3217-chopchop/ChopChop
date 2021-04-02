import FirebaseFirestore

struct OnlineIngredientRecord {
    var name: String
    var quantity: QuantityRecord
}

extension OnlineIngredientRecord: Codable {
}

extension OnlineIngredientRecord {
    func toRecipeIngredient() throws -> RecipeIngredient {
        try RecipeIngredient(name: name, quantity: quantity.toQuantity())
    }
}

extension OnlineIngredientRecord {
    func toDict() -> [String: Any] {
        ["name": name, "quantity": quantity.toDict()]
    }
}

extension OnlineIngredientRecord: Equatable {
}
