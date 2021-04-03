import SwiftUI
import Combine

class OnlineRecipeByUserViewModel: OnlineRecipeViewModel {
    @Published var creatorName = "No name"

    @Published var saveAs = ""
    @Published var isDownload = false
    @Published var errorMessage = ""

    private var creatorCancellable: AnyCancellable?

    override init(recipe: OnlineRecipe) {
        super.init(recipe: recipe)

        creatorCancellable = creatorPublisher()
            .sink { [weak self] user in
                self?.creatorName = user.name
            }
    }

    var ownRating: RecipeRating? {
        recipe.ratings.first(where: { $0.userId == USER_ID })
    }

    func tapRating(_ ratingValue: Int) {
        guard let USER_ID = USER_ID else {
            assertionFailure()
            return
        }

        guard let rating = try? RatingScore(rawValue: ratingValue + 1) else {
            assertionFailure()
            return
        }

        guard ownRating != nil else {
            storageManager.rateRecipe(recipeId: recipe.id, userId: USER_ID, rating: rating)
            return
        }
        storageManager.rerateRecipe(recipeId: recipe.id, newRating: RecipeRating(userId: USER_ID, score: rating))
    }

    func downloadRecipe() {
        do {
            try storageManager.downloadRecipe(newName: saveAs, recipe: recipe)
            isDownload = false
            errorMessage = ""
        } catch {
            errorMessage = "Invalid name"
        }
    }

    func toggleIsDownload() {
        isDownload.toggle()
    }

    private func creatorPublisher() -> AnyPublisher<User, Never> {
        storageManager.userByIdPublisher(userId: recipe.userId)
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

}
