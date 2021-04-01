import Combine
import Foundation

final class MainViewModel: ObservableObject {
    @Published private(set) var recipeCategories: [RecipeCategory] = []

    private let storageManager = StorageManager()
    private var recipeCategoriesCancellable: AnyCancellable?
    private var test = [AnyCancellable]()
    private let storage = StorageManager()
    @Published var recipes = [OnlineRecipe]()

    var currentCookingSession: SessionRecipe?

    init() {
        recipeCategoriesCancellable = recipeCategoriesPublisher()
            .sink { [weak self] categories in
                self?.recipeCategories = categories
            }
        storage.fetchAllPublishedRecipes(userId: "12345")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("finished")
                    break
                case .failure:
                    print("error")
                    self.recipes = []
                }

            }, receiveValue: { value in
                print(value)
                self.recipes = value
            })
            .store(in: &test)
    }

    private func recipeCategoriesPublisher() -> AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesPublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }
}
