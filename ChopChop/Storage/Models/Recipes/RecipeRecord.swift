import GRDB

struct RecipeRecord: Equatable {
    var id: Int64?
    var recipeCategoryId: Int64?
    var name: String
    var servings: Double
    var difficulty: Difficulty?
}

extension RecipeRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let recipeCategoryId = Column(CodingKeys.recipeCategoryId)
        static let name = Column(CodingKeys.name)
        static let servings = Column(CodingKeys.servings)
        static let difficulty = Column(CodingKeys.difficulty)
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

    static let stepGraph = hasOne(RecipeStepGraphRecord.self)
    var stepGraph: QueryInterfaceRequest<RecipeStepGraphRecord> {
        request(for: RecipeRecord.stepGraph)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == RecipeRecord {
    func orderedByName() -> Self {
        order(RecipeRecord.Columns.name)
    }

    func filteredByCategory(ids: [Int64?]) -> Self {
        if ids == [nil] {
            return filter(RecipeRecord.Columns.recipeCategoryId == nil)
        } else if ids.contains(nil) {
            return joining(optional: RecipeRecord.category.filter(keys: ids.compactMap { $0 }))
        } else {
            return joining(required: RecipeRecord.category.filter(keys: ids.compactMap { $0 }))
        }
    }

    func filteredByName(_ query: String) -> Self {
        filter(RecipeRecord.Columns.name.like("%\(query)%"))
    }

    func filteredByIngredients(_ ingredients: [String]) -> Self {
        having(RecipeRecord.ingredients
                .filter(ingredients.contains(RecipeIngredientRecord.Columns.name)).count == ingredients.count)
    }
}
