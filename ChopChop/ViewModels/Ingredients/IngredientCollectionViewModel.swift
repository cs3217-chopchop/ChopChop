import Combine

final class IngredientCollectionViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var ingredients: [IngredientInfo] = []

    let title: String
    let categoryIds: [Int64]

    private let storageManager = StorageManager()
    private var ingredientsCancellable: AnyCancellable?

    init(title: String, categoryIds: [Int64] = []) {
        self.title = title
        self.categoryIds = categoryIds

        ingredientsCancellable = ingredientsPublisher()
            .sink { [weak self] ingredients in
                self?.ingredients = ingredients
            }
    }

    private func ingredientsPublisher() -> AnyPublisher<[IngredientInfo], Never> {
        $query.map { [self] query -> AnyPublisher<[IngredientInfo], Error> in
            storageManager.ingredientsPublisher(query: query,
                                                categoryIds: categoryIds)
        }
        .map { ingredientsPublisher in
            ingredientsPublisher.catch { _ in
                Just<[IngredientInfo]>([])
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
