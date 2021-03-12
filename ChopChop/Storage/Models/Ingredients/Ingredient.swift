import GRDB

struct Ingredient {
    var id: Int64?
    var name: String
}

extension Ingredient: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
    }

    static let sets = hasMany(IngredientSet.self)
    var sets: QueryInterfaceRequest<IngredientSet> {
        request(for: Ingredient.sets)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == Ingredient {
    func orderedByName() -> Self {
        order(Ingredient.Columns.name)
    }
}
