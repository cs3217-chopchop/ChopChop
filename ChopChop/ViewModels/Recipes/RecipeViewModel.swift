import SwiftUI
import Combine

final class RecipeViewModel: ObservableObject {
    @Published private(set) var recipe: Recipe?
    @Published private(set) var image: UIImage?

    @Published var showSessionRecipe = false
    @Published var showRecipeForm = false

    var isPublished: Bool {
        recipe?.onlineId != nil
    }
    var isCookingDisabled: Bool {
        (recipe?.ingredients.isEmpty ?? false) && (recipe?.stepGraph.nodes.isEmpty ?? false)
    }

    let timeFormatter: DateComponentsFormatter
    private let storageManager = StorageManager()
    private var recipeCancellable: AnyCancellable?
    private let settings: UserSettings

    init(id: Int64, settings: UserSettings) {
        self.settings = settings

        timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.includesApproximationPhrase = true
        timeFormatter.unitsStyle = .abbreviated

        recipeCancellable = recipePublisher(id: id)
            .sink { [weak self] recipe in
                self?.recipe = recipe

                if let recipe = recipe, let id = recipe.id {
                    self?.image = self?.storageManager.fetchRecipeImage(name: String(id))
                }
            }
    }

    // TODO: Properly throw errors
    func publish() {
        guard var recipe = recipe, let userId = settings.userId else {
            assertionFailure()
            return
        }

        if isPublished {
            storageManager.updateOnlineRecipe(recipe: recipe, userId: userId)
        } else {
            try? storageManager.publishRecipe(recipe: &recipe, userId: userId)
        }
    }

    private func recipePublisher(id: Int64) -> AnyPublisher<Recipe?, Never> {
        storageManager.recipePublisher(id: id)
            .catch { _ in
                Just<Recipe?>(nil)
            }
            .eraseToAnyPublisher()
    }
}
