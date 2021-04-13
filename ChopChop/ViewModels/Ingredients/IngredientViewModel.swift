import SwiftUI
import UIKit
import Combine

class IngredientViewModel: ObservableObject {
    @ObservedObject var ingredient: Ingredient

    @Published private(set) var ingredientName: String = ""
    @Published private(set) var ingredientBatches: [IngredientBatch] = []
    @Published private(set) var ingredientImage: UIImage?
    @Published var activeFormView: FormView?
    @Published var alertIdentifier: AlertIdentifier?

    private let storageManager = StorageManager()
    private var cancellables = Set<AnyCancellable>()

    init(ingredient: Ingredient) {
        self.ingredient = ingredient

        ingredient.$name
            .sink { [weak self] name in
                self?.ingredientName = name
                self?.ingredientImage = StorageManager().fetchIngredientImage(name: name)
            }
            .store(in: &cancellables)

        ingredient.$batches
            .sink { [weak self] batches in
                self?.ingredientBatches = batches
            }
            .store(in: &cancellables)
    }

    func addBatch(quantity: Quantity, expiryDate: Date?) {
        do {
            try ingredient.add(quantity: quantity, expiryDate: expiryDate)
            try storageManager.saveIngredient(&ingredient)
        } catch {
            setAlertState(.saveError)
        }
    }

    func deleteBatch(expiryDate: Date?) {
        ingredient.removeBatch(expiryDate: expiryDate)
        do {
            try storageManager.saveIngredient(&ingredient)
        } catch {
            setAlertState(.saveError)
        }
    }

    func deleteExpiredBatches() {
        ingredient.removeExpiredBatches()
        do {
            try storageManager.saveIngredient(&ingredient)
        } catch {
            setAlertState(.saveError)
        }
    }

    func deleteAllBatches() {
        ingredient.removeAllBatches()
        do {
            try storageManager.saveIngredient(&ingredient)
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
