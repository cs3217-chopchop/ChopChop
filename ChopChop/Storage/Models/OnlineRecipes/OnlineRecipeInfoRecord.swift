import Foundation
import FirebaseFirestoreSwift

struct OnlineRecipeInfoRecord: InfoRecord {
    @DocumentID var id: String? // same as OnlineRecipe id
    private(set) var creatorId: String
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    @ServerTimestamp var imageUpdatedAt: Date? // imageCache 'updatedAt' related to this
}

extension OnlineRecipeInfoRecord: Equatable {
}

extension OnlineRecipeInfoRecord: Codable {
}
