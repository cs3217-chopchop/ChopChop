import GRDB

struct IngredientInfo: Identifiable {
    var id: Int64?
    var name: String
    var quantity: String
}
