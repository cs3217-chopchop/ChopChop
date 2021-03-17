import GRDB

struct RecipeRecord: Equatable {
    var id: Int64?
    var recipeCategoryId: Int64?
    var name: String
}

extension RecipeRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let recipeCategoryId = Column(CodingKeys.recipeCategoryId)
        static let name = Column(CodingKeys.name)
    }

    static let databaseTableName = "recipe"

    static let category = belongsTo(RecipeCategoryRecord.self)
    var category: QueryInterfaceRequest<RecipeCategoryRecord> {
        request(for: RecipeRecord.category)
    }

    static let ingredients = hasMany(RecipeIngredientRecord.self)
    var ingredients: QueryInterfaceRequest<RecipeIngredientRecord> {
        request(for: RecipeRecord.ingredients)
    }

    // Sorted by step index
    static let steps = hasMany(RecipeStepRecord.self).order(RecipeStepRecord.Columns.index)
    var steps: QueryInterfaceRequest<RecipeStepRecord> {
        request(for: RecipeRecord.steps)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == RecipeRecord {
    func orderedByName() -> Self {
        order(RecipeRecord.Columns.name)
    }

    func filteredByCategory(ids: [Int64]) -> Self {
        joining(required: RecipeRecord.category.filter(keys: ids))
    }

    func filteredByName(_ query: String) -> Self {
        filter(RecipeRecord.Columns.name.like("%\(query)%"))
    }

    func filteredByContents(_ query: String) -> Self {
        let ingredientsAlias = TableAlias()

        return joining(optional: RecipeRecord.ingredients.aliased(ingredientsAlias))
            .filter(RecipeRecord.Columns.name.like("%\(query)%")
                        || ingredientsAlias[RecipeIngredientRecord.Columns.name.like("%\(query)%")])
    }
}
