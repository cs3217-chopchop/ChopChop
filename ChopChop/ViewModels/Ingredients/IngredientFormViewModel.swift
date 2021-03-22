import SwiftUI

class IngredientFormViewModel: ObservableObject {
    private(set) var ingredient: Ingredient
    let isEdit: Bool

    @Published var selectedType: QuantityType
    @Published var inputName: String
    @Published var image: UIImage

    @Published var isShowingPhotoLibrary = false
    var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    init(edit ingredient: Ingredient) {
        self.ingredient = ingredient
        self.isEdit = true

        self.selectedType = ingredient.quantityType
        self.inputName = ingredient.name
        self.image = ingredient.image ?? UIImage()
    }

    init() throws {
        self.ingredient = try Ingredient(name: "temporary", type: .count)
        self.isEdit = false

        self.selectedType = .count
        self.inputName = ""
        self.image = UIImage()
    }

    var areFieldsValid: Bool {
        !inputName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() throws {
        let storageManager = StorageManager()

        guard areFieldsValid else {
            return
        }

        if isEdit {
            try ingredient.rename(inputName)

            if image != UIImage() {
                try storageManager.saveIngredientImage(image, name: inputName)
            }
        } else {
            ingredient = try Ingredient(name: inputName, type: selectedType)
        }

        try storageManager.saveIngredient(&ingredient)
    }
}