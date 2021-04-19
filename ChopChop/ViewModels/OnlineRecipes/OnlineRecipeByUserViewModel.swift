import SwiftUI
import Combine

/**
 Represents a view model of a view of a recipe published online by another user.
 */
class OnlineRecipeByUserViewModel: OnlineRecipeViewModel {
    /// Display flags
    @Published var isShowingRating = false

    override init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings) {
        super.init(recipe: recipe, downloadRecipeViewModel: downloadRecipeViewModel, settings: settings)
    }

    var ownRating: RecipeRating? {
        recipe.ratings.first(where: { $0.userId == settings.userId })
    }

    /**
     Rates the displayed recipe with the given value.
     */
    func tapRating(_ ratingValue: Int) {
        guard let userId = settings.userId else {
            return
        }

        guard let rating = RatingScore(rawValue: ratingValue + 1) else {
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

    /**
     Unrates the previously given rating.
     If the user has yet to rate the recipe, do nothing.
     */
    func removeRating() {
        guard let ownRating = ownRating else {
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
