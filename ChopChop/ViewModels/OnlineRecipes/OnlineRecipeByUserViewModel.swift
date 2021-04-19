import SwiftUI
import Combine

class OnlineRecipeByUserViewModel: OnlineRecipeViewModel {
    @Published var isShowingRating = false

    override init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings) {
        super.init(recipe: recipe, downloadRecipeViewModel: downloadRecipeViewModel, settings: settings)
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
            storageManager.rateRecipe(recipeId: recipe.id, userId: userId, rating: rating) { err in
                guard err == nil else {
                    return
                }
                self.reload()
            }
            return
        }
        storageManager.rerateRecipe(recipeId: recipe.id, oldRating: ownRating,
                                    newRating: RecipeRating(userId: userId, score: rating)) { err in
            guard err == nil else {
                return
            }
            self.reload()
        }
    }

    func removeRating() {
        guard let ownRating = ownRating else {
            assertionFailure()
            return
        }

        storageManager.unrateRecipe(recipeId: recipe.id, rating: ownRating) { err in
            guard err == nil else {
                return
            }
            self.reload()
        }

    }

    func toggleShowRating() {
        isShowingRating.toggle()
        self.objectWillChange.send()
    }
}
