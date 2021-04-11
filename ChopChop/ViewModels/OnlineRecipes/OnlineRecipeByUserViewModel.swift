import SwiftUI
import Combine

class OnlineRecipeByUserViewModel: OnlineRecipeViewModel {
    @Published var creatorName = "No name" {
        willSet { self.objectWillChange.send() }
    }

    override init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings) {
        super.init(recipe: recipe, downloadRecipeViewModel: downloadRecipeViewModel, settings: settings)

        storageManager.fetchUserInfoById(userId: recipe.userId) {
            user, _ in
            guard let name = user?.name else {
                return
            }
            self.creatorName = name
        }
    }

    var ownRating: RecipeRating? {
        recipe.ratings.first(where: { $0.userId == settings.userId })
    }

    func tapRating(_ ratingValue: Int) {
        guard let userId = settings.userId else {
            assertionFailure()
            return
        }

        guard let rating = RatingScore(rawValue: ratingValue + 1) else {
            assertionFailure()
            return
        }

        guard let ownRating = ownRating else {
            storageManager.rateRecipe(recipeId: recipe.id, userId: userId, rating: rating, completion: reload)
            return
        }
        storageManager.rerateRecipe(recipeId: recipe.id, oldRating: ownRating,
                                    newRating: RecipeRating(userId: userId, score: rating), completion: reload)
    }

    func removeRating() {
        guard let ownRating = ownRating else {
            assertionFailure()
            return
        }

        storageManager.unrateRecipe(recipeId: recipe.id, rating: ownRating, completion: reload)
    }

}
