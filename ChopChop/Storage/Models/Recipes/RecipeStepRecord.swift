import GRDB

struct RecipeStepRecord {
    var id: Int64?
    var recipeId: Int64?
    var index: Int
    var content: String
}

extension RecipeStepRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let recipeId = Column(CodingKeys.recipeId)
        static let index = Column(CodingKeys.index)
        static let content = Column(CodingKeys.content)
    }

    static let databaseTableName = "recipeStep"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
