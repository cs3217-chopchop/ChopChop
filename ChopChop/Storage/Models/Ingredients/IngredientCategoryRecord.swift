import GRDB

/**
 Represents a record of an ingredient category stored in the local database.
 */
struct IngredientCategoryRecord: Equatable {
    var id: Int64?

    // MARK: - Specification Fields
    /// The name of the category.
    var name: String
}

extension IngredientCategoryRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
    }

    static let databaseTableName = "ingredientCategory"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == IngredientCategoryRecord {
    func orderedByName() -> Self {
        order(IngredientCategoryRecord.Columns.name)
    }
}
