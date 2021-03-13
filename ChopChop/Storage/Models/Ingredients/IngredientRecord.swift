import GRDB

struct IngredientRecord {
    var id: Int64?
    var name: String
}

extension IngredientRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
    }

    static let databaseTableName = "ingredient"

    static let sets = hasMany(IngredientSetRecord.self)
    var sets: QueryInterfaceRequest<IngredientSetRecord> {
        request(for: IngredientRecord.sets)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == IngredientRecord {
    func orderedByName() -> Self {
        order(IngredientRecord.Columns.name)
    }
}
