import SwiftUI
import Combine

class OnlineRecipeByUserViewModel: OnlineRecipeViewModel {
    var creatorName: String

    @Published var saveAs = ""
    @Published var isDownload = false
    @Published var errorMessage = ""

    override init(recipe: OnlineRecipe) {
        super.init(recipe: recipe)
        creatorName = storageManager.fetchUserById(userId: recipe.userId).name
    }

    var ownRating: RecipeRating? {
        recipe.ratings.first(where: { $0.userId == USER_ID })
    }

    func tapRating(_ ratingValue: Int) {
        guard ownRating != nil else {
            storageManager.rateRecipe(recipeId: recipe.id, userId: USER_ID, rating: RatingScore(rawValue: ratingValue))
            return
        }
        storageManager.rerateRecipe(recipeId: recipe.id, newRating: RecipeRating(userId: USER_ID, score: RatingScore(rawValue: ratingValue)))
    }

    func downloadRecipe() {
        do {
            // take in saveAs
            try storageManager.downloadRecipe(recipe: recipe)
            isDownload = false
            errorMessage = ""
        } catch {
            errorMessage = "Invalid name"

        }
    }

}
