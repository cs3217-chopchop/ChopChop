import Combine
import Foundation
import UIKit

final class IngredientCollectionViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var filterByExpiryDate = false {
        didSet {
            expiryDateStart = .today
            expiryDateEnd = .today
        }
    }
    @Published var expiryDateStart = Date.today
    @Published var expiryDateEnd = Date.today
    @Published private(set) var ingredients: [IngredientInfo] = []

    let title: String
    let categoryIds: [Int64?]

    private let storageManager = StorageManager()
    private var ingredientsCancellable: AnyCancellable?

    init(title: String, categoryIds: [Int64?] = [nil]) {
        self.title = title
        self.categoryIds = categoryIds

        ingredientsCancellable = ingredientsPublisher()
            .sink { [weak self] ingredients in
                self?.ingredients = ingredients
            }
    }

    var categoryId: Int64? {
        guard !categoryIds.isEmpty else {
            return nil
        }

        guard categoryIds.count == 1, let id = categoryIds.first else {
            return nil
        }

        return id
    }

    func deleteIngredients(at offsets: IndexSet) throws {
        let ids = offsets.compactMap { ingredients[$0].id }
        try storageManager.deleteIngredients(ids: ids)
    }

    private func ingredientsPublisher() -> AnyPublisher<[IngredientInfo], Never> {
        $query.combineLatest($filterByExpiryDate, $expiryDateStart, $expiryDateEnd)
            .map { [self] query, filterByExpiryDate, expiryDateStart, expiryDateEnd
                -> AnyPublisher<[IngredientInfo], Error> in
                if filterByExpiryDate {
                    return storageManager.ingredientsPublisher(query: query,
                                                               categoryIds: categoryIds,
                                                               expiresAfter: expiryDateStart,
                                                               expiresBefore: expiryDateEnd)
                } else {
                    return storageManager.ingredientsPublisher(query: query, categoryIds: categoryIds)
                }
            }
            .map { ingredientsPublisher in
                ingredientsPublisher.catch { _ in
                    Just<[IngredientInfo]>([])
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func getIngredient(info: IngredientInfo) -> Ingredient? {
        guard let id = info.id else {
            return nil
        }

        return try? storageManager.fetchIngredient(id: id)
    }

    func getIngredientImage(ingredient: Ingredient) -> UIImage {
        storageManager.fetchIngredientImage(name: ingredient.name) ?? UIImage()
    }
}
