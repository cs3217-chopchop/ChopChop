import GRDB

struct RecipeStepEdgeRecord {
    var id: Int64?
    var graphId: Int64?
    var sourceId: Int64?
    var destinationId: Int64?
}

extension RecipeStepEdgeRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let graphId = Column(CodingKeys.graphId)
        static let sourceId = Column(CodingKeys.sourceId)
        static let destinationId = Column(CodingKeys.destinationId)
    }

    static let databaseTableName = "recipeStepEdge"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
