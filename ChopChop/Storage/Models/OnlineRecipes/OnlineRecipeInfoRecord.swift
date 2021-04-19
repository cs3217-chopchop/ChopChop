import Foundation
import FirebaseFirestoreSwift

/**
 Represents a firebase document that contains concise online recipe information to facilitate caching.
 */
struct OnlineRecipeInfoRecord: InfoRecord {
    // MARK: - Specification Fields
    /// Identifies the firebase document that contains the concise online recipe information.
    /// This Id is the same as the another firebase document that contains the main details of the same recipe.
    /// Is `nil` before the recipe has been added to firebase.
    @DocumentID var id: String?
    /// Identifies the firebase document that contains the user who created the recipe.
    private(set) var creatorId: String
    /// The time of adding the recipe to firebase.
    /// Is `nil` before the recipe has been added to firebase.
    @ServerTimestamp var createdAt: Date?
    /// The time where this recipe is last updated on firebase..
    /// Is `nil` before the recipe has been added to firebase.
    @ServerTimestamp var updatedAt: Date?
    /// The time where the image associated with this recipe has been updated in cloud storage.
    /// Is `nil` before any image associated with the recipe has been uploaded.
    @ServerTimestamp var imageUpdatedAt: Date?
}

// MARK: Equatable
extension OnlineRecipeInfoRecord: Equatable {
}

// MARK: Codable - Allows encoding to and decoding from firebase document
extension OnlineRecipeInfoRecord: Codable {
}
