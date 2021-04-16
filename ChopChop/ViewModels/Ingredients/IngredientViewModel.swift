import SwiftUI
import UIKit
import Combine

class IngredientViewModel: ObservableObject {
    @Published private(set) var ingredient: Ingredient?
    @Published private(set) var image: UIImage?

    @Published var activeFormView: FormView?
    @Published var alertIdentifier: AlertIdentifier?

    private let storageManager = StorageManager()
    private var ingredientCancellable: AnyCancellable?

    init(id: Int64) {
        ingredientCancellable = ingredientPublisher(id: id)
            .sink { [weak self] ingredient in
                self?.ingredient = ingredient

                if let ingredient = ingredient, let id = ingredient.id {
                    self?.image = self?.storageManager.fetchIngredientImage(name: String(id))
                }
            }
    }

    private func ingredientPublisher(id: Int64) -> AnyPublisher<Ingredient?, Never> {
        storageManager.ingredientPublisher(id: id)
            .catch { _ in
                Just<Ingredient?>(nil)
            }
            .eraseToAnyPublisher()
    }

    func removeBatch(expiryDate: Date?) throws {
        guard var ingredient = ingredient else {
            return
        }

        ingredient.removeBatch(expiryDate: expiryDate)
        save(&ingredient)
    }

    func add(quantity: Quantity, expiryDate: Date?) throws {
        guard var ingredient = ingredient else {
            return
        }

        try ingredient.add(quantity: quantity, expiryDate: expiryDate)
        save(&ingredient)
    }

    func deleteBatch(expiryDate: Date?) {
        guard var ingredient = ingredient else {
            return
        }

        ingredient.removeBatch(expiryDate: expiryDate)
        save(&ingredient)
    }

    func deleteExpiredBatches() {
        guard var ingredient = ingredient else {
            return
        }

        ingredient.removeExpiredBatches()
        save(&ingredient)
    }

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
