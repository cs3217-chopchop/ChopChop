import SwiftUI
import Combine

class OnlineRecipeByUserViewModel: OnlineRecipeViewModel {
    // https://stackoverflow.com/questions/57615920/published-property-wrapper-not-working-on-subclass-of-observableobject
    @Published var creatorName = "No name" {
        willSet { self.objectWillChange.send() }
    }

    private var creatorCancellable: AnyCancellable?
    @Published var downloadRecipeViewModel: DownloadRecipeViewModel

    init(recipe: OnlineRecipe, downloadRecipeViewModel: DownloadRecipeViewModel, settings: UserSettings) {
        self.downloadRecipeViewModel = downloadRecipeViewModel

        super.init(recipe: recipe, settings: settings)

        creatorCancellable = creatorPublisher()
            .sink { [weak self] user in
                self?.creatorName = user.name
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

        guard ownRating != nil else {
            storageManager.rateRecipe(recipeId: recipe.id, userId: userId, rating: rating)
            return
        }
        storageManager.rerateRecipe(recipeId: recipe.id, newRating: RecipeRating(userId: userId, score: rating))
    }

    func removeRating() {
        guard let ownRating = ownRating else {
            assertionFailure()
            return
        }

        storageManager.unrateRecipe(recipeId: recipe.id, rating: ownRating)
    }

    func setRecipe() {
        downloadRecipeViewModel.setRecipe(recipe: recipe)
    }

    private func creatorPublisher() -> AnyPublisher<User, Never> {
        storageManager.userByIdPublisher(userId: recipe.userId)
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

}
