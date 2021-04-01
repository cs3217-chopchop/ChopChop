import Combine
import Foundation

final class MainViewModel: ObservableObject {
    @Published private(set) var recipeCategories: [RecipeCategory] = []

    private let storageManager = StorageManager()
    private var recipeCategoriesCancellable: AnyCancellable?
    private var test = [AnyCancellable]()
    private let storage = StorageManager()
    private let db = FirebaseDatabase()
    @Published var recipes: OnlineRecipe?

    var currentCookingSession: SessionRecipe?

    init() {
        recipeCategoriesCancellable = recipeCategoriesPublisher()
            .sink { [weak self] categories in
                self?.recipeCategories = categories
            }
        do {
//        try storage.removeRecipeFromLocal(recipeId: "grrsE5SgRjIX9yf6NEvv")
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    print("finished")
//                    break
//                case .failure:
//                    print("error")
//                    self.recipes = nil
//                }
//
//            }, receiveValue: { value in
//                print(value)
//                self.recipes = value
//            })
//            .store(in: &test)
        } catch {
            print("error")
        }
    }

    private func recipeCategoriesPublisher() -> AnyPublisher<[RecipeCategory], Never> {
        storageManager.recipeCategoriesPublisher()
            .catch { _ in
                Just<[RecipeCategory]>([])
            }
            .eraseToAnyPublisher()
    }
}
