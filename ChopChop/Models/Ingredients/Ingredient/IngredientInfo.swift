import GRDB

struct IngredientInfo: Identifiable, Equatable {
    var id: Int64?
    var name: String
    var quantity: String
}
