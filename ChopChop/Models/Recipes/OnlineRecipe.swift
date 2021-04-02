import Foundation
import FirebaseFirestoreSwift

class OnlineRecipe: Identifiable {
    private(set) var id: String
    private(set) var userId: String

    private(set) var name: String
    private(set) var servings: Double
    private(set) var cuisine: String?
    private(set) var difficulty: Difficulty?
    private(set) var steps: [String]
    private(set) var ingredients: [RecipeIngredient]
    private(set) var ratings: [RecipeRating]
    private(set) var created: Date

    init(id: String, userId: String, name: String, servings: Double, difficulty: Difficulty?, cuisine: String?,
         steps: [String], ingredients: [RecipeIngredient], ratings: [RecipeRating], created: Date) throws {
        self.id = id
        self.userId = userId
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RecipeError.invalidName
        }
        self.name = trimmedName

        guard servings > 0 else {
            throw RecipeError.invalidServings
        }
        self.servings = servings
        self.cuisine = cuisine
        self.difficulty = difficulty
        self.steps = steps
        self.ingredients = ingredients
        self.ratings = ratings
        self.created = created
    }
}

extension OnlineRecipe {
    convenience init(from record: OnlineRecipeRecord) throws {
        guard let id = record.id else {
            throw OnlineRecipeRecordError.missingId
        }

        guard let createdDate = record.created else {
            throw OnlineRecipeRecordError.missingCreatedDate
        }
        try self.init(
            id: id,
            userId: record.creator,
            name: record.name,
            servings: record.servings,
            difficulty: record.difficulty,
            cuisine: record.cuisine,
            steps: record.steps,
            ingredients: record.ingredients.compactMap({ try? RecipeIngredient(from: $0) }),
            ratings: record.ratings,
            created: createdDate
        )
    }
}
