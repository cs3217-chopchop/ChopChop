import GRDB

struct RecipeStepGraphRecord {
    var id: Int64?
    var recipeId: Int64?
}

extension RecipeStepGraphRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let recipeId = Column(CodingKeys.recipeId)
    }

    static let databaseTableName = "recipeStepGraph"

    static let steps = hasMany(RecipeStepRecord.self)
    var steps: QueryInterfaceRequest<RecipeStepRecord> {
        request(for: RecipeStepGraphRecord.steps)
    }

    static let edges = hasMany(RecipeStepEdgeRecord.self)
    var edges: QueryInterfaceRequest<RecipeStepEdgeRecord> {
        request(for: RecipeStepGraphRecord.edges)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
