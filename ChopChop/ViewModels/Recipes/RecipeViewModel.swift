import SwiftUI
import Combine

class RecipeViewModel: ObservableObject {
    @ObservedObject private(set) var recipe: Recipe

    private var storage = StorageManager()
    private var cancellables = Set<AnyCancellable>()
    private let storageManager = StorageManager()

    private(set) var hasError = false

    @Published var isShowingForm = false
    @Published var isShowingPhotoLibrary = false
    @Published private(set) var recipeName: String = ""
    @Published private(set) var serving: Double = 1
    @Published private(set) var recipeCategory: String = ""
    @Published private(set) var difficulty: Difficulty?
    @Published var image: UIImage
    @Published private(set) var errorMessage = ""
    @Published private(set) var ingredients = [String]()
    @Published private(set) var stepGraph = RecipeStepGraph()
    @Published private(set) var isPublished = false
    let totalTimeTaken: String

    private let settings: UserSettings

    init(recipe: Recipe, settings: UserSettings) {
        self.recipe = recipe
        self.settings = settings
        image = storageManager.fetchRecipeImage(name: recipe.name) ?? UIImage()
        totalTimeTaken = get_HHMMSS_Display(seconds: recipe.totalTimeTaken)

        bindName()
        bindServing()
        bindRecipeCategory()
        bindDifficulty()
        bindInstructions()
        bindPublished()
        bindStepGraph()

    }

    private func bindName() {
        recipe.$name
            .sink { [weak self] name in
                self?.recipeName = name
            }
            .store(in: &cancellables)
    }

    private func bindServing() {
        recipe.$servings
            .sink { [weak self] serving in
                self?.serving = serving
            }
            .store(in: &cancellables)
    }

    private func bindDifficulty() {
        recipe.$difficulty
            .sink { [weak self] difficulty in
                self?.difficulty = difficulty

            }
            .store(in: &cancellables)
    }

    private func bindStepGraph() {
        recipe.$stepGraph
            .sink { [weak self] stepGraph in
                self?.stepGraph = stepGraph
            }
            .store(in: &cancellables)
    }

    private func bindInstructions() {
        recipe.$ingredients
            .sink { [weak self] ingredient in
                self?.ingredients = ingredient.map({ $0.description })

            }
            .store(in: &cancellables)
    }

    private func bindRecipeCategory() {
        recipe.$recipeCategoryId
            .sink { [weak self] category in
                if let categoryId = category {
                    do {
                        self?.recipeCategory = try self?.storage.fetchRecipeCategory(id: categoryId)?.name ?? ""
                    } catch {

                    }
                }
            }
            .store(in: &cancellables)
    }

    private func bindPublished() {
        recipe.$onlineId
            .sink { [weak self] onlineId in
                self?.isPublished = onlineId != nil
            }
            .store(in: &cancellables)
    }

    func publish() {
        guard let userId = settings.userId else {
            assertionFailure()
            return
        }

        guard isPublished else {
            try? storageManager.addOnlineRecipe(recipe: &recipe, userId: userId)
            return
        }
        storageManager.updateOnlineRecipe(recipe: recipe, userId: userId)
    }

}
