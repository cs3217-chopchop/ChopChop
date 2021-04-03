import SwiftUI
import Combine

class OnlineRecipeViewModel: ObservableObject {
    private(set) var recipe: OnlineRecipe

    private var recipeCancellable: AnyCancellable?
    let storageManager = StorageManager()

    init(recipe: OnlineRecipe) {
        self.recipe = recipe

        recipeCancellable = onlineRecipePublisher()
            .sink { [weak self] recipe in
                self?.recipe = recipe
            }
    }

    var averageRating: Double {
        guard !recipe.ratings.isEmpty else {
            return 0
        }
        return Double(recipe.ratings.map { $0.score.rawValue }.reduce(0, +)) / Double(recipe.ratings.count)
    }

    private func onlineRecipePublisher() -> AnyPublisher<OnlineRecipe, Never> {
        storageManager.onlineRecipeByIdPublisher(recipeId: recipe.id)
            .assertNoFailure()
            .eraseToAnyPublisher()
    }

}
