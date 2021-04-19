import FirebaseFirestoreSwift

/**
 Represents the step edge field in the firebase document for online recipe.
 A step edge refers to an edge in the step graph which exists in the runtime online recipe model.
 It represents the direct ordering of two steps in a recipe (e.g. Poaching cabbage should be done after washing cabbage)
 */
struct OnlineStepEdgeRecord {
    // MARK: - Specification Fields
    /// Identifies the step that should be completed first.
    var sourceStepId: String
    /// Identifies the step that should be completed later.
    var destinationStepId: String
}

// MARK: Equatable
extension OnlineStepEdgeRecord: Equatable {
}

// MARK: Codable - Allows encoding to and decoding from firebase document field
extension OnlineStepEdgeRecord: Codable {
}

// MARK: Firebase document field representation
extension OnlineStepEdgeRecord {
    var asDict: [String: Any] {
        ["sourceStepId": sourceStepId, "destinationStepId": destinationStepId]
    }
}
