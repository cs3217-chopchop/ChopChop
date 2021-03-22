import SwiftUI

class IngredientFormViewModel: ObservableObject {
    private(set) var ingredient: Ingredient?
    let isEdit: Bool

    @Published var selectedType: BaseQuantityType
    @Published var inputName: String
    @Published var image: UIImage

    @Published var isShowingPhotoLibrary = false
    var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    private let storageManager = StorageManager()

    init(edit ingredient: Ingredient) {
        self.ingredient = ingredient
        self.isEdit = true

        self.selectedType = ingredient.quantityType
        self.inputName = ingredient.name
        self.image = StorageManager().fetchIngredientImage(name: ingredient.name) ?? UIImage()
    }

    init() {
        self.ingredient = nil
        self.isEdit = false

        self.selectedType = .count
        self.inputName = ""
        self.image = UIImage()
    }

    var areFieldsValid: Bool {
        !inputName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() throws {
        guard areFieldsValid else {
            return
        }

        if isEdit {
            try ingredient?.rename(inputName)
        } else {
            ingredient = try Ingredient(name: inputName, type: selectedType)
        }

        guard var savedIngredient = ingredient else {
            return
        }

        if image != UIImage() {
            try storageManager.saveIngredientImage(image, name: inputName)
        }

        try storageManager.saveIngredient(&savedIngredient)
    }

    func reset() {
        self.selectedType = .count
        self.inputName = ""
        self.image = UIImage()
    }
}
