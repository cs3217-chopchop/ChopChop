import Combine
import Foundation
import UIKit

/**
 Represents a view model for a view of a collection of ingredients.
 */
final class IngredientCollectionViewModel: ObservableObject {
    /// The name of the collection of ingredients.
    let title: String
    /// The ingredients displayed in the view is the union of ingredients in
    /// each of the categories in this array, represented by their ids.
    let categoryIds: [Int64?]

    /// The collection of ingredients displayed in the view.
    @Published private(set) var ingredients: [IngredientInfo] = []

    /// Search fields
    @Published var query: String = ""
    @Published var filterByExpiryDate = false {
        didSet {
            expiryDateStart = .today
            expiryDateEnd = .today
        }
    }
    @Published var expiryDateStart = Date.today
    @Published var expiryDateEnd = Date.today

    /// Alert fields
    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    private let storageManager = StorageManager()
    private var cancellables: Set<AnyCancellable> = []

    init(title: String, categoryIds: [Int64?] = [nil]) {
        self.title = title
        self.categoryIds = categoryIds

        ingredientsPublisher
            .sink { [weak self] ingredients in
                self?.ingredients = ingredients
            }
            .store(in: &cancellables)
    }

    /// Returns the category represented by the view model,
    /// or `nil` if it represents all ingredients or uncategorised ingredients.
    var category: IngredientCategory? {
        guard categoryIds.compactMap({ $0 }).count == 1 else {
            return nil
        }

        return try? IngredientCategory(name: title, id: categoryIds.compactMap({ $0 }).first)
    }

    /**
     Deletes the ingredients at the given indices of the ingredient array.
     */
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

    /**
     Returns the corresponding image of the ingredient, or `nil` if such an image does not exist in local storage.
     */
    func getIngredientImage(ingredient: IngredientInfo) -> UIImage? {
        guard let id = ingredient.id else {
            return nil
        }

        return storageManager.fetchIngredientImage(name: String(id))
    }

    private var ingredientsPublisher: AnyPublisher<[IngredientInfo], Never> {
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
}
