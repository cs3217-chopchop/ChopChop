import GRDB

struct IngredientRecord: Equatable {
    var id: Int64?
    var ingredientCategoryId: Int64?
    var name: String
}

extension IngredientRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let ingredientCategoryId = Column(CodingKeys.ingredientCategoryId)
        static let name = Column(CodingKeys.name)
    }

    static let databaseTableName = "ingredient"

    static let category = belongsTo(IngredientCategoryRecord.self)
    var category: QueryInterfaceRequest<IngredientCategoryRecord> {
        request(for: IngredientRecord.category)
    }

    // Sorted by expiry date (nils last)
    static let batches = hasMany(IngredientBatchRecord.self)
        .order(IngredientBatchRecord.Columns.expiryDate.ascNullsLast)
    var batches: QueryInterfaceRequest<IngredientBatchRecord> {
        request(for: IngredientRecord.batches)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == IngredientRecord {
    func orderedByName() -> Self {
        order(IngredientRecord.Columns.name)
    }

    func orderedByExpiryDate() -> Self {
        annotated(with: IngredientRecord.batches.min(IngredientBatchRecord.Columns.expiryDate))
            .order(SQLLiteral("minIngredientBatchExpiryDate").sqlExpression.ascNullsLast)
    }

    func filteredByCategory(ids: [Int64]) -> Self {
        joining(required: IngredientRecord.category.filter(keys: ids))
    }
}
