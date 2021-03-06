import Foundation
import FirebaseFirestoreSwift

/**
 Represents a firebase document that contains the online recipe details.
 */
struct OnlineRecipeRecord {
    // MARK: - Specification Fields
    /// Identifies the firebase document that contains this recipe.
    /// This id is autogenerated by firebase when the recipe is first added to firebase.
    /// Is `nil` before the recipe has been added to firebase.
    @DocumentID var id: String?
    /// The name of the online recipe.
    var name: String
    /// Identifies the firebase document that contains the user who created this recipe.
    var creatorId: String
    /// Identifies the firebase document that contains the recipe that this recipe is adapted from.
    /// This Id exists if this recipe was previously downloaded from another recipe, and is `nil` otherwise
    @ExplicitNull var parentOnlineRecipeId: String?
    /// The number of people this recipe is designed to feed.
    var servings: Double
    /// The cuisine description of this recipe.
    /// Is `nil` if unspecified.
    @ExplicitNull var cuisine: String?
    /// A measure of the difficulty to make the recipe.
    /// Is `nil` if there is no associated difficulty.
    @ExplicitNull var difficulty: Difficulty?
    /// The ingredients required to make the recipe, in terms of the
    /// firebase document representation of the ingredient field.
    var ingredients: [OnlineIngredientRecord]
    /// The steps in a recipe, in terms of the firebase document representation of the steps field.
    var steps: [OnlineStepRecord]
    /// The ordered pairs of steps in a recipe, in terms of the firebase document representation of the field.
    var stepEdges: [OnlineStepEdgeRecord]
    /// The ratings given by other users to this recipe.
    var ratings: [RecipeRating] = []

}

// MARK: Equatable
extension OnlineRecipeRecord: Equatable {
}

// MARK: Codable - Allows encoding to and decoding from firebase document
extension OnlineRecipeRecord: Codable {
}

enum OnlineRecipeRecordError: Error {
    case missingId, missingCreatedDate, missingUpdatedDate
}
