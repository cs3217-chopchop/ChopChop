import SwiftUI

class IngredientBatchFormViewModel: ObservableObject {
    let batch: IngredientBatch
    var ingredient: Ingredient
    let isEdit: Bool

    @Published var selectedUnit: String
    @Published var inputQuantity: String
    @Published var expiryDateEnabled: Bool
    @Published var selectedDate: Date

    init(edit batch: IngredientBatch, in ingredient: Ingredient) {
        self.batch = batch
        self.ingredient = ingredient
        self.isEdit = true

        self.selectedUnit = batch.quantity.unit
        self.inputQuantity = String(batch.quantity.value)

        if let expiryDate = batch.expiryDate {
            self.expiryDateEnabled = true
            self.selectedDate = expiryDate
        } else {
            self.expiryDateEnabled = false
            self.selectedDate = Date()
        }
    }

    init(addBatchTo ingredient: Ingredient) throws {
        let quantity = try Quantity(ingredient.quantityType, value: 0)
        self.batch = IngredientBatch(quantity: quantity)
        self.ingredient = ingredient
        self.isEdit = false

        self.selectedUnit = ""
        self.inputQuantity = "0"
        self.expiryDateEnabled = false
        self.selectedDate = Date()
    }

    var areFieldsValid: Bool {
        // TODO: validate selected unit and input quantity
        true
    }

    func save() throws {
        guard areFieldsValid else {
            return
        }

        // TODO: handle quantity conversion
        guard let convertedValue = Double(inputQuantity) else {
            return
        }

        let newQuantity = try Quantity(ingredient.quantityType, value: convertedValue)
        let newExpiryDate: Date? = expiryDateEnabled ? selectedDate : nil

        if isEdit {
            ingredient.removeBatch(expiryDate: batch.expiryDate)
        }

        try ingredient.add(quantity: newQuantity, expiryDate: newExpiryDate)

        try StorageManager().saveIngredient(&ingredient)
    }
}
