import Foundation
import SwiftUI
import Combine

class IngredientBatchViewModel {
    @ObservedObject var batch: IngredientBatch

    @Published private(set) var quantityDescription: String = ""

    private var cancellables = Set<AnyCancellable>()

    init(batch: IngredientBatch) {
        self.batch = batch

        batch.$quantity
            .sink { [weak self] quantity in
                self?.quantityDescription = quantity.description
            }
            .store(in: &cancellables)
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
