import SwiftUI
import UIKit
import Combine

/**
 Represents a view model for a view of an ingredient.
 */
class IngredientViewModel: ObservableObject {
    /// The ingredient displayed by the view.
    @Published private(set) var ingredient: Ingredient?
    /// The image corresponding to the ingredient.
    @Published private(set) var image: UIImage?

    @Published var activeFormView: FormView?
    @Published var alertIdentifier: AlertIdentifier?

    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    init(id: Int64) {
        ingredientPublisher(id: id)
            .sink { [weak self] ingredient in
                self?.ingredient = ingredient

                if let ingredient = ingredient, let id = ingredient.id {
                    self?.image = self?.storageManager.fetchIngredientImage(name: String(id))
                }
            }
            .store(in: &cancellables)
    }

    /**
     Adds a batch with the given quantity and expiry date into the ingredient.
     */
    func add(quantity: Quantity, expiryDate: Date?) throws {
        guard var ingredient = ingredient else {
            return
        }

        try ingredient.add(quantity: quantity, expiryDate: expiryDate)
        save(&ingredient)
    }

    /**
     Removes the batch identified by the given expiry date from the ingredient.
     */
    func deleteBatch(expiryDate: Date?) {
        guard var ingredient = ingredient else {
            return
        }

        ingredient.removeBatch(expiryDate: expiryDate)
        save(&ingredient)
    }

    /**
     Removes all batches with past expiry dates from the ingredient.
     */
    func deleteExpiredBatches() {
        guard var ingredient = ingredient else {
            return
        }

        ingredient.removeExpiredBatches()
        save(&ingredient)
    }

    /**
     Removes all batches from the ingredient.
     */
    func deleteAllBatches() {
        guard var ingredient = ingredient else {
            return
        }

        ingredient.removeAllBatches()
        save(&ingredient)
    }

    private func save(_ ingredient: inout Ingredient) {
        do {
            try storageManager.saveIngredient(&ingredient)
            self.ingredient = ingredient
        } catch {
            setAlertState(.saveError)
        }
    }

    private func ingredientPublisher(id: Int64) -> AnyPublisher<Ingredient?, Never> {
        storageManager.ingredientPublisher(id: id)
            .catch { _ in
                Just<Ingredient?>(nil)
            }
            .eraseToAnyPublisher()
    }

    struct AlertIdentifier: Identifiable {
        var id: AlertState

        // swiftlint:disable nesting
        enum AlertState {
            case saveError
        }
        // swiftlint:enable nesting
    }

    func setAlertState(_ state: AlertIdentifier.AlertState) {
        self.alertIdentifier = AlertIdentifier(id: state)
    }

    enum FormView {
        case addBatch
        case editIngredient
    }
}
