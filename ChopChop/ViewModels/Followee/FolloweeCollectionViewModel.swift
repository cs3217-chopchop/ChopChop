import Combine
import Foundation
import UIKit

final class FolloweeCollectionViewModel: ObservableObject {
//    @Published var query: String = ""
    @Published private var allUsers: [User] = []
    @Published private(set) var currentFolloweeViewModels: [CurrentFolloweeViewModel]
    @Published private(set) var notCurrentFolloweeViewModels: [NotCurrentFolloweeViewModel]
    private let currentUserId: String = "" // TODO

    private let storageManager = StorageManager()
//    private var ingredientsCancellable: AnyCancellable?

    init() {
//        ingredientsCancellable = ingredientsPublisher()
//            .sink { [weak self] ingredients in
//                self?.ingredients = ingredients
//            }

        // fetch current user id
    }


    func deleteIngredients(at offsets: IndexSet) {
        do {
            let ids = offsets.compactMap { ingredients[$0].id }
            try storageManager.deleteIngredients(ids: ids)
        } catch {
            alertTitle = "Database error"
            alertMessage = "\(error)"

            alertIsPresented = true
        }
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
