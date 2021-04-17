import SwiftUI
import Combine

/**
 Represents the view model for a view of a form for adding or editing an ingredient.
 */
class IngredientFormViewModel: ObservableObject {
    /// Is true if the form edits an existing ingredient, and is false if the form adds a new ingredient.
    let isEdit: Bool
    /// The ingredient edited by the form, or `nil` if the form adds a new ingredient.
    private let ingredient: Ingredient?

    /// Form fields
    @Published var quantityType: QuantityType
    @Published var name: String
    @Published var categories: [IngredientCategory] = []
    @Published var category: IngredientCategory?
    @Published var image: UIImage

    @Published var alertIdentifier: AlertIdentifier?
    @Published var isShowingPhotoLibrary = false
    var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    init(edit ingredient: Ingredient) {
        self.isEdit = true
        self.ingredient = ingredient

        self.quantityType = ingredient.quantityType
        self.name = ingredient.name
        self.category = ingredient.category

        if let id = ingredient.id {
            self.image = storageManager.fetchIngredientImage(name: String(id)) ?? UIImage()
        } else {
            self.image = UIImage()
        }

        categoriesPublisher
            .sink { [weak self] categories in
                self?.categories = categories
            }
            .store(in: &cancellables)
    }

    init(addToCategory categoryId: Int64?) {
        self.isEdit = false
        self.ingredient = nil

        self.quantityType = .count
        self.name = ""
        self.image = UIImage()

        categoriesPublisher
            .sink { [weak self] categories in
                self?.categories = categories
            }
            .store(in: &cancellables)
    }

    /**
     Saves the ingredient to local storage.
     */
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
        }
    }

    private var categoriesPublisher: AnyPublisher<[IngredientCategory], Never> {
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
