import GRDB

struct RecipeCategoryRecord: Identifiable, Equatable {
    var id: Int64?
    var name: String
}

extension RecipeCategoryRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
    }

    static let databaseTableName = "recipeCategory"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == RecipeCategoryRecord {
    func orderedByName() -> Self {
        order(RecipeCategoryRecord.Columns.name)
    }
}
