import SwiftUI

/**
 Represents a view model for a view for the form for adding or editing an ingredient batch.
 */
class IngredientBatchFormViewModel: ObservableObject {
    /// Is true if the form edits an existing ingredient batch, and is false if the form adds a new ingredient batch.
    let isEdit: Bool

    /// The ingredient batch edited by the form, or an empty batch if the form adds a new ingredient batch.
    let batch: IngredientBatch
    /// The quantity type of the ingredient batch.
    let quantityType: QuantityType

    private let ingredientViewModel: IngredientViewModel

    /// Form fields
    @Published var selectedUnit: String
    @Published var inputQuantity: String
    @Published var expiryDateEnabled: Bool
    @Published var selectedDate: Date

    @Published var alertIdentifier: AlertIdentifier?

    init(edit batch: IngredientBatch, quantityType: QuantityType, ingredientViewModel: IngredientViewModel) {
        self.batch = batch
        self.quantityType = quantityType
        self.ingredientViewModel = ingredientViewModel
        self.isEdit = true

        self.selectedUnit = batch.quantity.unit.description
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

    init(addBatchTo ingredientViewModel: IngredientViewModel, quantityType: QuantityType) throws {
        var quantity: Quantity

        switch quantityType {
        case .count:
            quantity = try Quantity(.count, value: 0)
        case .mass:
            quantity = try Quantity(.mass(.baseUnit), value: 0)
        case .volume:
            quantity = try Quantity(.volume(.baseUnit), value: 0)
        }

        self.batch = IngredientBatch(quantity: quantity)
        self.quantityType = quantityType
        self.ingredientViewModel = ingredientViewModel
        self.isEdit = false

        self.selectedUnit = batch.quantity.unit.description
        self.inputQuantity = String(batch.quantity.value)
        self.expiryDateEnabled = false
        self.selectedDate = Date()
    }

    /**
     Saves the ingredient batch to local storage.
     */
    func save() throws {
        guard let convertedValue = Double(inputQuantity) else {
            throw QuantityError.invalidQuantity
        }

        var newQuantity: Quantity

        switch quantityType {
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

        try ingredientViewModel.add(quantity: newQuantity, expiryDate: newExpiryDate)
    }

    private let massUnitMap: [String: MassUnit] = [
        "kg": .kilogram,
        "g": .gram,
        "lb": .pound,
        "oz": .ounce
    ]

    private let volumeUnitMap: [String: VolumeUnit] = [
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
