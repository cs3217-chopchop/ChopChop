import Foundation
import FirebaseFirestoreSwift

struct OnlineRecipeRecord {
    @DocumentID var id: String?
    var name: String
    var creator: String
    @ExplicitNull var parentOnlineRecipeId: String?
    var servings: Double
    @ExplicitNull var cuisine: String?
    @ExplicitNull var difficulty: Difficulty?
    var ingredients: [OnlineIngredientRecord]
    var steps: [OnlineStepRecord]
    var stepEdges: [OnlineStepEdgeRecord]
    var ratings: [RecipeRating] = []

}

extension OnlineRecipeRecord: Equatable {
}

extension OnlineRecipeRecord: Codable {
}

enum OnlineRecipeRecordError: Error {
    case missingId, missingCreatedDate, missingUpdatedDate
}
