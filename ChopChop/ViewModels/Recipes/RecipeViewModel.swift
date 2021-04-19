import SwiftUI
import Combine

/**
 Represents a view model for a view of a recipe.
 */
final class RecipeViewModel: ObservableObject {
    /// The recipe displayed by the view.
    @Published private(set) var recipe: Recipe?
    /// The image corresponding to the displayed recipe.
    @Published private(set) var image: UIImage?
    /// The recipe from which the displayed recipe was downloaded from.
    /// Is `nil` if the displayed recipe was not downloaded from an online recipe.
    @Published private(set) var parentRecipe: OnlineRecipe?
    /// The total time taken to make the recipe.
    @Published private(set) var totalTimeTaken: String = ""

    /// Display flags
    @Published var showSessionRecipe = false
    @Published var showRecipeForm = false
    @Published var showParentRecipe = false

    var isPublished: Bool {
        recipe?.onlineId != nil
    }

    var isCookingDisabled: Bool {
        (recipe?.ingredients.isEmpty ?? false) && (recipe?.stepGraph.nodes.isEmpty ?? false)
    }

    private let timeFormatter: DateComponentsFormatter
    private let settings: UserSettings
    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    init(id: Int64, settings: UserSettings) {
        self.settings = settings

        timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.includesApproximationPhrase = true
        timeFormatter.unitsStyle = .abbreviated

        recipePublisher(id: id)
            .sink { [weak self] recipe in
                self?.recipe = recipe

                if let recipe = recipe {
                    self?.totalTimeTaken = self?.timeFormatter.string(from: recipe.totalTimeTaken) ?? ""
                } else {
                    self?.totalTimeTaken = ""
                }

                if let recipe = recipe, let id = recipe.id {
                    self?.image = self?.storageManager.fetchRecipeImage(name: String(id))
                }
            }
            .store(in: &cancellables)

        if let parentId = recipe?.parentOnlineRecipeId {
            storageManager.fetchOnlineRecipe(id: parentId) { onlineRecipe, _ in
                self.parentRecipe = onlineRecipe
            }
        }
    }

    func publish() {
        guard var recipe = recipe, let userId = settings.userId else {
            return
        }

        if isPublished {
            try? storageManager.updateOnlineRecipe(recipe: recipe, userId: userId) { _ in }
        } else {
            try? storageManager.addOnlineRecipe(recipe: &recipe, userId: userId) { _ in }
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
