import Foundation
import SwiftUI
import Combine

/**
 Represents a view model for a view of a batch of an ingredient.
 */
class IngredientBatchViewModel: ObservableObject {
    /// Displayed information about the ingredient batch
    @Published private(set) var quantityDescription: String = ""
    @Published private(set) var expiryDateDescription: String?

    init(batch: IngredientBatch) {
        self.quantityDescription = batch.quantity.description
        self.expiryDateDescription = IngredientBatchViewModel.getExpiryDateDescription(batch)
    }

    private static func getExpiryDateDescription(_ batch: IngredientBatch) -> String? {
        guard let expiryDate = batch.expiryDate else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: expiryDate)
    }
}
