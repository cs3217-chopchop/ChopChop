import Foundation
import FirebaseFirestoreSwift

struct OnlineRecipeInfoRecord: InfoRecord {
    @DocumentID var id: String? // same as OnlineRecipe id
    private(set) var creator: String // creatorId
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    @ServerTimestamp var imageUpdatedAt: Date?
}

extension OnlineRecipeInfoRecord: Equatable {
}

extension OnlineRecipeInfoRecord: Codable {
}
