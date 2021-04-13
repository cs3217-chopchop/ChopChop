import Foundation
import GRDB

struct RecipeStepTimerRecord {
    var id: Int64?
    var stepId: Int64?
    var duration: TimeInterval
}

extension RecipeStepTimerRecord: Codable, FetchableRecord, MutablePersistableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let stepId = Column(CodingKeys.stepId)
        static let duration = Column(CodingKeys.duration)
    }

    static let databaseTableName = "recipeStepTimer"

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
