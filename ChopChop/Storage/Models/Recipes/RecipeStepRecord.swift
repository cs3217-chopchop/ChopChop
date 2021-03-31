import GRDB

struct RecipeStepRecord {
    var id: Int64?
    var graphId: Int64?
    var content: String
}

extension RecipeStepRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let graphId = Column(CodingKeys.graphId)
        static let content = Column(CodingKeys.content)
    }

    static let databaseTableName = "recipeStep"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
