import GRDB

struct RecipeStepRecord {
    var id: Int64?
    var graphId: Int64?
    var index: Int
    var content: String
}

extension RecipeStepRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let graphId = Column(CodingKeys.graphId)
        static let index = Column(CodingKeys.index)
        static let content = Column(CodingKeys.content)
    }

    static let outgoingEdges = hasMany(RecipeStepEdgeRecord.self)
    var outgoingEdges: QueryInterfaceRequest<RecipeStepEdgeRecord> {
        request(for: RecipeStepRecord.outgoingEdges)
    }

    static let incomingEdges = hasMany(RecipeStepEdgeRecord.self)
    var incomingEdges: QueryInterfaceRequest<RecipeStepEdgeRecord> {
        request(for: RecipeStepRecord.incomingEdges)
    }

    static let databaseTableName = "recipeStep"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
