import Foundation

class IngredientBatchViewModel {
    let batch: IngredientBatch

    init(batch: IngredientBatch) {
        self.batch = batch
    }

    var quantityDescription: String {
        batch.quantity.description
    }

    var expiryDateDescription: String? {
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
