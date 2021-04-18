import SwiftUI
import Combine

final class RecipeViewModel: ObservableObject {
    @Published private(set) var recipe: Recipe?
    @Published private(set) var image: UIImage?

//<<<<<<< HEAD
    private var cancellables = Set<AnyCancellable>()
//    private let storageManager = StorageManager()
//
//    private(set) var hasError = false

    @Published var parentRecipe: OnlineRecipe?
//    @Published var isShowingForm = false
//    @Published var isShowingPhotoLibrary = false
//    @Published private(set) var recipeName: String = ""
//    @Published private(set) var serving: Double = 1
//    @Published private(set) var recipeCategory: String = ""
//    @Published private(set) var difficulty: Difficulty?
//    @Published var image: UIImage
//    @Published private(set) var errorMessage = ""
//    @Published private(set) var ingredients = [String]()
//    @Published private(set) var stepGraph = RecipeStepGraph()
//    @Published private(set) var isPublished = false
//    let totalTimeTaken: String
//
//    private let settings: UserSettings
//
//    init(recipe: Recipe, settings: UserSettings) {
//        self.recipe = recipe
//        self.settings = settings
//        image = storageManager.fetchRecipeImage(name: recipe.name) ?? UIImage()
//        totalTimeTaken = get_HHMMSS_Display(seconds: recipe.totalTimeTaken)
//
//        bindName()
//        bindServing()
//        bindRecipeCategory()
//        bindDifficulty()
//        bindInstructions()
//        bindPublished()
//        bindStepGraph()
//=======
    @Published var showSessionRecipe = false
    @Published var showRecipeForm = false
    @Published var showParentRecipe = false

    var isPublished: Bool {
        recipe?.onlineId != nil
    }

    func fetchParentRecipe() {
        if parentRecipe != nil {
            return
        }
        guard let parentId = recipe?.parentId else {
            return
        }
        storageManager.fetchOnlineRecipe(id: parentId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.parentRecipe = nil
                }
            }, receiveValue: { value in
                self.parentRecipe = value
            })
            .store(in: &cancellables)
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
