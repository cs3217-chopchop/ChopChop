import SwiftUI
import Combine

class OnlineRecipeByUserViewModel: OnlineRecipeViewModel {
    // https://stackoverflow.com/questions/57615920/published-property-wrapper-not-working-on-subclass-of-observableobject
    @Published var creatorName = "No name" {
        willSet { self.objectWillChange.send() }
    }

    private var creatorCancellable: AnyCancellable?

    override init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings) {
        super.init(recipe: recipe, downloadRecipeViewModel: downloadRecipeViewModel, settings: settings)

        creatorCancellable = creatorPublisher()
            .sink { [weak self] user in
                self?.creatorName = user.name
            }
    }

    var ownRating: RecipeRating? {
        recipe.ratings.first(where: { $0.userId == settings.userId })
    }

    func tapRating(_ ratingValue: Int) {
        guard let USER_ID = settings.userId else {
            assertionFailure()
            return
        }

        guard let rating = RatingScore(rawValue: ratingValue + 1) else {
            assertionFailure()
            return
        }

        guard ownRating != nil else {
            storageManager.rateRecipe(recipeId: recipe.id, userId: USER_ID, rating: rating)
            return
        }
        storageManager.rerateRecipe(recipeId: recipe.id, newRating: RecipeRating(userId: USER_ID, score: rating))
    }

    func removeRating() {
        guard let ownRating = ownRating else {
            assertionFailure()
            return
        }

        storageManager.unrateRecipe(recipeId: recipe.id, rating: ownRating)
    }

    private func creatorPublisher() -> AnyPublisher<User, Never> {
        storageManager.userByIdPublisher(userId: recipe.userId)
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

}
