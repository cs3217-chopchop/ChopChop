import GRDB

struct Step {
    var id: Int64?
    var recipeId: Int64?
    var index: Int
    var text: String
}

extension Step: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let recipeId = Column(CodingKeys.recipeId)
        static let index = Column(CodingKeys.index)
        static let text = Column(CodingKeys.text)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
