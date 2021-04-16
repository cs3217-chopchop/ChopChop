import Foundation
import SwiftUI
import Combine

class IngredientBatchViewModel: ObservableObject {
    @Published private(set) var quantityDescription: String = ""
    @Published private(set) var expiryDateDescription: String?

    private var cancellables = Set<AnyCancellable>()

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
