import GRDB

struct RecipeStepEdgeRecord: Identifiable {
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

    static let sourceForeignKey = ForeignKey(["sourceId"])
    static let destinationForeignKey = ForeignKey(["destinationId"])

    static let source = belongsTo(RecipeStepRecord.self, using: sourceForeignKey)
    var source: QueryInterfaceRequest<RecipeStepRecord> {
        request(for: RecipeStepEdgeRecord.source)
    }

    static let destination = belongsTo(RecipeStepRecord.self, using: destinationForeignKey)
    var destination: QueryInterfaceRequest<RecipeStepRecord> {
        request(for: RecipeStepEdgeRecord.destination)
    }

    static let databaseTableName = "recipeStepEdge"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
