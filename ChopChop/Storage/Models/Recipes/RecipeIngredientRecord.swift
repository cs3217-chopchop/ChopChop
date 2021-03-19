import GRDB

struct RecipeIngredientRecord {
    var id: Int64?
    var recipeId: Int64?
    var name: String
    var quantity: QuantityRecord
}

extension RecipeIngredientRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let recipeId = Column(CodingKeys.recipeId)
        static let name = Column(CodingKeys.name)
        static let quantity = Column(CodingKeys.quantity)
    }

    static let databaseTableName = "recipeIngredient"

    static let recipe = belongsTo(RecipeRecord.self)
    var recipe: QueryInterfaceRequest<RecipeRecord> {
        request(for: RecipeIngredientRecord.recipe)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == RecipeIngredientRecord {
    func filteredByCategory(ids: [Int64]) -> Self {
        if ids.isEmpty {
            return joining(required: RecipeIngredientRecord.recipe.filter(RecipeRecord.Columns.recipeCategoryId == nil))
        } else {
            return joining(required: RecipeIngredientRecord.recipe
                            .filter(ids.contains(RecipeRecord.Columns.recipeCategoryId)))
        }
    }
}
