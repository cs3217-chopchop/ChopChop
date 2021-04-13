import SwiftUI

class IngredientBatchFormViewModel: ObservableObject {
    let batch: IngredientBatch
    let ingredientViewModel: IngredientViewModel
    let isEdit: Bool

    @Published var selectedUnit: String
    @Published var inputQuantity: String
    @Published var expiryDateEnabled: Bool
    @Published var selectedDate: Date

    @Published var alertIdentifier: AlertIdentifier?

    init(edit batch: IngredientBatch, ingredientViewModel: IngredientViewModel) {
        self.batch = batch
        self.ingredientViewModel = ingredientViewModel
        self.isEdit = true

        self.selectedUnit = batch.quantity.type.description
        self.inputQuantity = String(batch.quantity.value)

        if let expiryDate = batch.expiryDate {
            self.expiryDateEnabled = true
            self.selectedDate = expiryDate
        } else {
            self.expiryDateEnabled = false
            self.selectedDate = Calendar.current // Set selected date to one week from today
                .startOfDay(for: Date())
                .addingTimeInterval(24 * 60 * 60 * 7)
        }
    }

    init(addBatchTo ingredientViewModel: IngredientViewModel) throws {
        var quantity: Quantity

        switch ingredientViewModel.ingredient.quantityType {
        case .count:
            quantity = try Quantity(.count, value: 0)
        case .mass:
            quantity = try Quantity(.mass(.baseUnit), value: 0)
        case .volume:
            quantity = try Quantity(.volume(.baseUnit), value: 0)
        }

        self.batch = IngredientBatch(quantity: quantity)
        self.ingredientViewModel = ingredientViewModel
        self.isEdit = false

        self.selectedUnit = batch.quantity.type.description
        self.inputQuantity = String(batch.quantity.value)
        self.expiryDateEnabled = false
        self.selectedDate = Date()
    }

    func save() throws {
        guard let convertedValue = Double(inputQuantity) else {
            throw QuantityError.invalidQuantity
        }

        var newQuantity: Quantity

        switch ingredientViewModel.ingredient.quantityType {
        case .count:
            newQuantity = try Quantity(.count, value: convertedValue)
        case .mass:
            guard let unit = massUnitMap[selectedUnit] else {
                throw QuantityError.invalidUnit
            }

            newQuantity = try Quantity(.mass(unit), value: convertedValue)
        case .volume:
            guard let unit = volumeUnitMap[selectedUnit] else {
                throw QuantityError.invalidUnit
            }

            newQuantity = try Quantity(.volume(unit), value: convertedValue)
        }

        let newExpiryDate: Date? = expiryDateEnabled ? selectedDate : nil

        if isEdit {
            ingredientViewModel.deleteBatch(expiryDate: batch.expiryDate)
        }

        try ingredientViewModel.addBatch(quantity: newQuantity, expiryDate: newExpiryDate)
    }

    let massUnitMap: [String: MassUnit] = [
        "kg": .kilogram,
        "g": .gram,
        "lb": .pound,
        "oz": .ounce
    ]

    let volumeUnitMap: [String: VolumeUnit] = [
        "L": .liter,
        "ml": .milliliter,
        "cups": .cup,
        "tbsp": .tablespoon,
        "tsp": .teaspoon,
        "gallons": .gallon,
        "quarts": .quart,
        "pints": .pint
    ]

    var massUnits: [String] {
        Array(massUnitMap.keys)
    }

    var volumeUnits: [String] {
        Array(volumeUnitMap.keys)
    }

    struct AlertIdentifier: Identifiable {
        var id: AlertState

        // swiftlint:disable nesting
        enum AlertState {
            case invalidQuantity
            case negativeQuantity
            case invalidQuantityUnit
            case incompatibleQuantityTypes
            case saveError
        }
        // swiftlint:enable nesting
    }

    func setAlertState(_ state: AlertIdentifier.AlertState) {
        self.alertIdentifier = AlertIdentifier(id: state)
    }
}
