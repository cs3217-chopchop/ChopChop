import SwiftUI
import Combine

class IngredientFormViewModel: ObservableObject {
    @Published var categories: [IngredientCategory] = []

    let isEdit: Bool

    @Published var name: String
    @Published var quantityType: QuantityType
    @Published var category: IngredientCategory?
    @Published var image: UIImage

    @Published var alertIdentifier: AlertIdentifier?

    @Published var isShowingPhotoLibrary = false
    var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    private let storageManager = StorageManager()
    private var ingredientCategoriesCancellable: AnyCancellable?
    private let ingredient: Ingredient?

    init(edit ingredient: Ingredient) {
        self.ingredient = ingredient
        self.isEdit = true

        self.quantityType = ingredient.quantityType
        self.name = ingredient.name
        self.category = ingredient.category

        if let id = ingredient.id {
            self.image = storageManager.fetchIngredientImage(name: String(id)) ?? UIImage()
        } else {
            self.image = UIImage()
        }

        ingredientCategoriesCancellable = categoriesPublisher()
            .sink { [weak self] categories in
                self?.categories = categories
            }
    }

    init(addToCategory categoryId: Int64?) {
        self.ingredient = nil
        self.isEdit = false

        self.quantityType = .count
        self.name = ""
        self.image = UIImage()

        ingredientCategoriesCancellable = categoriesPublisher()
            .sink { [weak self] categories in
                self?.categories = categories
            }
    }

    func save() throws {
        var updatedIngredient = try Ingredient(id: ingredient?.id,
                                               name: name,
                                               type: quantityType,
                                               batches: ingredient?.batches ?? [],
                                               category: category)

        try storageManager.saveIngredient(&updatedIngredient)

        if let id = updatedIngredient.id {
            if image == UIImage() {
                storageManager.deleteIngredientImage(name: String(id))
            } else {
                try storageManager.saveIngredientImage(image, name: String(id))
            }
        }g
    }

    func reset() {
        self.quantityType = .count
        self.name = ""
        self.category = nil
        self.image = UIImage()
    }

    private func categoriesPublisher() -> AnyPublisher<[IngredientCategory], Never> {
        storageManager.ingredientCategoriesPublisher()
            .catch { _ in
                Just<[IngredientCategory]>([])
            }
            .eraseToAnyPublisher()
    }

    struct AlertIdentifier: Identifiable {
        var id: AlertState

        // swiftlint:disable nesting
        enum AlertState {
            case emptyName
            case saveImageError
            case saveError
        }
        // swiftlint:enable nesting
    }

    func setAlertState(_ state: AlertIdentifier.AlertState) {
        self.alertIdentifier = AlertIdentifier(id: state)
    }
}
