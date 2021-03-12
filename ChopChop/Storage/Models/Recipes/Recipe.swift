import GRDB

struct Recipe {
    var id: Int64?
    var name: String
}

extension Recipe: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
    }

    static let ingredients = hasMany(RecipeIngredient.self)
    var ingredients: QueryInterfaceRequest<RecipeIngredient> {
        request(for: Recipe.ingredients)
    }

    static let steps = hasMany(RecipeStep.self)
    var steps: QueryInterfaceRequest<RecipeStep> {
        request(for: Recipe.steps)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == Recipe {
    func orderedByName() -> Self {
        order(Recipe.Columns.name)
    }
}
