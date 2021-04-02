import FirebaseFirestoreSwift

struct OnlineIngredientRecord {
    var name: String
    var quantity: QuantityRecord
}

extension OnlineIngredientRecord: Codable {
}

extension OnlineIngredientRecord {
    var asDict: [String: Any] {
        ["name": name, "quantity": quantity.asDict]
    }
}

extension OnlineIngredientRecord: Equatable {
}
