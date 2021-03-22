import SwiftUI
import UIKit
import Combine

class IngredientViewModel: ObservableObject {
    @ObservedObject var ingredient: Ingredient

    @Published private(set) var ingredientName: String = ""
    @Published private(set) var ingredientBatches: [IngredientBatch] = []
    @Published private(set) var ingredientImage = UIImage()

    private let storageManager = StorageManager()
    private var cancellables = Set<AnyCancellable>()

    init(ingredient: Ingredient) {
        self.ingredient = ingredient

        ingredient.$name
            .sink { [weak self] name in
                self?.ingredientName = name
                self?.ingredientImage = StorageManager().fetchIngredientImage(name: name) ?? UIImage()
            }
            .store(in: &cancellables)

        ingredient.$batches
            .sink { [weak self] batches in
                self?.ingredientBatches = batches
            }
            .store(in: &cancellables)
    }
}
