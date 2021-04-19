import FirebaseFirestoreSwift

/**
 Represents the steps field in the firebase document for online recipe.
 */
struct OnlineStepRecord {
    // MARK: - Specification Fields
    /// Identifies a unique step. This allows repeated steps with the exact same wording to be differentiated.
    var id: String
    /// The step description.
    var content: String
}

// MARK: Codable - Allows encoding to and decoding from firebase document field
extension OnlineStepRecord: Codable {
}

// MARK: Equatable
extension OnlineStepRecord: Equatable {
}

// MARK: Firebase document field representation
extension OnlineStepRecord {
    var asDict: [String: Any] {
        ["id": id, "content": content]
    }
}
